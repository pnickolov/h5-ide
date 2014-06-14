#############################
#  View Mode for design/property/vpc
#############################

define [ '../base/model', 'Design', 'constant', "CloudResources" ], ( PropertyModel, Design, constant, CloudResources ) ->

    VPCModel = PropertyModel.extend {

        defaults :
            'isAppEdit' : false

        init : ( uid ) ->
            component = Design.instance().component( uid )

            dhcp_comp = component.get("dhcp")
            dhcp = $.extend {}, dhcp_comp.attributes

            dhcp.none    = dhcp_comp.isAuto()
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
                isAppEdit      : @isAppEdit
            }

            if @isAppEdit

                myVPCComponent = Design.instance().component( uid )

                vpc = CloudResources(constant.RESTYPE.VPC, Design.instance().region()).get(myVPCComponent.get('appId'))

                vpc = _.clone vpc

                TYPE_RTB = constant.RESTYPE.RT
                TYPE_ACL = constant.RESTYPE.ACL

                RtbModel = Design.modelClassForType( TYPE_RTB )
                AclModel = Design.modelClassForType( TYPE_ACL )

                vpc.mainRTB = RtbModel.getMainRouteTable()
                if vpc.mainRTB
                    vpc.mainRTB = vpc.mainRTB.get("appId")
                    vpc.defaultACL = AclModel.getDefaultAcl()
                if vpc.defaultACL
                    vpc.defaultACL = vpc.defaultACL.get("appId")

                @set vpc

            @set data
            null

        setCidr : ( newCIDR ) ->
            if Design.instance().component( @get("uid") ).setCidr( newCIDR )
                this.attributes.cidr = newCIDR
                return true

            false

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
                dhcp.setAuto()
            null

        setDhcp : (val)->
            uid = @get("uid")
            dhcp = Design.instance().component( uid ).get("dhcp")
            dhcp.setDhcp(val)
            null

        setDHCPOptions : ( options , force) ->
            uid = @get("uid")
            dhcp = Design.instance().component( uid ).get("dhcp")
            dhcp.set( options , force)
            null
    }

    new VPCModel()
