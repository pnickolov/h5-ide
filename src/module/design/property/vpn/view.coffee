#############################
#  View(UI logic) for design/property/vpn
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

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
            me = this
            console.log 'add ip'

            ips = []
            _.map $("#property-vpn-ips .input"), (target) -> ips.push target.value

            ori_ips = me.model.attributes

            console.log ips

            null

        removeIP : (event, target) ->
            ip = target.value

            console.log 'delete vpn ip ' + ip

            this.trigger 'VPN_DELETE_IP', ip

            null

    }

    view = new VPNView()

    return view
