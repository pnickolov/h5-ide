require [ 'jquery', 'domReady', 'MC',
    'text!/test/madeira_console/region/template.html',
    'text!/test/madeira_console/region/template_data.html',
    'event', 'constant', 'session_model', 'MC.ide.template'
], ( $, domReady, MC, region_tmpl, region_tmpl_data, ide_event, constant, session_model ) ->


    #private
    init = () ->

        #set MC.data
        MC.data = {}

        #global config data by region
        MC.data.config = {}

        #global cache for all ami
        MC.data.dict_ami = {}

        #global stack name list
        MC.data.stack_list = {}
        MC.data.stack_list[r] = [] for r in constant.REGION_KEYS
        #global app name list
        MC.data.app_list = {}
        MC.data.app_list[r] = [] for r in constant.REGION_KEYS

        #global resource data (Describe* return)
        MC.data.resource_list = {}
        MC.data.resource_list[r] = {} for r in constant.REGION_KEYS

        #set untitled
        MC.data.untitled = 0
        #set tab
        MC.tab  = {}


    #private
    MC.login = (event) ->

        event.preventDefault()

        username = $( '#login-user' ).val()
        password = $( '#login-password' ).val()

        #Email is empty
        if username is ''
            $( '.error-msg'     ).removeClass 'show'
            $( '.control-group' ).first().removeClass 'error'
            $( '#error-msg-2'   ).addClass 'show'
            $( '.control-group' ).first().addClass 'error'
            return false

        #invoke session.login api
        session_model.login {sender: this}, username, password

        #login return handler (dispatch from service/session/session_model)
        session_model.once 'SESSION_LOGIN_RETURN', ( forge_result ) ->

            if !forge_result.is_error
                #login succeed

                result = forge_result.resolved_data

                #set cookies
                $.cookie 'userid',      result.userid,      { expires: 3600 }
                $.cookie 'usercode',    result.usercode,    { expires: 3600 }
                $.cookie 'session_id',  result.session_id,  { expires: 3600 }
                $.cookie 'region_name', result.region_name, { expires: 3600 }
                $.cookie 'email',       result.email,       { expires: 3600 }
                $.cookie 'has_cred',    result.has_cred,    { expires: 3600 }

                $( '.error-msg'     ).removeClass 'show'
                $( '#error-msg-1'   ).removeClass 'show'

                #load
                loadModule()

                return true

            else
                #login failed
                #alert forge_result.error_message
                $( '.error-msg'     ).removeClass 'show'
                $( '.control-group' ).first().removeClass 'error'
                $( '#error-msg-1'   ).addClass 'show'

                return false


    #private
    loadModule = () ->

        MC.IDEcompile 'region', region_tmpl_data, {'.resource-tables': 'region-resource-tables-tmpl', '.unmanaged-resource-tables': 'region-unmanaged-resource-tables-tmpl', '.aws-status': 'aws-status-tmpl', '.vpc-attrs': 'vpc-attrs-tmpl', '.stat-app-count' : 'stat-app-count-tmpl', '.stat-stack-count' : 'stat-stack-count-tmpl', '.stat-app' : 'stat-app-tmpl', '.stat-stack' : 'stat-stack-tmpl' }


        console.log 'load madeira_console'
        #set MC.data.dashboard_type

        current_region = 'us-east-1'

        #load remote ./module/dashboard/region/view.js
        require [ '/test/madeira_console/region/view.js', '/test/madeira_console/region/model.js', 'UI.tooltip', 'UI.bubble', 'UI.modal', 'UI.table', 'UI.tablist' ], ( View, model ) ->

            console.log '------------ region view load ------------ '

            #view
            region_view        = new View()
            region_view.model  = model
            region_view.region = current_region
            region_view.render region_tmpl

            model.on 'change:vpc_attrs', () ->
                console.log 'dashboard_change:vpc_attrs'
                #model.get 'vpc_attrs'
                region_view.renderVPCAttrs()

            model.on 'change:unmanaged_list', () ->
                console.log 'dashboard_change:unmanaged_list'
                unmanaged_list = model.get 'unmanaged_list'
                region_view.renderUnmanagedRegionResource( unmanaged_list.time_stamp )

                null

            model.on 'change:status_list', () ->
                console.log 'dashboard_change:status_list'
                unmanaged_list = model.get 'status_list'
                region_view.renderAWSStatus()

                null

            #listen
            model.on 'change:cur_app_list', () ->
                console.log 'dashboard_region_change:cur_app_list'
                #model.get 'cur_app_list'
                region_view.renderRegionStatApp()

            model.on 'change:cur_stack_list', () ->
                console.log 'dashboard_region_change:cur_stack_list'
                #model.get 'cur_stack_list'
                region_view.renderRegionStatStack()
                region_view.checkCreateStack MC.data.supported_platforms

            model.on 'change:region_resource_list', () ->
                console.log 'dashboard_region_resource_list'
                #refresh view
                region_view.renderRegionResource()

            model.on 'change:region_resource', () ->
                console.log 'dashboard_region_resources'
                #refresh view
                region_view.renderRegionResource()

            model.on 'REGION_RESOURCE_CHANGED', ()->
                console.log 'region resource table render'
                region_view.renderRegionResource()

            region_view.on 'RETURN_OVERVIEW_TAB', () ->
                #set MC.data.dashboard_type
                MC.data.dashboard_type = 'OVERVIEW_TAB'
                #push event
                ide_event.trigger ide_event.RETURN_OVERVIEW_TAB, null
                return

            region_view.on 'RUN_APP_CLICK', (app_id) ->
                console.log 'dashboard_region_click:run_app'
                # call service
                model.runApp(current_region, app_id)
            region_view.on 'STOP_APP_CLICK', (app_id) ->
                console.log 'dashboard_region_click:stop_app'
                model.stopApp(current_region, app_id)
            region_view.on 'TERMINATE_APP_CLICK', (app_id) ->
                console.log 'dashboard_region_click:terminate_app'
                model.terminateApp(current_region, app_id)
            region_view.on 'DUPLICATE_STACK_CLICK', (stack_id, new_name) ->
                console.log 'dashboard_region_click:duplicate_stack'
                model.duplicateStack(current_region, stack_id, new_name)
            region_view.on 'DELETE_STACK_CLICK', (stack_id) ->
                console.log 'dashboard_region_click:delete_stack'
                model.deleteStack(current_region, stack_id)
            region_view.on 'REFRESH_REGION_BTN', () ->
                model.describeAWSResourcesService current_region

            model.describeAWSResourcesService current_region
            model.describeRegionAccountAttributesService current_region
            model.describeAWSStatusService current_region
            #model.getItemList 'app', current_region, overview_app
            #model.getItemList 'stack', current_region, overview_stack

            ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->

                overview_app = result

                console.log 'RESULT_APP_LIST'

                should_update_overview = true

                model.getItemList 'app', current_region, overview_app

                null

            ide_event.onLongListen 'RESULT_STACK_LIST', ( result ) ->

                overview_stack = result

                console.log 'RESULT_STACK_LIST'

                model.getItemList 'stack', current_region, overview_stack

                null



    #public
    domReady () ->

        init()

        $( '#login-btn' ).removeAttr 'disabled'
        $( '#login-btn' ).addClass 'enabled'
        $( '#login-form' ).submit( MC.login )
