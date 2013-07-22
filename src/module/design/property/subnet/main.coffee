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

            model.setId uid
            view.model = model

            #render
            view.render formatData model.attributes

            view.on "CHANGE_NAME", ( change ) ->
                # TODO : Validate Name
                model.setName change.value
                change.accept()

                # Sync the name to canvas
                MC.canvas.update uid, "text", "name", change.value
                null

            view.on "CHANGE_ACL", ( change ) ->
                model.setACL change.value
                change.accept()
                null

            view.on "CHANGE_CIDR", ( change ) ->
                # TODO : Validate CIDR
                model.setCIDR change.value
                change.accept()
                null

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    formatData = ( data ) ->
        # Should not touch model's data

        data = $.extend true, {}, data
        CIDR = data.CIDR.split "."
        data.CIDRPrefix = CIDR[0] + "." + CIDR[1] + "."
        data.CIDR = CIDR[2] + "." + CIDR[3]

        data

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
