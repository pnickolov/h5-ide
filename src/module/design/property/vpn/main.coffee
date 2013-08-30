####################################
#  Controller for design/property/vpn module
####################################

define [ 'jquery',
         'text!/module/design/property/vpn/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-vpn-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( line_option, type, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/vpn/view', './module/design/property/vpn/model' ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model
            #render
            model.getVPN line_option
            view.render()
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, "vpn:#{model.attributes.vpn_detail.cgw_name}"

            view.on 'VPN_IP_UPDATE', (ipset) ->
                model.updateIps ipset

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
