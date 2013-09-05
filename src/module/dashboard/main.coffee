####################################
#  Controller for dashboard module
####################################

define [ 'jquery',
    'text!./module/dashboard/overview/template.html',
    'text!./module/dashboard/region/template.html',
    'text!./module/dashboard/overview/template_data.html',
    'text!./module/dashboard/region/template_data.html',
    'event',
    'MC'
], ( $, overview_tmpl, region_tmpl, overview_tmpl_data, region_tmpl_data, ide_event, MC ) ->

    current_region = null
    overview_app    = null
    overview_stack  = null
    should_update_overview = false

    # private
    loadModule = () ->

        MC.IDEcompile 'overview', overview_tmpl_data, {'.overview-result' : 'overview-result-tmpl', '.global-list' : 'global-list-tmpl', '.region-app-stack' : 'region-app-stack-tmpl','.region-resource' : 'region-resource-tmpl', '.recent' : 'recent-tmpl', '.recent-launched-app' : 'recent-launched-app-tmpl', '.recent-stopped-app' : 'recent-stopped-app-tmpl', '.loading': 'loading-tmpl' }
        MC.IDEcompile 'region', region_tmpl_data, {'.resource-tables': 'region-resource-tables-tmpl', '.unmanaged-resource-tables': 'region-unmanaged-resource-tables-tmpl', '.aws-status': 'aws-status-tmpl', '.vpc-attrs': 'vpc-attrs-tmpl', '.stat-app-count' : 'stat-app-count-tmpl', '.stat-stack-count' : 'stat-stack-count-tmpl', '.stat-app' : 'stat-app-tmpl', '.stat-stack' : 'stat-stack-tmpl' }

        #set MC.data.dashboard_type default
        MC.data.dashboard_type = 'OVERVIEW_TAB'
        #load remote ./module/dashboard/overview/view.js
        require [ './module/dashboard/overview/view', './module/dashboard/overview/model', 'constant', 'UI.tooltip' ], ( View, model, constant ) ->
            region_view = null
            #view
            view       = new View()
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
                #
                if region_view then region_view.checkCreateStack MC.data.supported_platforms

                # display refresh time
                (->
                    loadTime = $.now() / 1000
                    setInterval ( ->
                        view.updateLoadTime MC.intervalDate( loadTime )
                        console.log 'timeupdate', loadTime
                    ), 60001
                )()

            model.on 'change:recent_edited_stacks', () ->
                console.log 'dashboard_change:recent_eidted_stacks'
                #model.get 'recent_edited_stacks'
                view.renderRecent()

            model.on 'change:recent_launched_apps', () ->
                console.log 'dashboard_change:recent_launched_apps'
                #model.get 'recent_launched_apps'
                view.renderRecentLaunchedApp()

            model.on 'change:recent_stoped_apps', () ->
                console.log 'dashboard_change:recent_stoped_apps'
                #model.get 'recent_stoped_apps'
                view.renderRecentStoppedApp()

            # global view
            model.on 'change:global_list', () ->
                view.renderGlobalList()

            # region view
            model.on 'change:cur_region_resource', () ->
                view.renderRegionResource()

            # update aws credential
            ide_event.onLongListen ide_event.UPDATE_AWS_CREDENTIAL, () ->
                console.log 'dashboard_region:UPDATE_AWS_CREDENTIAL'

                if $.cookie('has_cred') is 'true'   # update aws resource
                    model.describeAWSResourcesService

                else    # set aws credential
                    console.log 'show credential setting dialog'
                    require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            #model
            model.describeAccountAttributesService()

            model.describeAWSResourcesService()

            ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->
                console.log 'overview RESULT_APP_LIST'

                overview_app = result

                if overview_stack
                    model.updateMap model, overview_app, overview_stack

                model.updateRecentList( model, result, 'recent_launched_apps' )
                model.updateRecentList( model, result, 'recent_stoped_apps' )

                if should_update_overview
                    view.renderMapResult()

                model.getItemList 'app', current_region, overview_app

                null

            ide_event.onLongListen 'RESULT_STACK_LIST', ( result ) ->
                console.log 'overview RESULT_STACK_LIST'

                overview_stack = result

                if overview_app
                    model.updateMap model, overview_app, overview_stack
                else
                    ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->
                        overview_app = result
                        model.updateMap model, overview_app, overview_stack

                model.updateRecentList( model, result, 'recent_edited_stacks' )

                if should_update_overview
                    view.renderMapResult()

                model.getItemList 'stack', current_region, overview_stack

                null

            ide_event.onLongListen ide_event.NAVIGATION_TO_DASHBOARD_REGION, ( result ) ->

                console.log 'NAVIGATION_TO_DASHBOARD_REGION'
                view.trigger 'RETURN_REGION_TAB', result

                null

            # switch region tab
            view.on 'SWITCH_REGION', ( region ) ->
                current_region = region
                model.loadResource region
                #model.describeAWSStatusService region
                @model.getItemList 'app', region, overview_app
                @model.getItemList 'stack', region, overview_stack

            model.on 'change:cur_app_list', () ->
                view.renderRegionAppStack()
                model.describeAWSResourcesService()

            model.on 'change:cur_stack_list', () ->
                view.renderRegionAppStack()

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
















    ####################### reserve for test ##############################################
            #listen
            view.on 'RETURN_REGION_TAB', ( region ) ->
                console.log 'RETURN_REGION_TAB'
                #set MC.data.dashboard_type

                current_region = region

                MC.data.dashboard_type = 'REGION_TAB'
                #push event
                ide_event.trigger ide_event.RETURN_REGION_TAB, constant.REGION_SHORT_LABEL[ region ]

                if region_view isnt null

                    region_view.region = current_region

                    region_view.model.resetData()
                    region_view.model.describeAWSResourcesService region
                    region_view.model.describeRegionAccountAttributesService region
                    region_view.model.describeAWSStatusService region
                    region_view.model.getItemList 'app', region, overview_app
                    region_view.model.getItemList 'stack', region, overview_stack
                    return

                #load remote ./module/dashboard/region/view.js
                require [ './module/dashboard/region/view', './module/dashboard/region/model', 'UI.tooltip', 'UI.bubble', 'UI.modal', 'UI.table', 'UI.tablist' ], ( View, model ) ->

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


                    model.on 'UPDATE_REGION_APP_LIST', () ->
                        console.log 'dashboard_region_change:cur_app_list'
                        #model.get 'cur_app_list'
                        region_view.renderRegionStatApp()

                    #model.on 'change:cur_stack_list', () ->
                    model.on 'UPDATE_REGION_STACK_LIST', () ->
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
                    ide_event.onLongListen ide_event.UPDATE_REGION_RESOURCE, (region) ->
                        console.log 'dashboard_region:UPDATE_REGION_RESOURCE'

                        if $.cookie('has_cred') is 'true'
                            model.describeAWSResourcesService region
                            model.describeRegionAccountAttributesService region
                            model.describeAWSStatusService region
                        else
                            model.resetData()

                    ide_event.onLongListen ide_event.UPDATE_AWS_CREDENTIAL, () ->
                        console.log 'dashboard_region:UPDATE_AWS_CREDENTIAL'

                        if $.cookie('has_cred') is 'true'
                            model.describeAWSResourcesService current_region
                            model.describeRegionAccountAttributesService current_region
                            model.describeAWSStatusService current_region
                        else
                            model.resetData()

                    model.describeAWSResourcesService current_region
                    model.describeRegionAccountAttributesService current_region
                    model.describeAWSStatusService current_region
                    model.getItemList 'app', current_region, overview_app
                    model.getItemList 'stack', current_region, overview_stack

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

                    ide_event.onLongListen ide_event.UPDATE_REGION_THUMBNAIL, ( url ) ->
                        console.log 'UPDATE_REGION_THUMBNAIL'
                        region_view.updateThumbnail url if region_view
                        null

                    ide_event.onLongListen ide_event.UPDATE_TAB_ICON, ( flag, app_id ) ->
                        console.log 'UPDATE_TAB_ICON'

                        model.updateAppList flag, app_id

    ####################### reserve for test ##############################################

    unLoadModule = () ->

    # public
    loadModule   : loadModule
    unLoadModule : unLoadModule
