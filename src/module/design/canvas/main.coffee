####################################
#  Controller for design/canvas module
####################################

define [ 'jquery', 'text!/module/design/canvas/template.html', 'event' ], ( $, template, event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="canvas-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#canvas'

        #load remote module1.js
        require [ './module/design/canvas/view' ], ( View ) ->

            #view
            view       = new View()
            view.render( template )

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule