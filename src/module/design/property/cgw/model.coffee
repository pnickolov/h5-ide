#############################
#  View Mode for design/property/cgw
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    CGWModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getRenderData : ( uid ) ->
            cgw_component = MC.canvas_data.component[ uid ]

            uid  : uid
            name : cgw_component.name
            BGP  : cgw_component.resource.BgpAsn
            ip   : cgw_component.resource.IpAddress

        setName : ( uid, name ) ->
            MC.canvas_data.component[ uid ].name = name
            null

        setIP   : ( uid, ip ) ->
            MC.canvas_data.component[ uid ].resource.IpAddress = ip
            null

        setBGP  : ( uid, bgp ) ->
            MC.canvas_data.component[ uid ].resource.BgpAsn = bgp
            null
    }

    model = new CGWModel()

    return model
