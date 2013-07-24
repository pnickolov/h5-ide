####################################
#  Controller for design/property/elb module
####################################

define [ 'jquery',
         'event'
], ( $, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #private
    loadModule = ( uid, current_main, tab_type ) ->
        console.log 'elb main, tab_type = ' + tab_type

        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP' then view_type = 'app_view' else view_type = 'view'

        #
        require [ './module/design/property/elb/' + view_type,

                  './module/design/property/elb/model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            view.model    = model

            #event
            if tab_type is 'OPEN_APP'
                #app view to do
            else
                view.on 'ELB_NAME_CHANGED', ( value ) ->
                    view.model.setELBName uid, value

                view.on 'SCHEME_SELECT_CHANGED', ( value ) ->
                    view.model.setScheme uid, value

                view.on 'HEALTH_PROTOCOL_SELECTED', ( value ) ->
                    view.model.setHealthProtocol uid, value

                view.on 'HEALTH_PORT_CHANGED', ( value ) ->
                    view.model.setHealthPort uid, value

                view.on 'HEALTH_PATH_CHANGED', ( value ) ->
                    view.model.setHealthPath uid, value

                view.on 'HEALTH_INTERVAL_CHANGED', ( value ) ->
                    view.model.setHealthInterval uid, value

                view.on 'HEALTH_TIMEOUT_CHANGED', ( value ) ->
                    view.model.setHealthTimeout uid, value

                view.on 'UNHEALTHY_SLIDER_CHANGE', ( value ) ->
                    view.model.setHealthUnhealth uid, value

                view.on 'HEALTHY_SLIDER_CHANGE', ( value ) ->
                    view.model.setHealthHealth uid, value

                view.on 'LISTENER_ITEM_CHANGE', ( value ) ->
                    view.model.setListenerAry uid, value

                view.on 'LISTENER_CERT_CHANGED', ( value ) ->
                    view.model.setListenerCert uid, value

                view.on 'REFRESH_CERT_PANEL_DATA', ( value ) ->
                    currentCert = view.model.getCurrentCert uid
                    currentCert && view.refreshCertPanel currentCert

                view.on 'REMOVE_AZ_FROM_ELB', ( value ) ->
                    view.model.removeAZFromELB uid, value

                view.on 'ADD_AZ_TO_ELB', ( value ) ->
                    view.model.addAZToELB uid, value

            #model
            model.init uid
            
            #render
            view.render model.attributes

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule