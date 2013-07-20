####################################
#  Controller for design/property/vpc module
####################################

define [ 'jquery',
         'text!/module/design/property/vpc/template.html',
         'event',
         'UI.notification',
         'UI.multiinputbox'
], ( $, template, ide_event ) ->

    #
    current_view = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-vpc-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( uid, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/vpc/view', './module/design/property/vpc/model' ], ( view, model ) ->

            #
            current_view  = view

            #view
            view.model = model
            view.render( model.getRenderData( uid ) )

            view.on "CHANGE_NAME", ( newName ) ->
                if not validateName newName
                    view.setName ( model.getName uid )
                else
                    model.setName uid, newName
                    # Update Canvas
                    MC.canvas.update uid, "text", "vpc_name", newName
                null

            view.on "CHANGE_CIDR", ( newCIDR ) ->
                if not validateCIDR newCIDR
                    view.setCIDR ( model.getCIDR uid )
                    notification 'error', "Must be a valid IPv4 CIDR block.", true
                else
                    model.setCIDR uid, newCIDR
                null

            null

        null

    validateName = ( name ) ->
        name && name.match /^[a-zA-Z0-9\-]+$/

    validateCIDR = ( cird ) ->
        cird && cird.match /^(\d{1,3}.){3}\d{1,3}\/\d\d$/

    unLoadModule = () ->
        current_view.off()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
