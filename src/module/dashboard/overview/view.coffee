#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'i18n!nls/lang.js',
         './module/dashboard/overview/template',
         './module/dashboard/overview/template_data',
         "component/exporter/Thumbnail"
         'constant',
         'unmanagedvpc',
         'backbone', 'jquery', 'handlebars', 'UI.scrollbar'
], ( ide_event, lang, overview_tmpl, template_data, ThumbUtil, constant, unmanagedvpc ) ->

    current_region = null

    ### helper ###
    Helper =
        switchTab: ( event, tabSelector, listSelector ) ->
            tabSelector =  if tabSelector instanceof $ then tabSelector else $( tabSelector )
            listSelector =  if listSelector instanceof $ then listSelector else $( listSelector )

            $target = $ event.currentTarget
            currentIndex = $(tabSelector).index $target

            if not $target.hasClass 'on'
                tabSelector.each ( index ) ->
                    if index is currentIndex
                        $( @ ).addClass( 'on' )
                    else
                        $( @ ).removeClass( 'on' )

                listSelector.each ( index ) ->
                    if index is currentIndex
                        $( @ ).show()
                    else
                        $( @ ).hide()
            null

        thumbError: ( event ) ->
            $target = $ event.currentTarget
            $target.hide()

        regexIndexOf: (str, regex, startpos) ->
            indexOf = str.substring(startpos || 0).search(regex)
            if indexOf >= 0 then (indexOf + (startpos || 0)) else indexOf

        updateLoadTime: ( time ) ->
            $('#global-refresh').text time

        scrollToResource: ->
            scrollContent = $( '#global-region-wrap .scroll-content' )
            scrollContent.addClass 'scroll-transition'
            setTimeout ->
                scrollContent.removeClass( 'scroll-transition' )
                null
            , 100

            scrollTo = $('#global-region-map-wrap').height() + 7
            scrollbar.scrollTo( $( '#global-region-wrap' ), { 'top': scrollTo } )

        hasCredential: ->
            MC.common.cookie.getCookieByName('has_cred') is 'true'

        accountIsDemo: ->
            $.cookie('account_id') is 'demo_account'

    OverviewView = Backbone.View.extend {

        el                      : $( '#tab-content-dashboard' )

        overview                : overview_tmpl

        events          :
            'click #global-region-spot > li'            : 'gotoRegion'
            'click #global-region-create-stack-list li' : 'createStack'
            'click #btn-create-stack'                   : 'createStack'
            'click .global-region-status-content li a'  : 'openItem'
            'click .global-region-status-tab-item'      : 'switchRecent'
            'click #region-switch-list li'              : 'switchRegion'
            'click #region-resource-tab a'              : 'switchAppStack'
            'click #region-aws-resource-tab a'          : 'switchResource'
            'click #global-refresh'                     : 'reloadResource'
            'click .global-region-resource-content a'   : 'switchRegionAndResource'
            'click .show-credential'                    : 'showCredential'

            'click .region-resource-thumbnail'          : 'clickRegionResourceThumbnail'
            'click .table-app-link-clickable'           : 'openApp'
            'modal-shown .start-app'                    : 'startAppClick'
            'modal-shown .stop-app'                     : 'stopAppClick'
            'modal-shown .terminate-app'                : 'terminateAppClick'
            'modal-shown .duplicate-stack'              : 'duplicateStackClick'
            'modal-shown .delete-stack'                 : 'deleteStackClick'

            'click #global-region-visualize-VPC' : 'unmanagedVPCClick'
            'click #global-import-stack'         : 'importJson'

        status:
            reloading       : false
            resourceType    : null
            isDemo          : false

        initialize: ->
            $( document.body ).on 'click', 'div.nav-region-group a', @gotoRegion
            $( document.body ).on 'click', '#dashboard-global',      @gotoRegion
            # work for dashboard and toolbar
            $( document.body ).on 'keyup', '#confirm-app-name', @confirmAppName

        confirmAppName: ( event ) ->
            confirm = $( @ ).data 'confirm'
            if $( @ ).val() is confirm
                $( '#btn-confirm' ).removeAttr 'disabled'
            else
                $( '#btn-confirm' ).attr 'disabled', 'disabled'


        setDemo: ->
            @status.isDemo = true
            null

        clearDemo: ->
            @status.isDemo = false
            null

        reloadResource: ( event, skip_load) ->
            if Helper.hasCredential() and not @status.isDemo
                @status.reloading = true
                @showLoading '#global-view, #region-resource-wrap'
                if !skip_load
                # skip_load true means refresh after DescribeAccountAttributes
                # skip_load false means refresh by click refresh icon on ovewview
                    @trigger 'RELOAD_RESOURCE'
            else
                @showCredential()

        showLoading: ( selector ) ->
            @$el.find( selector ).html template_data.loading()

        showLoadingFaild: ( selector ) ->
            @$el.find( selector ).html template_data.loading_failed()

        switchRegion: ( event ) ->
            console.log 'switchRegion'
            target = $ event.currentTarget
            region = target.data 'region'
            current_region = region if region isnt 'global'
            regionName = target.find('a').text()

            if regionName is @$el.find( '#region-switch span' ).text()
                return

            @$el.find( '#region-switch span' )
                .text(regionName)
                .data 'region', region

            if region is 'global'
                @$el.find( '#global-view' ).show()
                @$el.find( '#region-view' ).hide()
            else
                if not @status.isDemo
                    @showLoading '#region-app-stack-wrap, #region-resource-wrap'
                @$el.find( '#global-view' ).hide()
                @$el.find( '#region-view' ).show()

                @trigger 'SWITCH_REGION', region
                @renderRegionAppStack()

        switchRecent: ( event ) ->
            Helper.switchTab event, '#global-region-status-tab-wrap a', '#global-region-status-content-wrap > div'

        switchAppStack: ( event ) ->
            Helper.switchTab event, '#region-resource-tab a', '.region-resource-list'

        switchResource: ( event ) ->
            type = $( event.currentTarget ).data 'resourceType'
            @renderRegionResourceBody type

        switchRegionAndResource: ( event ) ->
            $target = $ event.currentTarget
            region = $target.data 'region'
            @status.resourceType = $target.data 'resourceType'
            @gotoRegion region

        renderGlobalList: ( event ) ->
            #@enableSwitchRegion()
            if @status.reloading
                notification 'info', lang.ide.DASH_MSG_RELOAD_AWS_RESOURCE_SUCCESS
                @status.reloading = false

            tmpl = template_data.global_list @model.toJSON()
            if current_region
                @trigger 'SWITCH_REGION', current_region, true
            $( this.el ).find('#global-view').html tmpl

        renderRegionAppStack: ( tab ) ->
            @regionAppStackRendered = true
            tab = 'stack' if not tab
            context = _.extend {}, @model.toJSON()

            for i in context.cur_stack_list || []
                i.url = ThumbUtil.fetch( i.id )

            for i in context.cur_app_list || []
                i.url = ThumbUtil.fetch( i.id )


            context[ tab ] = true
            tmpl = template_data.region_app_stack context
            $( this.el )
                .find('#region-app-stack-wrap')
                .html( tmpl )
                .find('.region-resource-thumbnail img')
                .error Helper.thumbError

        renderRegionResource: ( event ) ->
            console.log  @model.toJSON()
            if not @status.reloading
                tmpl = template_data.region_resource_head @model.toJSON()
                @$el.find('#region-resource-wrap').html tmpl
                @renderRegionResourceBody()
            null

        renderRegionResourceBody: ( type, isReRender ) ->
            $typeTabs = $( '#region-aws-resource-tab .region-resource-tab-item')
            $currentTab = $typeTabs.filter( '.on' )
            currentType = $currentTab.data 'resourceType'

            if isReRender and type isnt currentType
                return

            if not type and not isReRender
                if @status.resourceType
                    type = @status.resourceType
                    @status.resourceType = null
                else
                    type = 'DescribeInstances'

            template = template_data[ type ]

            $typeTabs.each () ->
                if $( this ).data( 'resourceType' ) is type
                    $( this ).addClass 'on'
                else
                    $( this ).removeClass 'on'

            @$el.find("#region-aws-resource-data").html template @model.get 'cur_region_resource'

            null

        renderRecent: ->
            $( this.el ).find( '#global-region-status-widget' ).html template_data.recent @model.attributes
            null

        renderLoadingFaild: ->
            @showLoadingFaild '#global-view, #region-resource-wrap'

        renderGlobalDemo: ->
            @$el.find( '#global-view' ).html template_data.demo_global()

        renderRegionDemo: ->
            @$el.find( '#region-resource-wrap' ).html template_data.demo_region()

        enableCreateStack : ( platforms ) ->
            $middleButton = $( "#btn-create-stack" )
            $topButton    = $( "#global-create-stack" )

            $middleButton.removeAttr 'disabled'
            $topButton.removeAttr( 'disabled' ).addClass 'js-toggle-dropdown'

            $("#global-import-stack").removeAttr("disabled")

            # $.cookie('account_id') isnt 'demo_account' remvoe disable
            if MC.common.cookie.getCookieByName( 'account_id' ) isnt 'demo_account'
                $( '#global-region-visualize-VPC' ).removeAttr 'disabled'
            null

        enableSwitchRegion: ->
            $( '#region-switch' )
                .removeClass('disabled')
                .addClass('js-toggle-dropdown')

        disableSwitchRegion: ->
            $( '#region-switch' )
                .addClass('disabled')
                .removeClass('js-toggle-dropdown')

        createStack: ( event ) ->
            $target = $ event.currentTarget
            if $target.prop 'disabled'
                return
            #ide_event.trigger ide_event.ADD_STACK_TAB, $target.data( 'region' ) or current_region
            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'NEW_STACK', null, $target.data( 'region' ) or current_region, null

        gotoRegion: ( event ) ->
            console.log 'gotoRegion'
            if event is Object event
                $target = $ event.currentTarget
                region = ( $target.attr 'id' ) || ( $target.data 'regionName' )
                region = region.replace 'dashboard-global', 'global'
            else
                region = event

            $( "#region-switch-list li[data-region=#{region}]" ).click()
            Helper.scrollToResource()

        displayLoadTime: () ->
            # display refresh time
            loadTime = $.now() / 1000
            clearInterval @timer
            Helper.updateLoadTime MC.intervalDate( loadTime )
            @timer = setInterval ( ->
                Helper.updateLoadTime MC.intervalDate( loadTime )
                console.log 'timeupdate', loadTime
            ), 60001
            $( '#global-refresh ').show()
            null

        hideLoadTime: () ->
            $( '#global-refresh ').hide()
            null

        openApp: ( event ) ->
            $target = $ event.currentTarget
            name = $target.data 'name'
            id = $target.data 'id'
            #ide_event.trigger ide_event.OPEN_APP_TAB, name, current_region, id
            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'OPEN_APP', name, current_region, id

        showCredential: ( flag ) ->
            #flag = ''
            #if event
            #    if typeof(event) is 'string'
            #        flag = event
            #
            #    else
            #        event.preventDefault()

            require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule(flag)

        ############################################################################################


        renderMapResult : ->
            console.log 'dashboard overview-result render', @model.attributes

            cur_tmpl = template_data.overview_result @model.attributes

            $( this.el ).find('#global-region-spot').html cur_tmpl

            null

        render : () ->
            console.log 'dashboard overview render'
            console.log constant.REGION_LABEL
            region_names = _.map constant.REGION_LABEL, ( name, id ) ->
                long:
                    id: id, name: name
                short:
                    id: id, name: constant.REGION_SHORT_LABEL[ id ]

            data =
                region_names: region_names

            console.log data

            $( this.el ).html @overview data
            null

        openItem : (event) ->
            console.log 'click item'

            me = this
            id = event.currentTarget.id

            if id.indexOf('app-') == 0
                #ide_event.trigger ide_event.OPEN_APP_TAB, $("#"+id).data('option').name, $("#"+id).data('option').region, id
                ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'OPEN_APP', $("#"+id).data('option').name, $("#"+id).data('option').region, id
            else if id.indexOf('stack-') == 0
                #ide_event.trigger ide_event.OPEN_STACK_TAB, $("#"+id).data('option').name, $("#"+id).data('option').region, id
                ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'OPEN_STACK', $("#"+id).data('option').name, $("#"+id).data('option').region, id

            null

        clickRegionResourceThumbnail : (event) ->
            console.log 'click app/stack thumbnail'

            # check whether pending
            if $(event.currentTarget).children('.app-thumbnail-pending').length > 0
                # No need to show notification
                # notification 'warning', lang.ide.REG_MSG_WARN_APP_PENDING

            else
                item_info   = $(event.currentTarget).next('.region-resource-info')[0]
                id          = $(item_info).find('.modal')[0].id
                name        = $($(item_info).find('.region-resource-item-name')[0]).text()

                ##check params:region, id, name
                if id.indexOf('app-') is 0
                    #ide_event.trigger ide_event.OPEN_APP_TAB, name, current_region, id
                    ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'OPEN_APP', name, current_region, id

                else if id.indexOf('stack-') is 0
                    #ide_event.trigger ide_event.OPEN_STACK_TAB, name, current_region, id
                    ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'OPEN_STACK', name, current_region, id

            null

        deleteStackClick : (event) ->
            console.log 'click to delete stack'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard delete stack'

                modal.close()
                ide_event.trigger ide_event.DELETE_STACK, current_region, id, name

            null

        duplicateStackClick : (event) ->
            console.log 'click to duplicate stack'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            # set default name
            new_name = MC.aws.aws.getDuplicateName(name)
            $('#modal-input-value').val(new_name)

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'dashboard duplicate stack'
                new_name = $('#modal-input-value').val()

                #check duplicate stack name
                if not new_name
                    notification 'warning', lang.ide.PROP_MSG_WARN_NO_STACK_NAME
                else if new_name.indexOf(' ') >= 0
                    notification 'warning', lang.ide.PROP_MSG_WARN_WHITE_SPACE
                else if not MC.aws.aws.checkStackName null, new_name
                    notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_STACK_NAME
                else
                    modal.close()

                    ide_event.trigger ide_event.DUPLICATE_STACK, current_region, id, new_name, name

            null

        startAppClick : (event) ->
            console.log 'click to start app'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            # check credential
            if MC.common.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'dashboard region start app'
                    modal.close()
                    ide_event.trigger ide_event.START_APP, current_region, id, name

            null

        stopAppClick : (event) ->
            console.log 'click to stop app'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            # check credential
            if MC.common.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'dashboard region stop app'
                    modal.close()
                    ide_event.trigger ide_event.STOP_APP, current_region, id, name

            null

        terminateAppClick : (event) ->
            console.log 'click to terminate app'

            id      = $(event.currentTarget).attr('id')
            name    = $(event.currentTarget).attr('name')

            # check credential
            if MC.common.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'dashboard region terminal app'
                    modal.close()
                    ide_event.trigger ide_event.TERMINATE_APP, current_region, id, name

            null

        updateThumbnail : ( url, id ) ->
            console.log 'updateThumbnail, url = ' + url + ', id = ' + id
            _.each $('.region-resource-list-item').find('.region-resource-thumbnail img'), ( item ) ->
                $item = $ item
                if $item.attr('data-id') is id
                    new_url = 'https://madeiracloudthumbnails-dev.s3.amazonaws.com/' + url + '?time=' + Math.round(+new Date())
                    console.log 'new_url = ' + new_url
                    $item.attr 'src', new_url
                    $item.removeAttr 'style'

            null

        unmanagedVPCClick : ->
            console.log 'unmanagedVPCClick'

            if MC.common.cookie.getCookieByName( 'account_id' ) isnt 'demo_account'
                # load unmanagedvpc
                unmanagedvpc.loadModule()

            null

        importJson : ()->
            modal MC.template.importJSON()

            model = @model

            reader = new FileReader()
            reader.onload = ( evt )->
                error = model.importJson( reader.result )
                if error
                    $("#import-json-error").html error
                else
                    modal.close()
                    reader = null
                null

            reader.onerror = ()->
                $("#import-json-error").html lang.ide.POP_IMPORT_ERROR
                null

            hanldeFile = ( evt )->
                evt.stopPropagation()
                evt.preventDefault()

                $("#modal-import-json-dropzone").removeClass("dragover")
                $("#import-json-error").html("")

                evt = evt.originalEvent
                files = (evt.dataTransfer || evt.target).files
                if not files or not files.length then return
                reader.readAsText( files[0] )
                null

            $("#modal-import-json-file").on "change", hanldeFile
            zone = $("#modal-import-json-dropzone").on "drop", hanldeFile
            zone.on "dragenter", ()-> $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", true)
            zone.on "dragleave", ()-> $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", false)
            zone.on "dragover", ( evt )->
                dt = evt.originalEvent.dataTransfer
                if dt then dt.dropEffect = "copy"
                evt.stopPropagation()
                evt.preventDefault()
                null
            null

    }

    OverviewView
