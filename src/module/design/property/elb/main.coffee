####################################
#  Controller for design/property/elb module
####################################

define [ 'jquery',
         'text!/module/design/property/elb/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-elb-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/elb/view',
                  './module/design/property/elb/model'
        ], ( view, model ) ->

            #view
            view.model    = model

            #event
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

            #model
            model.initELB uid
            attributes = {
                component : MC.canvas_data.component[uid],
                health_detail: model.get('health_detail'),
                elb_detail: model.get('elb_detail')
            }
            
            #render
            view.render( attributes )

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule