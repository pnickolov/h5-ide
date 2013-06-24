####################################
#  Controller for dashboard module
####################################

define [ 'jquery', 'text!/module/dashboard/overview/template.html', 'text!/module/dashboard/region/template.html', 'event', 'MC' ], ( $, overview_tmpl, region_tmpl, ide_event, MC ) ->


    current_region = null

    app_list        = null
    stack_list      = null
    overview_app    = null
    overview_stack  = null
    should_update_overview = false

    #private
    loadModule = () ->
        #add handlebars script
        overview_tmpl = '<script type="text/x-handlebars-template" id="overview-tmpl">' + overview_tmpl + '</script>'
        #load remote html ovverview_tmpl
        $( overview_tmpl ).appendTo 'head'

        #add handlebars script
        overview_tmpl = '<script type="text/x-handlebars-template" id="region-tmpl">' + region_tmpl + '</script>'
        #load remote html ovverview_tmpl
        $( overview_tmpl ).appendTo 'head'

        #set MC.data.dashboard_type default
        MC.data.dashboard_type = 'OVERVIEW_TAB'

        #load remote ./module/dashboard/overview/view.js
        require [ './module/dashboard/overview/view', './module/dashboard/overview/model', 'constant', 'UI.tooltip' ], ( View, model, constant ) ->

            console.log '------------ overview view load ------------ '

            #
            region_view = null

            #view
            view       = new View()
            view.model = model

            model.on 'change:result_list', () ->
                console.log 'dashboard_change:result_list'
                #push event
                model.get 'result_list'
                #refresh view
                view.render()

            model.on 'change:region_empty_list', () ->
                console.log 'dashboard_change:region_empty'
                #push event
                model.get 'region_empty_list'
                #refresh view
                view.render()

            model.on 'change:region_classic_list', () ->
                console.log 'dashboard_region_classic_list'
                #push event
                model.get 'region_classic_list'
                #refresh view
                view.render()

            model.on 'change:resent_edited_stacks', () ->
                console.log 'dashboard_change:resent_eidted_stacks'
                model.get 'resent_edited_stacks'
                view.render()

            model.on 'change:resent_launched_apps', () ->
                console.log 'dashboard_change:resent_launched_apps'
                model.get 'resent_launched_apps'
                view.render()

            model.on 'change:resent_stoped_apps', () ->
                console.log 'dashboard_change:resent_stoped_apps'
                model.get 'resent_stoped_apps'
                view.render()

            model.on 'change:app_list', () ->
                console.log 'dashboard_change:app_list'
                app_list = model.get 'app_list'
                null

            model.on 'change:stack_list', () ->
                console.log 'dashboard_change:stack_list'
                stack_list = model.get 'stack_list'
                null

            #model
            model.resultListListener()
            model.emptyListListener()
            model.describeAccountAttributesService()

            ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->
                console.log 'overview RESULT_APP_LIST'

                overview_app = result

                if overview_stack
                    model.updateMap model, overview_app, overview_stack

                model.updateRecentList( model, result, 'recent_launched_apps' )
                model.updateRecentList( model, result, 'recent_stoped_apps' )

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

                null

            ide_event.onLongListen ide_event.NAVIGATION_TO_DASHBOARD_REGION, ( result ) ->

                console.log 'NAVIGATION_TO_DASHBOARD_REGION'
                view.trigger 'RETURN_REGION_TAB', result

                null

            #listen
            view.on 'RETURN_REGION_TAB', ( region ) ->
                console.log 'RETURN_REGION_TAB'
                #set MC.data.dashboard_type

                current_region = region

                MC.data.dashboard_type = 'REGION_TAB'
                #push event
                ide_event.trigger ide_event.RETURN_REGION_TAB, null

                current_app = null
                # get current region's apps/stacks
                _.map app_list, (value) ->
                    if region == value.region_name
                        current_app = value.items
                    null

                current_stack = null
                if stack_list && stack_list.length > 0
                    _.map stack_list, (value) ->
                        if region == value.region_name
                            current_stack = value.items
                        null
                else
                    _.map overview_stack, (value) ->
                        if value.region_name_group && region is value.region_name_group[0].region
                            current_stack = value.region_name_group
                        null

                if region_view isnt null
                    region_view.model.resetData()
                    region_view.model.describeAWSResourcesService region
                    region_view.model.describeRegionAccountAttributesService region
                    region_view.model.describeAWSStatusService region
                    region_view.model.getItemList 'app', current_app
                    region_view.model.getItemList 'stack', current_stack
                    return

                #load remote ./module/dashboard/region/view.js
                require [ './module/dashboard/region/view', './module/dashboard/region/model', 'UI.tooltip', 'UI.bubble', 'UI.modal', 'UI.table', 'UI.tablist' ], ( View, model ) ->

                    console.log '------------ region view load ------------ '

                    #view
                    region_view        = new View()
                    region_view.model  = model
                    region_view.region = region

                    model.on 'change:vpc_attrs', () ->
                        console.log 'dashboard_change:vpc_attrs'
                        model.get 'vpc_attrs'
                        region_view.render()

                    model.on 'change:unmanaged_list', () ->
                        console.log 'dashboard_change:unmanaged_list'
                        unmanaged_list = model.get 'unmanaged_list'
                        region_view.render( unmanaged_list.time_stamp )

                    model.on 'change:status_list', () ->
                        console.log 'dashboard_change:status_list'
                        unmanaged_list = model.get 'status_list'
                        region_view.render()

                    #listen
                    model.on 'change:cur_app_list', () ->
                        console.log 'dashboard_region_change:cur_app_list'
                        model.get 'cur_app_list'
                        region_view.render()

                    model.on 'change:cur_stack_list', () ->
                        console.log 'dashboard_region_change:cur_stack_list'
                        model.get 'cur_stack_list'
                        region_view.render()

                    model.on 'change:region_resource_list', () ->
                        console.log 'dashboard_region_resource_list'
                        #push event
                        model.get 'region_resource_list'
                        #refresh view
                        region_view.render()

                    model.on 'change:region_resource', () ->
                        console.log 'dashboard_region_resources'
                        #push event
                        model.get 'region_resource'
                        #refresh view
                        region_view.render()

                    model.on 'REGION_RESOURCE_CHANGED', ()->

                        region_view.render()

                    region_view.on 'RETURN_OVERVIEW_TAB', () ->
                        #set MC.data.dashboard_type
                        MC.data.dashboard_type = 'OVERVIEW_TAB'
                        #push event
                        if should_update_overview
                            view.model.updateMap view.model, overview_app, overview_stack
                            view.model.updateRecentList( view.model, overview_app, 'recent_launched_apps' )
                            view.model.updateRecentList( view.model, overview_app, 'recent_stoped_apps' )
                            view.model.updateRecentList( view.model, overview_stack.result, 'recent_edited_stacks' )
                            should_update_overview = false
                            view.render()
                        ide_event.trigger ide_event.RETURN_OVERVIEW_TAB, null
                        return

                    region_view.on 'RUN_APP_CLICK', (app_id) ->
                        console.log 'dashboard_region_click:run_app'
                        # call service
                        model.runApp(region, app_id)
                    region_view.on 'STOP_APP_CLICK', (app_id) ->
                        console.log 'dashboard_region_click:stop_app'
                        model.stopApp(region, app_id)
                    region_view.on 'TERMINATE_APP_CLICK', (app_id) ->
                        console.log 'dashboard_region_click:terminate_app'
                        model.terminateApp(region, app_id)
                    region_view.on 'DUPLICATE_STACK_CLICK', (stack_id, new_name) ->
                        console.log 'dashboard_region_click:duplicate_stack'
                        model.duplicateStack(region, stack_id, new_name)
                    region_view.on 'DELETE_STACK_CLICK', (stack_id) ->
                        console.log 'dashboard_region_click:delete_stack'
                        model.deleteStack(region, stack_id)
                    region_view.on 'REFRESH_REGION_BTN', () ->
                        model.describeAWSResourcesService region

                    model.describeAWSResourcesService region
                    model.describeRegionAccountAttributesService region
                    model.describeAWSStatusService region
                    model.getItemList 'app', current_app
                    model.getItemList 'stack', current_stack

                    ide_event.onLongListen 'RESULT_APP_LIST', ( result ) ->

                        overview_app = result
                        should_update_overview = true

                        # get current region's apps
                        item_list = regions.region_name_group for regions in result when constant.REGION_LABEL[ current_region ] == regions.region_group

                        model.getItemList('app', item_list)

                        null

                    ide_event.onLongListen 'RESULT_STACK_LIST', ( result ) ->

                        overview_stack = result
                        should_update_overview = true

                        console.log 'RESULT_STACK_LIST'

                        # get current region's stacks
                        item_list = regions.region_name_group for regions in result when constant.REGION_LABEL[ current_region ] == regions.region_group

                        model.getItemList('stack', item_list)

                        null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule