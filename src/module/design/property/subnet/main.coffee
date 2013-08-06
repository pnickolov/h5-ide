####################################
#  Controller for design/property/subnet module
####################################

define [ 'jquery',
         'text!/module/design/property/subnet/template.html',
         'text!/module/design/property/subnet/acl_template.html',
         'text!/module/design/property/subnet/app_template.html',
         'event'
], ( $, template, acl_template, app_template, ide_event ) ->
    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-subnet-tmpl">' + template + '</script>'
    acl_template = '<script type="text/x-handlebars-template" id="property-subnet-acl-tmpl">' + acl_template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-subnet-app-tmpl">' + app_template + '</script>'
    #load remote html template
    $( 'head' ).append( template ).append( acl_template ).append( app_template )

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP'
            loadAppModule uid
            return

        #
        require [ './module/design/property/subnet/view',
                  './module/design/property/subnet/model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            model.setId uid
            view.model = model

            ide_event.onLongListen ide_event.RETURN_SUBNET_PROPERTY_FROM_ACL, (mainModule) ->
                view.refreshACLList()
                # mainModule.unLoadModule()

            #render
            view.render()
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name

            view.on "CHANGE_NAME", ( change ) ->

                model.setName change.value
                # Sync the name to canvas
                MC.canvas.update uid, "text", "name", change.value

                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, change.value
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

    loadAppModule = ( uid )->
        require [ './module/design/property/subnet/app_view',
                  './module/design/property/subnet/app_model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            current_view  = view
            current_model = model

            #view
            view.model    = model

            view.on 'OPEN_ACL', ( acl_uid, subnet_uid ) ->

                ide_event.trigger ide_event.OPEN_ACL, subnet_uid, 0, acl_uid, null, null

            model.init uid
            view.render()
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name


    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        ide_event.offListen ide_event.RETURN_SUBNET_PROPERTY_FROM_ACL
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
