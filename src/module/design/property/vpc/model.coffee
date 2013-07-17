#############################
#  View Mode for design/property/vpc
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    VPCModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getRenderData : ( uid ) ->
            component = MC.canvas_data.component[ uid ]

            uid            : uid
            component      : component
            dnsSupport     : component.resource.EnableDnsSupport   == "true"
            dnsHosts       : component.resource.EnableDnsHostnames == "true"
            defaultTenancy : component.resource.InstanceTenancy    == "default"

        getName : ( uid ) ->
            MC.canvas_data.component[ uid ].name

        getCIDR : ( uid ) ->
            MC.canvas_data.component[ uid ].resource.CidrBlock

        setTenancy : ( uid, tenancy ) ->
            component = MC.canvas_data.component[ uid ]
            component.resource.InstanceTenancy = tenancy

            console.log "UID:", uid, "InstanceTenancy:", component.resource.InstanceTenancy

        setDnsSupport : ( uid, enable ) ->
            component = MC.canvas_data.component[ uid ]
            component.resource.EnableDnsSupport = if enable then "true" else "false"
            console.log "UID:", uid, "VPC Resource:", component.resource

        setDnsHosts : ( uid, enable ) ->
            component = MC.canvas_data.component[ uid ]
            component.resource.EnableDnsHostnames = if enable then "true" else "false"
            console.log "UID:", uid, "VPC Resource:", component.resource
    }

    model = new VPCModel()

    return model
