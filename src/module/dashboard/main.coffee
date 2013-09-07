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

            ide_event.onLongListen ide_event.SWITCH_MAIN, () ->
                if MC.data.supported_platforms and MC.data.supported_platforms.length
                    model.set 'supported_platforms', true
                    view.enableCreateStack()

            # update aws credential
            ide_event.onLongListen ide_event.UPDATE_AWS_CREDENTIAL, () ->
                console.log 'dashboard_region:UPDATE_AWS_CREDENTIAL'

                if $.cookie('has_cred') isnt 'true'   # update aws resource
                #     model.describeAWSResourcesService

                # else    # set aws credential
                    console.log 'show credential setting dialog'
                    require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

                model.describeAWSResourcesService

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
                view.renderRegionAppStack( 'app' )
                model.describeAWSResourcesService()

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

    unLoadModule = () ->

    # public
    loadModule   : loadModule
    unLoadModule : unLoadModule
