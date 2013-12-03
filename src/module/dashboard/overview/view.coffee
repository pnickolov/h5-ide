#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'i18n!nls/lang.js',
         'text!./module/dashboard/overview/template.html',
         'text!./module/dashboard/overview/template_data.html',
         'constant',
         'backbone', 'jquery', 'handlebars', 'MC.ide.template', 'UI.scrollbar'
], ( ide_event, lang, overview_tmpl, overview_tmpl_data, constant ) ->

    current_region = null

    MC.IDEcompile 'overview', overview_tmpl_data,
        '.overview-result'      : 'overview-result-tmpl'
        '.global-list'          : 'global-list-tmpl'
        '.region-app-stack'     : 'region-app-stack-tmpl'
        '.region-resource-head' : 'region-resource-head-tmpl'
        '.region-resource-body' : 'region-resource-body-tmpl'
        '.recent'               : 'recent-tmpl'
        '.loading'              : 'loading-tmpl'
        '.loading-failed'       : 'loading-failed-tmpl'
        '.demo-global'          : 'global-demo-tmpl'
        '.demo-region'          : 'region-demo-tmpl'

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
            $('#global-refresh span').text time

        scrollToResource: ->
            scrollTo = $('#global-region-map-wrap').height() + 7
            scrollbar.scrollTo( $( '#global-region-wrap' ), { 'top': scrollTo } )

        hasCredential: ->
            MC.forge.cookie.getCookieByName('has_cred') is 'true'

        accountIsDemo: ->
            $.cookie('account_id') is 'demo_account'

    Template_Cache = {}

    OverviewView = Backbone.View.extend {

        el                      : $( '#tab-content-dashboard' )

        overview                : Handlebars.compile overview_tmpl
        overview_result         : Handlebars.compile $( '#overview-result-tmpl' ).html()
        global_list             : Handlebars.compile $( '#global-list-tmpl' ).html()
        region_app_stack        : Handlebars.compile $( '#region-app-stack-tmpl' ).html()
        region_resource_head    : Handlebars.compile $( '#region-resource-head-tmpl' ).html()
        region_resource_body    : Handlebars.compile $( '#region-resource-body-tmpl' ).html()
        recent                  : Handlebars.compile $( '#recent-tmpl' ).html()
        loading                 : $( '#loading-tmpl' ).html()
        loading_failed          : $( '#loading-failed-tmpl' ).html()
        region_demo             : $( '#region-demo-tmpl' ).html()
        global_demo             : $( '#global-demo-tmpl' ).html()


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

            'click #global-region-visualize-VPC'        : 'unmanagedVPCClick'

        status:
            reloading       : false
            resourceType    : null
            isDemo          : false

        initialize: ->
            $( document.body ).on 'click', 'div.nav-region-group a', @gotoRegion

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
            @$el.find( selector ).html @loading

        showLoadingFaild: ( selector ) ->
            @$el.find( selector ).html @loading_failed

        switchRegion: ( event ) ->
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

            tmpl = @global_list @model.toJSON()
            if current_region
                @trigger 'SWITCH_REGION', current_region, true
            $( this.el ).find('#global-view').html tmpl

        renderRegionAppStack: ( tab ) ->
            @regionAppStackRendered = true
            tab = 'stack' if not tab
            context = _.extend {}, @model.toJSON()
            context[ tab ] = true
            tmpl = @region_app_stack context
            $( this.el )
                .find('#region-app-stack-wrap')
                .html( tmpl )
                .find('.region-resource-thumbnail img')
                .error Helper.thumbError

        renderRegionResource: ( event ) ->
            console.log  @model.toJSON()
            if not @status.reloading
                tmpl = @region_resource_head @model.toJSON()
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

            if not Template_Cache[ type ]
                tmplAll = $( '#region-resource-body-tmpl' ).html()

                startPos = tmplAll.indexOf "<!-- #{type} -->"
                endPos = tmplAll.indexOf "<!-- #{type} -->", startPos + 1

                tmpl = tmplAll.slice startPos, endPos
                Template_Cache[ type ] = Handlebars.compile tmpl

            template = Template_Cache[ type ]

            $typeTabs.each () ->
                if $( this ).data( 'resourceType' ) is type
                    $( this ).addClass 'on'
                else
                    $( this ).removeClass 'on'

            @$el.find("#region-aws-resource-data").html template @model.get 'cur_region_resource'

            null

        renderRecent: ->
            $( this.el ).find( '#global-region-status-widget' ).html this.recent this.model.attributes
            null

        renderLoadingFaild: ->
            @showLoadingFaild '#global-view, #region-resource-wrap'

        renderGlobalDemo: ->
            @$el.find( '#global-view' ).html @global_demo

        renderRegionDemo: ->
            @$el.find( '#region-resource-wrap' ).html @region_demo

        enableCreateStack : ( platforms ) ->
            $middleButton = $( "#btn-create-stack" )
            $topButton = $( "#global-create-stack" )

            $middleButton.removeAttr 'disabled'
            $topButton.removeClass( 'disabled' ).addClass( 'js-toggle-dropdown' )

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
            if event is Object event
                $target = $ event.currentTarget
                region = ( $target.attr 'id' ) || ( $target.data 'regionName' )
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
            console.log 'dashboard overview-result render'

            cur_tmpl = (this.overview_result this.model.attributes)

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
            #hack
            setTimeout () ->
                $( '.icon-dashboard' ).css { background: "url('#{ window.location.origin }/assets/images/ide/icon-dashboard.png') center center no-repeat" }
            ,1000
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
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
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
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
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
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
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
                    new_url = 'https://s3.amazonaws.com/madeiracloudthumbnail/' + url + '?time=' + Math.round(+new Date())
                    console.log 'new_url = ' + new_url
                    $item.attr 'src', new_url
                    $item.removeAttr 'style'

            null

        unmanagedVPCClick : ->
            console.log 'unmanagedVPCClick'
            require [ 'component/unmanagedvpc/main' ], ( unmanagedvpc_main ) -> unmanagedvpc_main.loadModule()

    }

    OverviewView
