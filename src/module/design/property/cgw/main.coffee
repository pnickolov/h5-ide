####################################
#  Controller for design/property/cgw module
####################################

define [ 'jquery',
         'text!/module/design/property/cgw/template.html',
         'text!/module/design/property/cgw/app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template     = '<script type="text/x-handlebars-template" id="property-cgw-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-cgw-app-tmpl">' + app_template + '</script>'
    #load remote html template
    $( 'head' ).append( template ).append( app_template )

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        console.log 'tab_type = ' + tab_type

        #
        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP'
            loadAppModule uid
            return

        #
        require [ './module/design/property/cgw/view',
                  './module/design/property/cgw/model'
        ], ( view, model ) ->

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

            # Set title
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name


            view.on "CHANGE_NAME", ( change ) ->
                model.setName change.value
                # Sync the name to canvas
                MC.canvas.update uid, "text", "name", change.value

                # Set title
                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, change.value
                null

            view.on "CHANGE_IP", ( change ) ->
                model.setIP change.value
                null

            view.on "CHANGE_BGP", ( change ) ->
                change.done( model.setBGP change.value )
                null

            null

    loadAppModule = (uid) ->
        require [ './module/design/property/cgw/app_view',
                  './module/design/property/cgw/app_model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.init uid
            view.render()

            # Set title
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, "vpn:#{model.attributes.name}"



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
