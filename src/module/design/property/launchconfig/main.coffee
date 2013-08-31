####################################
#  Controller for design/property/launchconfig module
####################################

define [ 'jquery',
         'text!./template.html',
         'text!./app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view     = null
    current_model    = null
    current_sub_main = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-launchconfig-tmpl">' + template + '</script>'
    app_template = "<script type='text/x-handlebars-template' id='property-launchconfig-app-tmpl'>#{app_template}</script>"
    #load remote html template
    $( 'head' ).append( template ).append( app_template )

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        #
        MC.data.current_sub_main = current_main

        if tab_type is 'OPEN_APP'
            loadAppModule uid, current_main
            return

        require [ './module/design/property/launchconfig/view',
                  './module/design/property/launchconfig/model',
                  './module/design/property/sglist/main'
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_sub_main = sglist_main

            #
            current_view  = view
            current_model = model
            #
            model.getUID  uid
            model.getName()
            model.getInstanceType()
            model.getAmiDisp()
            model.getAmi()
            model.getComponent()
            model.getKerPair()
            # model.getSgDisp()
            model.getCheckBox()

            #view
            view.model    = model
            view.render()

            ide_event.trigger ide_event.RELOAD_PROPERTY
            # Update property title
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name

            model.listen()

            sglist_main.loadModule model

            view.on "NAME_CHANGE", ( value ) ->
                model.set 'name', value
                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, value

    loadAppModule = ( uid ) ->
        require [ './module/design/property/launchconfig/app_view',
                  './module/design/property/launchconfig/model',
                  './module/design/property/sglist/main'
        ], ( view, model, sglist_main ) ->
             #
            if current_view then view.delegateEvents view.events

            #
            current_sub_main = sglist_main

            #
            current_view  = view
            current_model = model

            model.getAppLaunch uid
            #view
            view.model    = model
            view.render()

            # Update property title
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name

            model.listen()

            sglist_main.loadModule model



    unLoadModule = () ->
        if !current_view then return
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #
        current_sub_main.unLoadModule()
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
