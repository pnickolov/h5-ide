####################################
#  Controller for design/property/vpc module
####################################

define [ 'jquery',
         'text!./template.html',
         'text!./app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-vpc-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-vpc-app-tmpl">' + app_template + '</script>'
    #load remote html template
    $( 'head' ).append( template ).append( app_template )

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP'
            loadAppModule uid
            return

        #
        require [ './module/design/property/vpc/view',
                  './module/design/property/vpc/model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            model.setId uid
            view.model = model
            view.render()
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.component.name

            view.on "CHANGE_NAME", ( newName ) ->
                model.setName newName
                # Update Canvas
                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, newName
                null
        null

    loadAppModule = ( uid ) ->
        require [ './module/design/property/vpc/app_view',
                  './module/design/property/vpc/app_model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.init uid
            view.render()
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name


    unLoadModule = () ->
        if !current_view then return
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
