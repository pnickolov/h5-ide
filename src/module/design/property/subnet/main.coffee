####################################
#  Controller for design/property/subnet module
####################################

define [ 'jquery',
         'text!/module/design/property/subnet/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-subnet-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( uid, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/subnet/view', './module/design/property/subnet/model' ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model
            #render
            view.render model.getRenderData uid

            view.on "CHANGE_NAME", ( uid, change ) ->
                # TODO : Validate Name
                model.setName uid, change.value
                change.accept()

                # Sync the name to canvas
                MC.canvas.update uid, "text", "name", change.value
                null

            view.on "CHANGE_ACL", ( uid, change ) ->
                model.setACL uid, change.value
                change.accept()
                null

            view.on "CHANGE_CIDR", ( uid, change ) ->
                # TODO : Validate CIDR
                model.setCIDR uid, change.value
                change.accept()
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
