####################################
#  Controller for dashboard module
####################################

define [ 'jquery', 'text!/module/dashboard/overview/template.html', 'text!/module/dashboard/region/template.html', 'event', 'MC' ], ( $, overview_tmpl, region_tmpl, ide_event, MC ) ->

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

            #model
            model.resultListListener()
            model.emptyListListener()
            model.describeAccountAttributesService()

            #listen
            view.on 'RETURN_REGION_TAB', () ->
                #set MC.data.dashboard_type
                MC.data.dashboard_type = 'REGION_TAB'
                #push event
                ide_event.trigger ide_event.RETURN_REGION_TAB, null
                #render
                view.render()

        #load remote ./module/dashboard/region/view.js
        require [ './module/dashboard/region/view', './module/dashboard/region/model', 'UI.tooltip', 'UI.bubble' ], ( View, model ) ->

            #view
            view       = new View()
            view.model = model
            #listen
            view.on 'RETURN_OVERVIEW_TAB', () ->
                #set MC.data.dashboard_type
                MC.data.dashboard_type = 'OVERVIEW_TAB'
                #push event
                ide_event.trigger ide_event.RETURN_OVERVIEW_TAB, null
            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule