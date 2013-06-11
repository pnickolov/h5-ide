####################################
#  Controller for navigation module
####################################

define [ 'jquery', 'text!/module/navigation/template.html', '/module/navigation/model.js', 'event' ], ( $, template, model, ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="navigation-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo 'head'

        #load remote /module/navigation/view.js
        require [ './module/navigation/view', 'UI.tooltip', 'UI.scrollbar', 'UI.accordion', 'hoverIntent' ], ( View ) ->

            #view
            view       = new View()
            view.model = model
            
            #listen vo set change event
            model.on 'change:app_list', () ->
                console.log 'change:app_list'
                #push event
                ide_event.trigger ide_event.RESULT_APP_LIST, model.get 'app_list'
                #refresh view
                view.render()

            model.on 'change:stack_list', () ->
                console.log 'change:stack_list'
                #push event
                ide_event.trigger ide_event.RESULT_STACK_LIST, model.get 'stack_list'
                #refresh view
                view.render()

            model.on 'change:region_list', () ->
                console.log 'change:region_list'
                #push event
                ide_event.trigger ide_event.RESULT_REGION_LIST, model.get 'region_list'
                #refresh view
                view.render()

            model.on 'change:region_empty_list', () ->
                console.log 'change:region_empty_list'
                #push event
                ide_event.trigger ide_event.RESULT_EMPTY_REGION_LIST, model.get 'region_empty_list'
                #refresh view
                view.render()

            #model
            model.appListService()
            model.stackListService()
            model.describeRegionsService()
            model.regionEmptyList()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule