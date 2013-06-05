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

        #model
        model.appListService()
        model.on 'complete', () ->
            #load remote /module/navigation/view.js
            require [ './module/navigation/view', 'UI.tooltip', 'UI.scrollbar', 'UI.accordion', 'hoverIntent' ], ( View ) ->

                #view
                view       = new View()
                view.model = model
                view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule