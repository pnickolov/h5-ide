####################################
#  Controller for design/property/subnet module
####################################

define [ 'jquery',
         'text!/module/design/property/subnet/template.html',
         'text!/module/design/property/subnet/acl_template.html',
         'event'
], ( $, template, acl_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-subnet-tmpl">' + template + '</script>'
    acl_template = '<script type="text/x-handlebars-template" id="property-subnet-acl-tmpl">' + acl_template + '</script>'
    #load remote html template
    $( 'head' ).append template
    $( 'head' ).append acl_template

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
            view.render()

            view.on "CHANGE_NAME", ( change ) ->

                model.setName change.value
                # Sync the name to canvas
                MC.canvas.update uid, "text", "name", change.value
                null

            view.on "CHANGE_CIDR", ( change ) ->
                error model.setCIDR change.value
                change.done error
                null

            view.on "CHANGE_ACL", ( change ) ->
                model.setACL change.value
                null

            view.on "SET_NEW_ACL", ( acl_uid ) ->
                model.setACL acl_uid
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
