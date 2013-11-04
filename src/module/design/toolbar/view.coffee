#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'MC', 'event',
         'i18n!nls/lang.js',
         'text!./stack_template.html',
         'text!./app_template.html',
         'UI.zeroclipboard',
         'constant'
         'backbone', 'jquery', 'handlebars',
         'UI.selectbox', 'UI.notification',
         "UI.tabbar"
], ( MC, ide_event, lang, stack_tmpl, app_tmpl, zeroclipboard, constant ) ->

    stack_tmpl = Handlebars.compile stack_tmpl
    app_tmpl   = Handlebars.compile app_tmpl

    ToolbarView = Backbone.View.extend {

        el         : document

        events     :
            ### env:dev ###
            #json
            'click #toolbar-jsondiff'       : 'clickOpenJSONDiff'
            'click #toolbar-jsonview'       : 'clickOpenJSONView'
            ### env:dev:end ###

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
            'click .icon-refresh'           : 'clickRefreshApp'
            'click #toolbar-convert-cf'     : 'clickConvertCloudFormation'

            #app edit
            'click #toolbar-edit-app'        : 'clickEditApp'
            'click #toolbar-save-edit-app'   : 'clickSaveEditApp'
            'click #toolbar-cancel-edit-app' : 'clickCancelEditApp'


        render   : ( type ) ->
            console.log 'toolbar render'

            #
            if type is 'app'
                $( '#main-toolbar' ).html app_tmpl this.model.attributes
            else
                $( '#main-toolbar' ).html stack_tmpl this.model.attributes

            #set line style
            lines =
                icon : ''
                is_style0: null
                is_style1: null
                is_style2: null
                is_style3: null

            #restore line style
            switch MC.canvas_property.LINE_STYLE

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



            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE
            #
            ### env:dev ###
            zeroclipboard.copy $( '#toolbar-jsoncopy' )
            ### env:dev:end ###

            # add by song
            if !$('#phantom-frame')[0]
                $( document.body ).append '<iframe id="phantom-frame" src="' + MC.SAVEPNG_URL + 'proxy.html" style="display:none;"></iframe>'

        reRender   : ( type ) ->
            console.log 're-toolbar render'
            if $.trim( $( '#main-toolbar' ).html() ) is 'loading...'
                #
                if type is 'stack'
                    $( '#main-toolbar' ).html stack_tmpl this.model.attributes
                else
                    $( '#main-toolbar' ).html app_tmpl this.model.attributes

        clickRunIcon : ->
            console.log 'clickRunIcon'
            me = this

            # check credential
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                # set total fee
                copy_data = $.extend( true, {}, MC.canvas_data )
                cost = MC.aws.aws.getCost MC.forge.stack.compactServerGroup(copy_data)
                $('#label-total-fee').find("b").text("$#{cost.total_fee}")

                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'clickRunIcon'

                    # disable button
                    $('#btn-confirm').attr 'disabled', true
                    $('.modal-close').attr 'disabled', true

                    app_name = $('.modal-input-value').val()

                    #check app name
                    if not app_name
                        notification 'warning', lang.ide.PROP_MSG_WARN_NO_APP_NAME
                        return

                    if not MC.validate 'awsName', app_name
                        notification 'warning', lang.ide.PROP_MSG_WARN_INVALID_APP_NAME
                        return

                    process_tab_name = 'process-' + MC.canvas_data.region + '-' + app_name
                    # repeat with app list or tab name(some run failed app tabs)
                    if (not MC.aws.aws.checkAppName app_name) or (_.contains(_.keys(MC.process), process_tab_name))
                        notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_APP_NAME
                        return

                    #modal.close()

                    # # check change and save stack
                    # ori_data = MC.canvas_property.original_json
                    # new_data = JSON.stringify( MC.canvas_data )
                    # id = MC.canvas_data.id
                    # if ori_data != new_data or id.indexOf('stack-') isnt 0
                        #ide_event.trigger ide_event.SAVE_STACK, MC.canvas.layout.save()
                    ide_event.trigger ide_event.SAVE_STACK, MC.canvas_data

                    # hold on 0.5 second for data update
                    # setTimeout () ->
                    #     me.trigger 'TOOLBAR_RUN_CLICK', app_name, MC.canvas_data
                    #     MC.data.app_list[MC.canvas_data.region].push app_name
                    # , 500

            true

        clickSaveIcon : ->
            console.log 'clickSaveIcon'

            name = MC.canvas_data.name
            id = MC.canvas_data.id

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

                modal template, false
                $('#rename-confirm').click () ->
                    new_name = $('#new-stack-name').val()
                    console.log 'save stack new name:' + new_name

                    if MC.aws.aws.checkStackName id, new_name
                        modal.close()

                        MC.canvas_data.name = new_name

                        # #expand components
                        # MC.canvas_data = MC.forge.stack.expandServerGroup MC.canvas_data
                        # #save stack
                        # ide_event.trigger ide_event.SAVE_STACK, MC.canvas.layout.save()
                        # #compact and update canvas
                        # MC.canvas_data = MC.forge.stack.compactServerGroup json_data

                        ide_event.trigger ide_event.SAVE_STACK, MC.canvas_data

                        true

            else
                MC.canvas_data.name = name

                # #expand components
                # MC.canvas_data = MC.forge.stack.expandServerGroup MC.canvas_data
                # #save stack
                # ide_event.trigger ide_event.SAVE_STACK, MC.canvas.layout.save()
                # #compact and update canvas
                # MC.canvas_data = MC.forge.stack.compactServerGroup MC.canvas_data

                ide_event.trigger ide_event.SAVE_STACK, MC.canvas_data

            true

        clickDuplicateIcon : (event) ->
            name     = MC.canvas_data.name

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

                    region  = MC.canvas_data.region
                    id      = MC.canvas_data.id
                    name    = MC.canvas_data.name

                    # check change and save stack
                    # ori_data = MC.canvas_property.original_json
                    # new_data = JSON.stringify( MC.canvas.layout.save() )
                    # if ori_data != new_data or id.indexOf('stack-') isnt 0
                    #     #ide_event.trigger ide_event.SAVE_STACK, MC.canvas.layout.save()
                    ide_event.trigger ide_event.SAVE_STACK, MC.canvas_data

                    setTimeout () ->
                        ide_event.trigger ide_event.DUPLICATE_STACK, MC.canvas_data.region, MC.canvas_data.id, new_name, MC.canvas_data.name
                    , 500

            true

        clickDeleteIcon : ->
            me = this

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'clickDeleteIcon'
                modal.close()

                ide_event.trigger ide_event.DELETE_STACK, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name

        clickNewStackIcon : ->
            console.log 'clickNewStackIcon'
            ide_event.trigger ide_event.ADD_STACK_TAB, MC.canvas_data.region

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
            console.log 'clickExportPngIcon'
            this.trigger 'TOOLBAR_EXPORT_PNG_CLICK', MC.canvas_data

        clickExportJSONIcon : ->
            file_content = JSON.stringify MC.canvas.layout.save()
            #this.trigger 'TOOLBAR_EXPORT_MENU_CLICK'
            $( '#btn-confirm' ).attr {
                'href'      : "data://text/plain;, " + file_content,
                'download'  : MC.canvas_data.name + '.json',
            }
            $( '#json-content' ).val file_content

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'clickExportJSONIcon'
                    modal.close()

        exportPNG : ( base64_image ) ->
            console.log 'exportPNG'
            #$( 'body' ).html '<img src="data:image/png;base64,' + base64_image + '" />'
            modal MC.template.exportpng {"title":"Export PNG", "confirm":"Download", "color":"blue" }, false
            if base64_image
                $( '.modal-body' ).html '<img src="data:image/png;base64,' + base64_image + '" />'
            $( '#btn-confirm' ).attr {
                'href'      : "data:image/png;base64, " + base64_image,
                'download'  : MC.canvas_data.name + '.png',
            }
            $('#btn-confirm').one 'click', { target : this }, () -> modal.close()

        #for debug
        clickOpenJSONDiff : ->
            #
            a = MC.canvas_property.original_json.split('"').join('\\"')
            b = JSON.stringify(MC.canvas_data).split('"').join('\\"')
            param = '{"d":{"a":"'+a+'","b":"'+b+'"}}'
            #
            window.open 'test/jsondiff/jsondiff.htm#' + encodeURIComponent(param)
            null

        clickOpenJSONView : ->
            window.open 'http://jsonviewer.stack.hu/'
            null

        #request cloudformation
        clickConvertCloudFormation : ->
            this.trigger 'CONVERT_CLOUDFORMATION'
            null

        #save cloudformation
        saveCloudFormation : ( cf_json ) ->

            try
                file_content = JSON.stringify cf_json
                $( '#tpl-download' ).attr {
                    'href'      : "data://application/json;," + file_content,
                    'download'  : MC.canvas_data.name + '.json',
                }
                $('#tpl-download').on 'click', { target : this }, (event) ->
                    console.log 'clickExportJSONIcon'
                    modal.close()
            catch error
                notification 'error', lang.ide.TOOL_MSG_ERR_CONVERT_CLOUDFORMATION

        notify : (type, msg) ->
            notification type, msg

        clickStopApp : (event) ->
            me = this
            console.log 'click stop app'

            # check credential
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    #me.trigger 'TOOLBAR_STOP_CLICK', MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    ide_event.trigger ide_event.STOP_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    modal.close()

        clickStartApp : (event) ->
            me = this
            console.log 'click run app'

            # check credential
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    #me.trigger 'TOOLBAR_START_CLICK', MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    ide_event.trigger ide_event.START_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    modal.close()

        clickTerminateApp : (event) ->
            me = this

            console.log 'click terminate app'

            # check credential
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    #me.trigger 'TOOLBAR_TERMINATE_CLICK', MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    ide_event.trigger ide_event.TERMINATE_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    modal.close()


        clickLineStyleStraight  : (event) ->
            MC.canvas_property.LINE_STYLE = 0
            ide_event.trigger ide_event.REDRAW_SG_LINE
            null

        clickLineStyleElbow     : (event) ->
            MC.canvas_property.LINE_STYLE = 1
            ide_event.trigger ide_event.REDRAW_SG_LINE
            null

        clickLineStyleBezierQ   : (event) ->
            MC.canvas_property.LINE_STYLE = 2
            ide_event.trigger ide_event.REDRAW_SG_LINE
            null

        clickLineStyleBezierQT  : (event) ->
            MC.canvas_property.LINE_STYLE = 3
            ide_event.trigger ide_event.REDRAW_SG_LINE
            null

        clickRefreshApp         : (event) ->
            console.log 'toolbar clickRefreshApp'
            ide_event.trigger ide_event.UPDATE_APP_RESOURCE, MC.canvas_data.region, MC.canvas_data.id, true

        clickEditApp : ->
            console.log 'clickEditApp'

            # 1. Update MC.canvas.getState() to return 'appedit'
            ide_event.trigger ide_event.UPDATE_TABBAR_TYPE, MC.data.current_tab_id, 'appedit'

            # 2. Show Resource Panel and call canvas_layout.listen()
            ide_event.trigger ide_event.UPDATE_RESOURCE_STATE, 'show'

            # 3. Toggle Toolbar Button
            @trigger "UPDATE_APP", true

            MC.aws.eni.markAutoAssginFalse()
            MC.canvas.event.clearList()

            # 4. Trigger OPEN_PROPERTY
            ide_event.trigger ide_event.OPEN_PROPERTY
            null

        clickSaveEditApp : (event)->
            me = this
            console.log 'click save app'

            # 1. Send save request
            # check credential
            if MC.forge.cookie.getCookieByName('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                # check changes
                diff_data = MC.aws.aws.getChanges(MC.canvas_data, MC.data.origin_canvas_data)

                if diff_data.isChanged

                    state = constant.APP_STATE.APP_STATE_STOPPED
                    platform = 'vpc'

                    # check app state
                    if MC.canvas_data.state is constant.APP_STATE.APP_STATE_RUNNING
                        state = constant.APP_STATE.APP_STATE_RUNNING
                    if MC.canvas_data.platform is "ec2-classic"
                        platform = 'ec2'

                    ## modal init
                    obj = { 'state':state, 'platform':platform, 'instance_list':diff_data.changes }
                    #obj.platform = 'vpc'
                    #obj.instance_list = []
                    #obj.state = constant.APP_STATE.APP_STATE_STOPPED
                    #
                    if obj.state is constant.APP_STATE.APP_STATE_STOPPED

                        modal MC.template.updateApp()
                        $( document.body ).one 'click', '#close-update-app', this, @_updateAndRun

                    else if obj.state is constant.APP_STATE.APP_STATE_RUNNING

                        if obj.instance_list.length is 0

                            modal MC.template.updateApp()
                            $( '.update-app-notice' ).empty()
                            $( document.body ).one 'click', '#close-update-app', this, @_updateAndRun

                        else

                            modal MC.template.restartInstance obj
                            if obj.platform is 'ec2'
                                $( '#instance-type' ).html lang.ide.TOOL_POP_BODY_APP_UPDATE_EC2
                            else if obj.platform is 'vpc'
                                $( '#instance-type' ).html lang.ide.TOOL_POP_BODY_APP_UPDATE_VPC
                            $( document.body ).one 'click', '#close-restart-instance', this, @_updateAndRun

                else
                    notification 'info', lang.ide.TOOL_MSG_INFO_NO_CHANGES
                    # no changes and return to app modal
                    @_return2App()

            # After success then do the clickCancelEditApp routine.
            null

        clickCancelEditApp : ->
            console.log 'clickCancelEditApp'

            data        = $.extend true, {}, MC.canvas_data
            origin_data = $.extend true, {}, MC.data.origin_canvas_data

            if _.isEqual( data, origin_data )
                @_return2App()
            else
                modal MC.template.cancelAppEdit2App(), true
                $( document.body ).one 'click', '#return-app-confirm', this, @_return2App
            null

        _return2App : ( target ) ->
            console.log '_return2App'

            # 1. Update MC.canvas.getState() to return 'app'
            ide_event.trigger ide_event.UPDATE_TABBAR_TYPE, MC.data.current_tab_id, 'app'

            # 2. Toggle Toolbar Button
            if target then me = target.data else me = this
            me.trigger "UPDATE_APP", false

            # 3. restore canvas to app model
            ide_event.trigger ide_event.RESTORE_CANVAS if target

            # 4. Trigger OPEN_PROPERTY
            ide_event.trigger ide_event.OPEN_PROPERTY

            # 5. Close modal
            modal.close()

            # 6. delete MC.process and MC.data.process
            delete MC.process[ MC.data.current_tab_id ]
            delete MC.data.process[ MC.data.current_tab_id ]

            # 7. Hide Resource Panel and call canvas_layout.listen()
            ide_event.trigger ide_event.UPDATE_RESOURCE_STATE, 'hide'

            null

        saveSuccess2App : ( tab_id, region ) ->
            console.log 'saveSuccess2App, tab_id = ' + tab_id + ', region = ' + region

            #if tab_id isnt MC.data.current_tab_id
            #    MC.data.process[ tab_id ].appedit2app = true if MC.data.process[ tab_id ]
            #    return

            # 1. Update MC.canvas.getState() to return 'app'
            ide_event.trigger ide_event.UPDATE_TABBAR_TYPE, MC.data.current_tab_id, 'app'

            # 2. push PROCESS_RUN_SUCCESS refresh current tab
            ide_event.trigger ide_event.PROCESS_RUN_SUCCESS, tab_id, region

            # 3. delete MC.process and MC.data.process
            delete MC.process[ MC.data.current_tab_id ]
            delete MC.data.process[ MC.data.current_tab_id ]

            null

        _updateAndRun : ( event ) ->
            console.log '_updateAndRun'
            # 1. event.data.trigger 'xxxxx'
            ide_event.trigger ide_event.SAVE_APP, MC.canvas_data

            # 2. TO-DO

            # 3. close modal
            modal.close()
            null

        _restartInstance : ( event ) ->
            console.log '_restartInstance'
            # 1. event.data.trigger 'xxxxx'

            # 2. TO-DO

            # 3. close modal
            modal.close()
            null

    }

    return ToolbarView