####################################
#  Controller for dashboard module
####################################

define [ 'jquery', 'text!/module/dashboard/overview/template.html', 'text!/module/dashboard/region/template.html', 'event', 'MC' ], ( $, overview_tmpl, region_tmpl, ide_event, MC ) ->


    current_region = null

    app_list   = null
    stack_list = null

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
        require [ './module/dashboard/overview/view', './module/dashboard/overview/model', 'UI.tooltip' ], ( View, model ) ->

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

            #listen
            view.on 'RETURN_REGION_TAB', ( region ) ->
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
                _.map stack_list, (value) ->
                    if region == value.region_name
                        current_stack = value.items
                    null

                #load remote ./module/dashboard/region/view.js
                require [ './module/dashboard/region/view', './module/dashboard/region/model', 'UI.tooltip', 'UI.bubble', 'UI.modal' ], ( View, model ) ->

                    #view
                    view       = new View()
                    view.model = model
                    #listen
                    model.describeAWSResourcesService(region)

                    model.on 'change:cur_app_list', () ->
                        console.log 'dashboard_region_change:cur_app_list'
                        model.get 'cur_app_list'
                        view.render()

                    model.on 'change:cur_stack_list', () ->
                        console.log 'dashboard_region_change:cur_stack_list'
                        model.get 'cur_stack_list'
                        view.render()

                    view.on 'RETURN_OVERVIEW_TAB', () ->
                        #set MC.data.dashboard_type
                        MC.data.dashboard_type = 'OVERVIEW_TAB'
                        #push event
                        ide_event.trigger ide_event.RETURN_OVERVIEW_TAB, null
                        #render
                        view.render()

                    model.getItemList('app', current_app)
                    model.getItemList('stack', current_stack)

                    view.on 'RUN_APP_CLICK', (app_id) ->
                        console.log 'dashboard_region_click:run_app'
                        # call service
                        model.runApp(app_id)
                    view.on 'STOP_APP_CLICK', (app_id) ->
                        console.log 'dashboard_region_click:stop_app'
                        model.stopApp(app_id)
                    view.on 'TERMINATE_APP_CLICK', (app_id) ->
                        console.log 'dashboard_region_click:terminate_app'
                        model.terminateApp(app_id)
                    view.on 'DUPLICATE_STACK_CLICK', (stack_id, new_name) ->
                        console.log 'dashboard_region_click:duplicate_stack'
                        model.duplicateStack(stack_id, new_name)
                    view.on 'DELETE_STACK_CLICK', (stack_id) ->
                        console.log 'dashboard_region_click:delete_stack'
                        model.deleteStack(stack_id)

                    model.resultListListener()



    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule