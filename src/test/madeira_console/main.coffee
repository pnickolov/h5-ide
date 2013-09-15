require [ 'jquery', 'domReady', 'MC',
    'text!./test/madeira_console/overview/template.html',
    'text!./test/madeira_console/overview/template_data.html',
    'event', 'constant', 'session_model', 'base_main', 'MC.ide.template', 'UI.scrollbar'
], ( $, domReady, MC, overview_tmpl, overview_tmpl_data, ide_event, constant, session_model, base_main ) ->


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


        MC.data.resources = {}

        MC.data.region_keys = {}

        _.extend this, base_main


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

                showLogined()

                return true

            else
                #login failed
                #alert forge_result.error_message
                $( '.error-msg'     ).removeClass 'show'
                $( '.control-group' ).first().removeClass 'error'
                $( '#error-msg-1'   ).addClass 'show'

                return false

    showLogined = ->
        $( '#login-state').html 'Login Succeed.'

    #private
    loadModule = () ->

        MC.IDEcompile 'overview', overview_tmpl_data,
            '.overview-result' : 'overview-result-tmpl'
            '.global-list' : 'global-list-tmpl'
            '.region-app-stack' : 'region-app-stack-tmpl'
            '.region-resource' : 'region-resource-tmpl'
            '.recent' : 'recent-tmpl'
            '.loading': 'loading-tmpl'

        #set MC.data.dashboard_type default
        MC.data.dashboard_type = 'OVERVIEW_TAB'
        #load remote ./module/dashboard/overview/view.js
        require [ '/test/madeira_console/overview/view.js', '/test/madeira_console/overview/model.js', 'constant', 'UI.tooltip' ], ( View, model, constant ) ->
            region_view = null
            #view
            #view       = new View()

            view = loadSuperModule loadModule, 'dashboard', View, null
            return if !view

            view.model = model
            view.render overview_tmpl

            #push DASHBOARD_COMPLETE
            ide_event.trigger ide_event.DASHBOARD_COMPLETE

            model.on 'change:result_list', () ->
                console.log 'dashboard_change:result_list'
                should_update_overview = true
                #refresh view
                view.renderMapResult()

            model.on 'change:region_classic_list', () ->
                console.log 'dashboard_region_classic_list'
                #set MC.data.supported_platforms
                MC.data.supported_platforms = model.get 'region_classic_list'
                #refresh view
                if MC.data.supported_platforms.length <= 0
                else
                    MC.data.is_loading_complete = true
                    ide_event.trigger ide_event.SWITCH_MAIN

                view.displayLoadTime()

            model.on 'change:recent_edited_stacks', () ->
                console.log 'dashboard_change:recent_eidted_stacks'
                #model.get 'recent_edited_stacks'
                view.renderRecent()

            model.on 'change:recent_launched_apps', () ->
                console.log 'dashboard_change:recent_launched_apps'
                #model.get 'recent_launched_apps'
                view.renderRecent()

            # global view
            model.on 'change:global_list', () ->
                view.renderGlobalList()

            # region view
            model.on 'change:cur_region_resource', () ->
                view.renderRegionResource()

            ide_event.onLongListen ide_event.SWITCH_MAIN, () ->
                if MC.data.supported_platforms and MC.data.supported_platforms.length
                    model.set 'supported_platforms', true
                    view.enableCreateStack()

            # update aws credential
            ide_event.onLongListen ide_event.UPDATE_AWS_CREDENTIAL, () ->
                console.log 'dashboard_region:UPDATE_AWS_CREDENTIAL'

                if MC.forge.cookie.getCookieByName('has_cred') is 'true'   # update aws resource
                    model.describeAWSResourcesService()
                else    # set aws credential
                    require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            ide_event.onLongListen ide_event.UPDATE_DASHBOARD, () ->
                console.log 'UPDATE_DASHBOARD'
                view.reloadResource() if view

            model.describeAWSResourcesService()

            #model
            #model.describeAccountAttributesService()

            #model.describeAWSResourcesService()

            ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->
                overview_app = result
                model.describeAWSResourcesService()

                model.updateMap model, overview_app, overview_stack
                model.updateRecentList( model, result, 'recent_launched_apps' )
                view.renderMapResult()
                model.getItemList 'app', current_region, overview_app

                null

            ide_event.onLongListen 'RESULT_STACK_LIST', ( result ) ->
                console.log 'overview RESULT_STACK_LIST'

                overview_stack = result

                model.updateMap model, overview_app, overview_stack
                model.updateRecentList( model, result, 'recent_edited_stacks' )
                view.renderMapResult()

                model.getItemList 'stack', current_region, overview_stack

                null

            ide_event.onLongListen ide_event.NAVIGATION_TO_DASHBOARD_REGION, ( result ) ->
                console.log 'NAVIGATION_TO_DASHBOARD_REGION'
                if result is 'global'
                    ide_event.trigger ide_event.RETURN_OVERVIEW_TAB
                else
                    view.trigger 'RETURN_REGION_TAB', result
                null

            # switch region tab
            view.on 'SWITCH_REGION', ( region ) ->
                current_region = region
                model.loadResource region
                #model.describeAWSStatusService region
                @model.getItemList 'app', region, overview_app
                @model.getItemList 'stack', region, overview_stack

            # reload resource
            view.on 'RELOAD_RESOURCE', ( region ) ->
                view.displayLoadTime()
                model.describeAWSResourcesService region

            model.on 'change:cur_app_list', () ->
                view.renderRegionAppStack( 'app' )

            ide_event.onLongListen ide_event.UPDATE_APP_RESOURCE, ( region, id ) ->
                model.describeAWSResourcesService region

            model.on 'UPDATE_REGION_APP_LIST', () ->
                view.renderRegionAppStack( 'app' )

            model.on 'change:cur_stack_list', () ->
                view.renderRegionAppStack( 'stack' )

            model.on 'REGION_RESOURCE_CHANGED', ( type, data )->
                console.log 'region resource table render'
                view.reRenderRegionPartial( type, data )

            # update region thumbnail
            ide_event.onLongListen ide_event.UPDATE_REGION_THUMBNAIL, ( url ) ->
                console.log 'UPDATE_REGION_THUMBNAIL'

                view.updateThumbnail url

                null

            #update region app state when pending
            ide_event.onLongListen ide_event.UPDATE_TAB_ICON, ( flag, app_id ) ->
                console.log 'UPDATE_TAB_ICON'

                model.updateAppList flag, app_id

                null





    #public
    domReady () ->

        init()


        $('#progress_wrap').hide()

        $( '#login-btn' ).removeAttr 'disabled'
        $( '#login-btn' ).addClass 'enabled'
        $( '#login-form' ).submit( MC.login )
