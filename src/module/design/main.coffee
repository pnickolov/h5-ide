####################################
#  Controller for design module
####################################

define [ 'jquery', 'text!/module/design/template.html' ], ( $, template ) ->

    #private
    loadModule = () ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="design-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#tab-content-stack01'

        #load remote design.js
        require [ './module/design/view', 'event' ], ( View, ide_event ) ->

            #view
            view       = new View()

            #listen event
            view.once 'DESIGN_COMPLETE', () ->
                console.log 'view:DESIGN_COMPLETE'
                ide_event.trigger ide_event.DESIGN_COMPLETE
                wrap()

            #render
            view.render template

    #private
    unLoadModule = () ->
        #view.remove()

    #private
    wrap = () ->

        require [ 'resource', 'property', 'toolbar', 'canvas' ], ( resource, property, toolbar, canvas ) ->
            #load remote design/resource
            resource.loadModule()

            #load remote design/property
            property.loadModule()

            #load remote design/canvas
            canvas.loadModule()

            #load remote design/toolbar
            toolbar.loadModule()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule