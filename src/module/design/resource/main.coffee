####################################
#  Controller for design/resource module
####################################

define [ 'jquery', 'text!/module/design/resource/template.html', 'event' ], ( $, template, event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="resource-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#resource-panel'

        #load remote module1.js
        require [ './module/design/resource/view' ], ( View ) ->

            #view
            view       = new View()
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule