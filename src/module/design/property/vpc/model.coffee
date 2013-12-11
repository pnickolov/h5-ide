#############################
#  View Mode for design/property/vpc
#############################

define [ '../base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

    VPCModel = PropertyModel.extend {

        init : ( uid ) ->
            component = Design.instance().component( uid )

            dhcp_comp = component.get("dhcp")
            dhcp = $.extend {}, dhcp_comp.attributes

            dhcp.none    = dhcp_comp.isNone()
            dhcp.default = dhcp_comp.isDefault()
            dhcp.hasDhcp = (not dhcp.none) and (not dhcp.default)

            data = {
                uid            : uid
                dnsSupport     : component.get("dnsSupport")
                dnsHosts       : component.get("dnsHostnames")
                defaultTenancy : component.get("tenancy") is "default"
                name           : component.get("name")
                cidr           : component.get("cidr")
                dhcp           : dhcp
            }

            @set data
            null

        setCIDR : ( newCIDR ) ->
            uid = @get("uid")
            Design.instance().component( uid ).setCIDR( newCIDR )
            null

        setTenancy : ( tenancy ) ->
            uid = @get("uid")
            Design.instance().component( uid ).set("tenancy", tenancy)

            # TODO :
            ###################################
            # Set all AMI to be tenacy
            # for uid, comp of MC.canvas_data.component
            #     if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
            #         comp.resource.Placement.Tenancy = "dedicated"
            #         if comp.resource.InstanceType is 't1.micro'
            #             MC.canvas_data.component[uid].resource.InstanceType = 'm1.small'
            ###################################
            null

        setDnsSupport : ( enable ) ->
            uid = @get("uid")
            Design.instance().component( uid ).set("dnsSupport", enable)
            null

        setDnsHosts : ( enable ) ->
            uid = @get("uid")
            Design.instance().component( uid ).set("dnsHostnames", enable)
            null

        setAmazonDns : ( enable )->
            uid = @get("uid")
            Design.instance().component( uid ).get("dhcp").set("amazonDNS", enable)
            null

        removeDhcp : ( isDefault )->
            uid = @get("uid")
            dhcp = Design.instance().component( uid ).get("dhcp")
            if isDefault
                dhcp.setDefault()
            else
                dhcp.setNone()
            null

        useDhcp : ()->
            uid = @get("uid")
            Design.instance().component( uid ).get("dhcp").setCustom()
            null

        setDHCPOptions : ( options ) ->
            uid = @get("uid")
            dhcp = Design.instance().component( uid ).get("dhcp")
            dhcp.set( options )
            null
    }

    new VPCModel()
