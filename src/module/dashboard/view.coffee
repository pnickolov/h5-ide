#############################
#  View(UI logic) for dashboard
#############################

define [ 'event', 'i18n!nls/lang.js',
         './module/dashboard/template',
         './module/dashboard/template_data',
         'constant',
         'unmanagedvpc',
         'backbone', 'jquery', 'handlebars', 'UI.scrollbar'
], ( ide_event, lang, overview_tmpl, template_data, constant, unmanagedvpc ) ->

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

        hasCredential: -> true

        accountIsDemo: -> not App.user.hasCredential()

    OverviewView = Backbone.View.extend {

        el                      : $( '#tab-content-dashboard' )

        overview                : overview_tmpl

        events          :
            "click .global-map-item"                                       : "gotoRegionFromMap"
            "click .global-map-item .app"                                  : "gotoRegionFromMap"
            'click .recent-list-item, .region-resource-list li'            : 'openItem'
            'click #global-region-create-stack-list li, #btn-create-stack' : 'createStack'

            "click .region-resource-list .delete-stack"    : "deleteStack"
            'click .region-resource-list .duplicate-stack' : 'duplicateStack'
            "click .region-resource-list .start-app"       : "startApp"
            'click .region-resource-list .stop-app'        : 'stopApp'
            'click .region-resource-list .terminate-app'   : 'terminateApp'

            'click .global-region-status-tab'           : 'switchRecent'
            'click #region-switch-list li'              : 'switchRegion'
            'click #region-resource-tab li'             : 'switchAppStack'
            'click .region-resource-tab-item'           : 'switchResource'
            'click #global-refresh'                     : 'reloadResource'
            'click .global-region-resource-content a'   : 'switchRegionAndResource'
            'click .show-credential'                    : 'showCredential'


            'click .table-app-link-clickable' : 'openApp'

            'click #global-region-visualize-VPC' : 'unmanagedVPCClick'
            'click #global-import-stack'         : 'importJson'

        status:
            reloading       : false
            resourceType    : null
            isDemo          : false

        initialize: ->
            # work for dashboard and toolbar
            $( document.body ).on 'keyup', '#confirm-app-name', @confirmAppName

            @render()

            @regionTab = "stack"
            @region    = "global"

            # Watch appList/stackList changes.
            @listenTo App.model.stackList(), "update", ()->
                console.info "Dashboard Updated due to changes in stack list."
                @renderMapResult()
                @renderRecent()
                @renderRegionAppStack()
                return

            @listenTo App.model.appList(),   "update", ()->
                @renderMapResult()
                @renderRecent()
                @renderRegionAppStack()
                return

            self = @
            @listenTo App.model.appList(), "change:state", ( model )->
                console.info "Dashboard Updated due to state changes in app list."
                if model.get("region") is self.region and @regionTab is "app"
                    @renderRegionAppStack()
                return

        render : () ->
            region_names = _.map constant.REGION_LABEL, ( name, id ) ->
                long:
                    id: id, name: name
                short:
                    id: id, name: constant.REGION_SHORT_LABEL[ id ]

            data =
                region_names: region_names

            $( this.el ).html @overview data

            @renderMapResult()
            @renderRecent()
            @renderRegionAppStack()
            null

        renderMapResult : ->
            regionsMap = {}
            for r in App.model.stackList().groupByRegion()
                regionsMap[ r.region ] = r
                r.stack = r.data.length
                r.app   = 0
            for r in App.model.appList().groupByRegion()
                if not regionsMap[ r.region ]
                    regionsMap[ r.region ] = r
                    r.stack = 0
                regionsMap[ r.region ].app = r.data.length

            $("#global-region-spot").html template_data.globalMap regionsMap
            null

        renderRecent : ->
            stacks = App.model.stackList().filterRecent(true)
            apps   = App.model.appList().filterRecent(true)

            if stacks.length > 5 then stacks.length = 5
            if apps.length > 5   then apps.length = 5

            $tabs = $("#global-region-status-widget").find(".global-region-status-tab")
            $tabs.eq(0).children("span").text apps.length
            $tabs.eq(1).children("span").text stacks.length

            $( '#global-region-recent-list' ).html template_data.recent { stacks:stacks, apps:apps }
            null

        renderRegionAppStack: () ->
            attr = { apps:[], stacks:[], region : @region }
            attr[ @regionTab ] = true

            region = @region
            if region isnt "global"
                filter = (f)-> f.get("region") is region && f.isExisting()
                tojson = {thumbnail:true}

                attr.stacks = App.model.stackList().filter(filter).map (m)-> m.toJSON(tojson)
                attr.apps   = App.model.appList().filter(filter).map   (m)-> m.toJSON(tojson)

            $('#region-app-stack-wrap').html( template_data.region_app_stack(attr) )

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

            if @region is region then return
            @region = region

            $( '#region-switch').find( 'span' )
                .text( target.text() )
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
            $tgt = $(event.currentTarget)
            if $tgt.hasClass("on") then return
            $tgt.addClass("on").siblings().removeClass("on")
            $("#global-region-recent-list").children().hide().eq( $tgt.index() ).show()

        switchAppStack: ( event ) ->
            @regionTab = if $(event.currentTarget).hasClass("stack") then "stack" else "app"
            Helper.switchTab event, '#region-resource-tab li', '.region-resource-list'

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

            if App.user.hasCredential()
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
            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'NEW_STACK', null, $target.data( 'region' ), null

        gotoRegionFromMap : ( evt )->
            $tgt = $( evt.currentTarget )
            region = $( evt.currentTarget ).closest("li").attr("id")
            @gotoRegion( region )

            $("#region-resource-tab").children().eq( if $tgt.hasClass("app") then 0 else 1 ).click()
            return false

        gotoRegion: ( region ) ->
            if region.currentTarget
                region = region.currentTarget.id

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

        showCredential: () -> App.showSettings( App.showSettings.TAB.Credential )

        ############################################################################################


        openItem : (event) ->
            id = $(event.currentTarget).attr("data-id")
            if not id then return

            model = App.model.stackList().get(id)
            if model
                evt = "OPEN_STACK"
            else
                model = App.model.appList().get(id)
                if not model then return
                evt = "OPEN_APP"

            ide_event.trigger ide_event.OPEN_DESIGN_TAB, evt, model.get("name"), model.get("region"), id
            return

        deleteStack : (event) ->
            App.deleteStack $( event.currentTarget ).closest("li").attr("data-id")
            false

        duplicateStack : (event) ->
            App.duplicateStack $( event.currentTarget ).closest("li").attr("data-id")
            false

        startApp : ( event )->
            App.startApp $( event.currentTarget ).closest("li").attr("data-id")
            false

        stopApp : ( event )->
            App.stopApp $( event.currentTarget ).closest("li").attr("data-id")
            false

        terminateApp : ( event )->
            App.terminateApp $( event.currentTarget ).closest("li").attr("data-id")
            false

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

            if App.user.hasCredential()
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
            zone.on "dragenter", ()->
                console.log "dragenter"
                $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", true)
            zone.on "dragleave", ()->
                console.log "dragleave"
                $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", false)
            zone.on "dragover", ( evt )->
                dt = evt.originalEvent.dataTransfer
                if dt then dt.dropEffect = "copy"
                evt.stopPropagation()
                evt.preventDefault()
                null
            null

    }

    OverviewView
