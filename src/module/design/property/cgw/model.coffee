#############################
#  View Mode for design/property/cgw
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    CGWModel = Backbone.Model.extend {

        defaults :
            uid  : null
            name : null
            BGP  : null
            ip   : null

        setId : ( uid ) ->
            cgw_component = MC.canvas_data.component[ uid ]

            obj =
                uid  : uid
                name : cgw_component.name
                BGP  : cgw_component.resource.BgpAsn
                ip   : cgw_component.resource.IpAddress

            this.set obj

            null

        setName : ( name ) ->
            MC.canvas_data.component[ this.attributes.uid ].name = name
            null

        setIP   : ( ip ) ->
            MC.canvas_data.component[ this.attributes.uid ].resource.IpAddress = ip
            null

        setBGP  : ( bgp ) ->

            if bgp

                if !bgp.match( /^\d+$/ )
                    error = "ASN must be a number"
                    return

                bgp = parseInt bgp, 10

                if bgp > 65534 || bgp < 1
                    error = "Must be between 1 and 65534"
                    return

                area = MC.canvas_data.region

                if bgp == 7224 && area == "us-east-1"
                    error = "ASN number 7224 is reserved in Virginia"
                    return

                if bgp == 9095 && area == "eu-west-1"
                    error = "ASN number 9059 is reserved in Ireland"
                    return

            if error
                return error
            else
                MC.canvas_data.component[ this.attributes.uid ].resource.BgpAsn = bgp

            null
    }

    model = new CGWModel()

    return model
