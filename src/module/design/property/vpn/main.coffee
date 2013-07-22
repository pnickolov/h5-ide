####################################
#  Controller for design/property/vpn module
####################################

define [ 'jquery',
         'text!/module/design/property/vpn/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( line_option, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-vpn-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/vpn/view', './module/design/property/vpn/model' ], ( view, model ) ->

            #view
            view.model    = model
            #render
            renderVPNPanel = (line_option) ->
                view.model.getVPN line_option
                view.render view.model.attributes

            renderVPNPanel line_option

            view.once 'VPN_DELETE_IP', (ip) ->
                console.log "VPN_DELETE_IP:" + ip
                model.delIP ip
                
            view.once 'VPN_ADD_IP', (new_ip) ->
                console.log "VPN_ADD_IP:" + new_ip
                model.addIP new_ip

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule