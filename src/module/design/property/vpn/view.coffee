#############################
#  View(UI logic) for design/property/vpn
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.notification', 'UI.multiinputbox' ], ( ide_event ) ->

   VPNView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-vpn-tmpl' ).html()

        events   :
            "change #property-vpn-ips input"    : 'addIP'
            "REMOVE_ROW #property-vpn-ips"      : 'removeIP'

        render     : () ->
            console.log 'property:vpn render'

            $( '.property-details' ).html this.template this.model.attributes

        addIP : (event) ->
            ips = []
            $("#property-vpn-ips input").each ()->
                ips.push $(this).val()

            this.trigger 'VPN_IP_UPDATE', ips
            null

        removeIP : (event, ip) ->
            if not ip
                return

            ips = []
            $("#property-vpn-ips input").each ()->
                ips.push $(this).val()

            this.trigger 'VPN_IP_UPDATE', ips
            null

    }

    view = new VPNView()

    return view
