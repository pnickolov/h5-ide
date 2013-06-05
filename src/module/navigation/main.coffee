####################################
#  Controller for navigation module
####################################

define [ 'jquery', 'text!/module/navigation/template.html', '/module/navigation/model.js' ], ( $, template, model ) ->

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
            model.on 'change:app_list', ( event ) ->
                console.log 'change:app_list'
                view.render()

            model.on 'change:stack_list', ( event ) ->
                console.log 'change:stack_list'
                view.render()

            model.on 'change:region_list', ( event ) ->
                console.log 'change:region_list'
                view.render()

            #model
            model.appListService()
            model.stackListService()
            model.describeRegionsService()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule