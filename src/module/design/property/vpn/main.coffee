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
            renderVPNPanel = (line_option) ->
                model.getVPN line_option
                view.render()

            renderVPNPanel line_option

            view.on 'VPN_DELETE_IP', (ip) ->
                console.log "VPN_DELETE_IP:" + ip
                model.delIP ip

            view.on 'VPN_ADD_IP', (new_ip) ->
                console.log "VPN_ADD_IP:" + new_ip
                model.addIP new_ip

            model.on 'UPDATE_VPN_DATA', () ->
                console.log 'update vpn panel'
                view.render()

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule