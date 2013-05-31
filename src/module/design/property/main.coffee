####################################
#  Controller for design/property module
####################################

define [ 'jquery', 'text!/module/design/property/template.html', 'event' ], ( $, template, event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#property-panel'

        #load remote module1.js
        require [ './module/design/property/view' ], ( View ) ->

            #view
            view       = new View()
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule