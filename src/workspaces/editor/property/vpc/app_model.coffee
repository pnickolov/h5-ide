#############################
#  View Mode for design/property/vpc (app)
#############################

define [ '../base/model', "Design", 'constant', 'CloudResources' ], ( PropertyModel, Design, constant, CloudResources ) ->

    VPCAppModel = PropertyModel.extend {

        init : ( vpc_uid ) ->

          myVPCComponent = Design.instance().component( vpc_uid )

          vpc = CloudResources(constant.RESTYPE.VPC, Design.instance().region()).get(myVPCComponent.get('appId'))?.attributes
          appData = CloudResources(constant.RESTYPE.DHCP, Design.instance().region())
          if not vpc then return false

          vpc = $.extend true, {}, vpc
          vpc.name = myVPCComponent.get 'name'

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

          if vpc.dhcpOptionsId
            if not appData.get(vpc.dhcpOptionsId)
              vpc.default_dhcp = true

            else
              dhcpData = appData.get(myVPCComponent?.toJSON().dhcp?.toJSON().appId)?.attributes
              vpc.dhcpOptionsId = myVPCComponent?.toJSON().dhcp?.toJSON()?.appId
              dhcp = null
              if dhcpData
                  dhcp = {}
                  for i of dhcpData
                    dhcp[ MC.camelCase(i) ] = dhcpData[i]
              vpc.dhcp = dhcp

          @set vpc
          null
    }

    new VPCAppModel()
