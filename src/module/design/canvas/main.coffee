####################################
#  Controller for design/canvas module
####################################

define [ 'jquery', 'text!/module/design/canvas/template.html', 'event' ], ( $, template, ide_event ) ->

    #private
    loadModule = () ->

        #load remote module1.js
        require [ './module/design/canvas/view' ], ( View ) ->

            #view
            view       = new View()
            view.render template

            #listen RELOAD_RESOURCE
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name ) ->
                console.log 'canvas:RELOAD_RESOURCE'
                #temp
                require [ 'canvas_layout' ], ( canvas_layout ) ->
                    canvas_layout.listen()
                    canvas_layout.ready()
                    canvas_layout.connect()
                null


    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule