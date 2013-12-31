#############################
#  View Mode for design/property/vpc
#############################

define [ '../base/model', 'Design', 'constant' ], ( PropertyModel, Design, constant ) ->

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
                defaultTenancy : component.isDefaultTenancy()
                name           : component.get("name")
                cidr           : component.get("cidr")
                dhcp           : dhcp
            }

            @set data
            null

        setCIDR : ( newCIDR ) ->
            Design.instance().component( @get("uid") ).setCIDR( newCIDR )

        setTenancy : ( tenancy ) ->
            Design.instance().component( @get("uid") ).setTenancy( tenancy )
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
