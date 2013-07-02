####################################
#  Controller for design/canvas module
####################################

define [ 'jquery', 'text!/module/design/canvas/template.html', 'event' ], ( $, template, event ) ->

    #private
    loadModule = () ->

        #load remote module1.js
        require [ './module/design/canvas/view' ], ( View ) ->

            #view
            view       = new View()
            view.render template
            #temp
            require [ 'canvas-layout' ], ( canvas_layout ) ->
                canvas_layout.ready()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule