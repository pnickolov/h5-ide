#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'MC', 'event',
         "Design",
         'i18n!nls/lang.js',
         './stack_template',
         './app_template',
         './appview_template',
         "component/exporter/JsonExporter",
         "component/exporter/Download",
         'constant'
         'backbone', 'jquery', 'handlebars',
         'UI.selectbox', 'UI.notification',
         "UI.tabbar"
], ( MC, ide_event, Design, lang, stack_tmpl, app_tmpl, appview_tmpl, JsonExporter, download, constant ) ->

    ToolbarView = Backbone.View.extend {

        el         : document

        events     :
            #line style
            'click #toolbar-straight'       : 'clickLineStyleStraight'
            'click #toolbar-elbow'          : 'clickLineStyleElbow'
            'click #toolbar-bezier-q'       : 'clickLineStyleBezierQ'
            'click #toolbar-bezier-qt'      : 'clickLineStyleBezierQT'

            'click #toolbar-run'            : 'clickRunIcon'
            'click .icon-save'              : 'clickSaveIcon'
            'click #toolbar-duplicate'      : 'clickDuplicateIcon'
            'click #toolbar-delete'         : 'clickDeleteIcon'
            'click #toolbar-new'            : 'clickNewStackIcon'
            'click .icon-zoom-in'           : 'clickZoomInIcon'
            'click .icon-zoom-out'          : 'clickZoomOutIcon'
            'click .icon-undo'              : 'clickUndoIcon'
            'click .icon-redo'              : 'clickRedoIcon'
            'click #toolbar-export-png'     : 'clickExportPngIcon'
            'click #toolbar-export-json'    : 'clickExportJSONIcon'
            'click #toolbar-stop-app'       : 'clickStopApp'
            'click #toolbar-start-app'      : 'clickStartApp'
            'click #toolbar-terminate-app'  : 'clickTerminateApp'
            'click #btn-app-refresh'        : 'clickRefreshApp'
            'click #toolbar-convert-cf'     : 'clickConvertCloudFormation'

            #app edit
            'click #toolbar-edit-app'        : 'clickEditApp'
            'click #toolbar-save-edit-app'   : 'clickSaveEditApp'
            'click #toolbar-cancel-edit-app' : 'clickCancelEditApp'

            'click .toolbar-visual-ops-switch' : 'opsOptionChanged'
            #'click #apply-visops'             : 'openExperimentalVisops'

        # when flag = 0 not invoke opsState
        # when flag = 1 invoke opsState
        render   : ( type, flag ) ->
            console.log 'toolbar render'

            #set line style
            lines =
                icon : ''
                is_style0: null
                is_style1: null
                is_style2: null
                is_style3: null

            #restore line style
            switch $canvas.lineStyle()

                when 0
                    lines.is_style0 = true
                    lines.icon = 'icon-straight'

                when 1
                    lines.is_style1 = true
                    lines.icon = 'icon-elbow'

                when 2
                    lines.is_style2 = true
                    lines.icon = 'icon-bezier-q'

                when 3
                    lines.is_style3 = true
                    lines.icon = 'icon-bezier-qt'

            this.model.attributes.lines = lines

            # platform is 'classis' stack or app
            data = MC.common.other.canvasData.data( true )
            # appview
            if Tabbar.current is 'appview'
                $( '#main-toolbar' ).html appview_tmpl this.model.attributes

            # type include 'app' | 'stack'
            else if type in [ 'app', 'OPEN_APP' ]
                $( '#main-toolbar' ).html app_tmpl this.model.attributes
            else
                $( '#main-toolbar' ).html stack_tmpl this.model.attributes

            if type and flag is 1
                # vispos state
                @opsState()

            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE
            #
            null

        listen     : ->
            # app update event
            $( document.body ).on 'click', '#confirm-update-app', this, @appUpdating
            # cancel to app model
            $( document.body ).on 'click', '#return-app-confirm', this, @appedit2App
            # export to png download button click
            $( document.body ).on 'click', '.modal-footer #btn-confirm', this, () -> modal.close()

            # experimentalVisops
            #$( document.body ).on 'click', '#experimental-visops-confirm', this, @experimentalVisopsConfirm
            #$( document.body ).on 'click', '#experimental-visops-cancel', this, () -> modal.close()

        reRender   : ( type ) ->
            console.log 're-toolbar render'
            if $.trim( $( '#main-toolbar' ).html() ) is 'loading...'
                #
                if type is 'stack'
                    $( '#main-toolbar' ).html stack_tmpl this.model.attributes
                else
                    $( '#main-toolbar' ).html app_tmpl this.model.attributes

        clickRunIcon : ( event ) ->
            console.log 'clickRunIcon'

            # when disabled not click
            if $('#toolbar-run').hasClass( 'disabled' )
                modal.close()
                return

            me = this
            event.preventDefault()
            # check credential
            if false
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else

                # set app name
                $('.modal-input-value').val MC.common.other.canvasData.get 'name'

                # set total fee
                cost = Design.instance().getCost()
                $('#label-total-fee').find("b").text("$#{cost.totalFee}")

                # insert ta component
                require [ 'component/trustedadvisor/main' ], ( trustedadvisor_main ) ->
                    trustedadvisor_main.loadModule 'stack'

                # click logic
                $('#btn-confirm').on 'click', this, (event) ->

                    console.log 'clickRunIcon'

                    #check app name
                    app_name = $('.modal-input-value').val()

                    if not app_name
                        notification 'warning', lang.ide.PROP_MSG_WARN_NO_APP_NAME
                        return

                    if not MC.validate 'awsName', app_name
                        notification 'warning', lang.ide.PROP_MSG_WARN_INVALID_APP_NAME
                        return

                    # get process tab name
                    process_tab_name = 'process-' + MC.common.other.canvasData.get( 'region' ) + '-' + app_name

                    # delete F5 old process
                    obj = MC.common.other.getProcess process_tab_name
                    if obj and obj.flag_list and obj.flag_list.is_failed is true and obj.flag_list.flag is 'RUN_STACK'

                        # delete MC.process
                        MC.common.other.deleteProcess process_tab_name

                        # close tab if exist
                        ide_event.trigger ide_event.CLOSE_DESIGN_TAB, process_tab_name

                    # repeat with app list or tab name(some run failed app tabs)
                    if (not MC.aws.aws.checkAppName app_name) or (_.contains(_.keys(MC.process), process_tab_name))
                        notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_APP_NAME
                        return false

                    # disable button
                    $('#btn-confirm').attr 'disabled', true
                    $('.modal-header .modal-close').hide()
                    $('#run-stack-cancel').attr 'disabled', true

                    # push SAVE_STACK event
                    #ide_event.trigger ide_event.SAVE_STACK, MC.common.other.canvasData.data()
                    event.data.model.syncSaveStack MC.common.other.canvasData.get( 'region' ), MC.common.other.canvasData.data()

            null

        clickSaveIcon : ->
            console.log 'clickSaveIcon'

            # get name and id
            name = MC.common.other.canvasData.get 'name'
            id   = MC.common.other.canvasData.get 'id'

            if not name
                notification 'warning', lang.ide.PROP_MSG_WARN_NO_STACK_NAME

            else if name.indexOf(' ') >= 0
                notification 'warning', lang.ide.PROP_MSG_WARN_WHITE_SPACE

            else if not MC.aws.aws.checkStackName id, name

                #notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_STACK_NAME
                #show modal to re-input stack name
                template = MC.template.modalReinputStackName {
                    stack_name : name
                }

                # popup rename dialog
                modal template, false

                $('#rename-confirm').click () ->
                    new_name = $('#new-stack-name').val()
                    console.log 'save stack new name:' + new_name

                    if MC.aws.aws.checkStackName id, new_name

                        # close dialog
                        modal.close()

                        # set new name
                        MC.common.other.canvasData.set 'name', new_name

                        # push event
                        ide_event.trigger ide_event.SAVE_STACK, MC.common.other.canvasData.data()

                        true

            else

                # set new name
                MC.common.other.canvasData.set 'name', name

                # push event
                ide_event.trigger ide_event.SAVE_STACK, MC.common.other.canvasData.data()

            true

        clickDuplicateIcon : (event) ->

            # old design flow
            #name     = MC.canvas_data.name

            # new design flow
            name      = MC.common.other.canvasData.get 'name'

            # set default name
            new_name = MC.aws.aws.getDuplicateName(name)
            $('#modal-input-value').val(new_name)

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'toolbar duplicate stack'
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

                    # old design flow +++++++++++++++++++++++++++
                    #region  = MC.canvas_data.region
                    #id      = MC.canvas_data.id
                    #name    = MC.canvas_data.name

                    #ide_event.trigger ide_event.SAVE_STACK, MC.canvas_data

                    #setTimeout () ->
                    #    ide_event.trigger ide_event.DUPLICATE_STACK, MC.canvas_data.region, MC.canvas_data.id, new_name, MC.canvas_data.name
                    #, 500
                    # old design flow +++++++++++++++++++++++++++

                    # new design flow +++++++++++++++++++++++++++
                    ide_event.trigger ide_event.SAVE_STACK, MC.common.other.canvasData.data()

                    setTimeout () ->
                        region  = MC.common.other.canvasData.get 'region'
                        id      = MC.common.other.canvasData.get 'id'
                        name    = MC.common.other.canvasData.get 'name'
                        ide_event.trigger ide_event.DUPLICATE_STACK, region, id, new_name, name
                    , 500
                    # new design flow +++++++++++++++++++++++++++

            true

        clickDeleteIcon : ->
            me = this

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'clickDeleteIcon'
                modal.close()

                # old design flow
                #ide_event.trigger ide_event.DELETE_STACK, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name

                # new design flow
                region  = MC.common.other.canvasData.get 'region'
                id      = MC.common.other.canvasData.get 'id'
                name    = MC.common.other.canvasData.get 'name'
                ide_event.trigger ide_event.DELETE_STACK, region, id, name

        clickNewStackIcon : ->
            console.log 'clickNewStackIcon'

            # old design flow
            #ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'NEW_STACK', null, MC.canvas_data.region, null

            # new design flow
            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'NEW_STACK', null, MC.common.other.canvasData.get( 'region' ), null

        clickZoomInIcon : ( event ) ->
            console.log 'clickZoomInIcon'

            if $( event.currentTarget ).hasClass("disabled")
                return false

            this.trigger 'TOOLBAR_ZOOM_IN'

        clickZoomOutIcon : ( event )->
            console.log 'clickZoomOutIcon'

            if $( event.currentTarget ).hasClass("disabled")
                return false

            this.trigger 'TOOLBAR_ZOOM_OUT'

        clickUndoIcon : ->
            console.log 'clickUndoIcon'
            #temp
            ###
            require [ 'component/stackrun/main' ], ( stackrun_main ) ->
                stackrun_main.loadModule()
            ###

        clickRedoIcon : ->
            console.log 'clickRedoIcon'
            #temp
            ###
            require [ 'component/sgrule/main' ], ( sgrule_main ) ->
                sgrule_main.loadModule()
            ###

        clickExportPngIcon : ->
            modal MC.template.exportPNG { 'title' : 'Export PNG', 'confirm' : 'Download' , 'color' : 'blue' }, false

            # old design flow
            #$("#modal-wrap").data("uid", MC.canvas_data.id).find("#btn-confirm").hide()

            # new design flow
            $("#modal-wrap").data("uid", MC.common.other.canvasData.get( 'id' )).find("#btn-confirm").hide()
            $("#modal-wrap").find(".modal-body").css({padding:"12px 20px", "max-height":"420px",overflow:"hidden",background:"none"})

            this.trigger 'TOOLBAR_EXPORT_PNG_CLICK'
            null


        clickExportJSONIcon : ->
            design   = Design.instance()
            username = App.user.get('username')
            date     = MC.dateFormat(new Date(), "yyyy-MM-dd")
            name     = [design.get("name"), username, date].join("-")

            data = JsonExporter.exportJson Design.instance().serialize(), name + ".json"
            if data
                # The browser doesn't support Blob. Fallback to show a dialog to
                # allow user to download the file.
                modal MC.template.exportJSON data
            null

        exportPNG : ( base64_image, uid, blob ) ->

            if $("#modal-wrap").data("uid") isnt uid
                return

            # new design flow
            name = MC.common.other.canvasData.get( 'name' )

            if not blob
                $("#modal-wrap").find("#btn-confirm").show().attr({
                    'href'     : base64_image

                    # old design flow
                    #'download' : MC.canvas_data.name + '.png'

                    # new design flow
                    'download' : name + '.png'
                })
            else
                $("#modal-wrap").find("#btn-confirm").show().click ()->

                    # old design flow
                    #download( blob, MC.canvas_data.name + ".png" )

                    # new design flow
                    download( blob, name + ".png" )

            $( '.modal-body' ).html( "<img style='max-height:100%;display:inline-block' src='#{base64_image}' />" ).css({
                "background":"none"
                "text-align":"center"
            })

            _.delay ()->
                modal.position()
            , 50
            null

        #request cloudformation
        clickConvertCloudFormation : ->
            modal MC.template.exportCloudFormation()
            #change export_cloudformation param stack_id to json, so no need save stack
            @trigger "CONVERT_CLOUDFORMATION"
            null

        #save cloudformation
        saveCloudFormation : ( name ) ->
            me = this

            try
                # able
                aTag     = $('#tpl-download').removeClass 'disabled'
                cf_json  = @model.attributes.cf_data[name]
                fileName = "#{Design.instance().get('name')}.json"

                JsonExporter.genericExport aTag, cf_json, fileName

                $('#tpl-download').on 'click', (event) ->
                    modal.close()

            catch error
                notification 'error', lang.ide.TOOL_MSG_ERR_CONVERT_CLOUDFORMATION

        notify : (type, msg) ->
            notification type, msg

        clickStopApp : (event) ->
            me = this
            console.log 'click stop app'

            # check credential
            if false
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->

                    # old design flow
                    #ide_event.trigger ide_event.STOP_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name

                    # new design flow
                    region  = MC.common.other.canvasData.get 'region'
                    id      = MC.common.other.canvasData.get 'id'
                    name    = MC.common.other.canvasData.get 'name'
                    ide_event.trigger ide_event.STOP_APP, region, id, name

                    modal.close()

        clickStartApp : (event) ->
            me = this
            console.log 'click run app'

            # check credential
            if false
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->

                    # old design flow
                    #ide_event.trigger ide_event.START_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name

                    # new design flow
                    region  = MC.common.other.canvasData.get 'region'
                    id      = MC.common.other.canvasData.get 'id'
                    name    = MC.common.other.canvasData.get 'name'
                    ide_event.trigger ide_event.START_APP, region, id, name
                    modal.close()

        clickTerminateApp : (event) ->
            me = this

            console.log 'click terminate app'

            # check credential
            if false
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->

                    # old design flow
                    #ide_event.trigger ide_event.TERMINATE_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name

                    # new design flow
                    region  = MC.common.other.canvasData.get 'region'
                    id      = MC.common.other.canvasData.get 'id'
                    name    = MC.common.other.canvasData.get 'name'
                    ide_event.trigger ide_event.TERMINATE_APP, region, id, name

                    modal.close()


        clickLineStyleStraight  : (event) ->
            $canvas.lineStyle( 0 )
            null

        clickLineStyleElbow     : (event) ->
            $canvas.lineStyle( 1 )
            null

        clickLineStyleBezierQ   : (event) ->
            $canvas.lineStyle( 2 )
            null

        clickLineStyleBezierQT  : (event) ->
            $canvas.lineStyle( 3 )
            null

        clickRefreshApp         : (event) ->
            console.log 'toolbar clickRefreshApp'

            # old design flow
            #ide_event.trigger ide_event.UPDATE_APP_RESOURCE, MC.canvas_data.region, MC.canvas_data.id

            # new design flow
            ide_event.trigger ide_event.UPDATE_APP_RESOURCE, MC.common.other.canvasData.get( 'region' ), MC.common.other.canvasData.get( 'id' )

        #############################
        #  app edit
        #############################

        clickEditApp : ->
            console.log 'clickEditApp'

            # 1. Update MC.canvas.getState() to return 'appedit'
            ide_event.trigger ide_event.UPDATE_DESIGN_TAB_TYPE, MC.data.current_tab_id, 'appedit'

            # 2. Show Resource Panel and call canvas_layout.listen()
            ide_event.trigger ide_event.UPDATE_RESOURCE_STATE, 'show'

            # 3. Toggle Toolbar Button
            @trigger "UPDATE_APP", true

            MC.canvas.event.clearList()

            # 4. Create backup point

            # old design flow
            #MC.data.origin_canvas_data = $.extend true, {}, MC.canvas_data

            # new design flow
            MC.common.other.canvasData.origin MC.common.other.canvasData.data()

            # 5. set Design mode
            Design.instance().setMode Design.MODE.AppEdit

            # 6. Trigger OPEN_PROPERTY
            ide_event.trigger ide_event.OPEN_PROPERTY

            # 7. refresh view for App update
            Design.instance().refreshAppUpdate()

            null

        clickSaveEditApp : (event)->
            # 1. Send save request
            # check credential
            if false
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                result = @model.diff()

                if not result.isModified
                    # no changes and return to app modal
                    @appedit2App()
                    return

                else
                    modal MC.template.updateApp result

                    require [ 'component/trustedadvisor/main' ], ( trustedadvisor_main ) ->
                        trustedadvisor_main.loadModule 'stack'
            null

        clickCancelEditApp : ->
            console.log 'clickCancelEditApp'

            # old design flow +++++++++++++++++++++++++++
            #data        = $.extend true, {}, MC.canvas_data
            #origin_data = $.extend true, {}, MC.data.origin_canvas_data

            #if _.isEqual( data, origin_data )
            # old design flow +++++++++++++++++++++++++++

            # new design flow
            if not MC.common.other.canvasData.isModified()
                @appedit2App()
            else
                modal MC.template.cancelAppEdit2App(), true

            Design.instance().refreshAppUpdate()

            null

        appedit2App : ( target ) ->
            console.log 'appedit2App'

            # 1. Update MC.canvas.getState() to return 'app'
            ide_event.trigger ide_event.UPDATE_DESIGN_TAB_TYPE, MC.data.current_tab_id, 'app'

            # 2. Toggle Toolbar Button
            if target then me = target.data else me = this
            me.trigger "UPDATE_APP", false

            # 3. restore canvas to app model
            ide_event.trigger ide_event.RESTORE_CANVAS if target

            # 4. Close modal
            modal.close()

            # 6. delete MC.process and MC.data.process
            # delete MC.process[ MC.data.current_tab_id ]
            # delete MC.data.process[ MC.data.current_tab_id ]
            # MC.common.other.deleteProcess MC.data.current_tab_id

            # 5. Hide Resource Panel and call canvas_layout.listen()
            ide_event.trigger ide_event.UPDATE_RESOURCE_STATE, 'hide'

            # 6. Hide status bar validation
            ide_event.trigger ide_event.HIDE_STATUS_BAR

            # 7. set Design mode
            Design.instance().setMode Design.MODE.App

            # 8. Trigger OPEN_PROPERTY
            ide_event.trigger ide_event.OPEN_PROPERTY

            # 9. re push AwsResourceUpdated
            Design.instance().trigger Design.EVENT.AwsResourceUpdated

            null

        saveSuccess2App : ( tab_id, region ) ->
            console.log 'saveSuccess2App, tab_id = ' + tab_id + ', region = ' + region

            # 1. Update MC.canvas.getState() to return 'app'
            ide_event.trigger ide_event.UPDATE_DESIGN_TAB_TYPE, MC.data.current_tab_id, 'app'

            # 2. push refresh current tab
            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'RELOAD_APP', null, region, tab_id

            # 3. delete MC.process and MC.data.process
            MC.common.other.deleteProcess MC.data.current_tab_id

            null

        appUpdating : ( event ) ->
            console.log 'appUpdating'

            # 1. event.data.trigger 'xxxxx'

            # old design flow
            #event.data.trigger 'APP_UPDATING', MC.canvas_data

            # new design flow
            event.data.trigger 'APP_UPDATING', MC.common.other.canvasData.data()

            # 2. close modal
            modal.close()

            null

        opsState : ->
            console.log 'opsState'

            # set toolbar-visual-ops-switch and apply-visops
            $switchCheckbox = $ '#main-toolbar .toolbar-visual-ops-switch'
            $applyVisops    = $ '#apply-visops'

            # when new stack enable VisualOps else disabled
            if Tabbar.current is 'new'
                $switchCheckbox.addClass    'on'
                @model.setAgentEnable       true
            else
                $switchCheckbox.removeClass 'on'

            # when JSON 'agent' existing
            if Design and Design.instance()

                agentData = Design.instance().get 'agent'
                if agentData.enabled
                    $switchCheckbox.addClass    'on'
                else
                    $switchCheckbox.removeClass 'on'

        opsOptionChanged : (event) ->

            thatModel = @model
            $switchInput = $('#main-toolbar .toolbar-visual-ops-switch')
            $switchInput.toggleClass('on')
            value = $switchInput.hasClass('on')
            if value
                # $('#property-stack-ops-enable-info').show()
                notShowModal = thatModel.isAllInstanceNotHaveUserData()
                if not notShowModal
                    # if have any userdata in any instance
                    $switchInput.removeClass('on')
                    modal MC.template.modalStackAgentEnable({})
                    $('#modal-stack-agent-enable-confirm').one 'click', ()->
                        $switchInput.addClass('on')
                        thatModel.setAgentEnable(true)
                        ide_event.trigger ide_event.REFRESH_PROPERTY
                        modal.close()
                else
                    thatModel.setAgentEnable(true)
            else
                # $('#property-stack-ops-enable-info').hide()
                thatModel.setAgentEnable(false)

            ide_event.trigger ide_event.REFRESH_PROPERTY
    }

    return ToolbarView
