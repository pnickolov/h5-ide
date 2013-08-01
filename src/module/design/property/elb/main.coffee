####################################
#  Controller for design/property/elb module
####################################

define [ 'jquery',
         'text!/module/design/property/elb/template.html',
         'text!/module/design/property/elb/app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template     = '<script type="text/x-handlebars-template" id="property-elb-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-elb-app-tmpl">' + app_template + '</script>'
    #load remote html template
    $( 'head' ).append template
    $( 'head' ).append app_template

    #private
    loadModule = ( uid, current_main, tab_type ) ->
        console.log 'elb main, tab_type = ' + tab_type

        MC.data.current_sub_main = current_main


        if tab_type is 'OPEN_APP'
            loadAppModule uid
            return

        require [ './module/design/property/elb/view',
                  './module/design/property/elb/model',
                  './module/design/property/sglist/main'
                  ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            view.model    = model

            view.on 'ELB_NAME_CHANGED', ( value ) ->
                model.setELBName uid, value

            view.on 'SCHEME_SELECT_CHANGED', ( value ) ->
                model.setScheme uid, value

            view.on 'HEALTH_PROTOCOL_SELECTED', ( value ) ->
                model.setHealthProtocol uid, value

            view.on 'HEALTH_PORT_CHANGED', ( value ) ->
                model.setHealthPort uid, value

            view.on 'HEALTH_PATH_CHANGED', ( value ) ->
                model.setHealthPath uid, value

            view.on 'HEALTH_INTERVAL_CHANGED', ( value ) ->
                model.setHealthInterval uid, value

            view.on 'HEALTH_TIMEOUT_CHANGED', ( value ) ->
                model.setHealthTimeout uid, value

            view.on 'UNHEALTHY_SLIDER_CHANGE', ( value ) ->
                model.setHealthUnhealth uid, value

            view.on 'HEALTHY_SLIDER_CHANGE', ( value ) ->
                model.setHealthHealth uid, value

            view.on 'LISTENER_ITEM_CHANGE', ( value ) ->
                model.setListenerAry uid, value

            view.on 'LISTENER_CERT_CHANGED', ( value ) ->
                model.setListenerCert uid, value

            view.on 'REFRESH_CERT_PANEL_DATA', ( value ) ->
                currentCert = model.getCurrentCert uid
                currentCert && view.refreshCertPanel currentCert

            view.on 'REMOVE_AZ_FROM_ELB', ( value ) ->
                model.removeAZFromELB uid, value

            view.on 'ADD_AZ_TO_ELB', ( value ) ->
                model.addAZToELB uid, value

            #model
            model.init uid

            #render
            view.render model.attributes

            sglist_main.loadModule model

    loadAppModule = ( uid ) ->
            
        require [ './module/design/property/elb/app_view',
                  './module/design/property/elb/app_model',
                  './module/design/property/sglist/main'
        ], ( view, model, sglist_main ) ->

            #
            if current_view then view.delegateEvents view.events

            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.init uid
            view.render()

            sglist_main.loadModule model, true

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
