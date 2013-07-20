#############################
#  View Mode for design/property/vpn
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    VPNModel = Backbone.Model.extend {

        defaults :
            'vpn_detail'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getVPN : (line_option) ->
            me = this

            vpn_detail = {}

            _.map line_option, (node) ->

                if node.port == 'cgw-vpn'

                    cgw = MC.canvas_data.component[ node.uid ]

                    vpn_detail.cgw_name = cgw.name
                    vpn_detail.is_dynamic = if cgw.BgpAsn then true else false
                    vpn_detail.ips = []
                    vpn_detail.is_del = if vpn_detail.ips.length > 1 then true else false

                null
                
            me.set 'vpn_detail', vpn_detail

    }

    model = new VPNModel()

    return model