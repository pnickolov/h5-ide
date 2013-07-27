####################################
#  Controller for design/property/sglist module
####################################

define [ 'jquery',
         'text!/module/design/property/sglist/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view     = null
    #current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-sg-list-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( model, isStackView ) ->

        #
        require [ './module/design/property/sglist/view' ], ( view ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            #current_model = model

            #view
            view.model    = model

            #render
            view.render isStackView

    unLoadModule = () ->
        current_view.off()
        #current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
