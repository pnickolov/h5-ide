####################################
#  Controller for design/property/cgw module
####################################

define [ 'jquery',
         'text!/module/design/property/cgw/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-cgw-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( uid, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/cgw/view', './module/design/property/cgw/model' ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            model.setId uid
            view.model = model
            #render
            view.render()

            view.on "CHANGE_NAME", ( change ) ->
                model.setName change.value
                # Sync the name to canvas
                MC.canvas.update uid, "text", "name", change.value
                null

            view.on "CHANGE_IP", ( change ) ->
                model.setIP change.value
                null

            view.on "CHANGE_BGP", ( change ) ->
                change.done( model.setBGP change.value )
                null

            null


    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
