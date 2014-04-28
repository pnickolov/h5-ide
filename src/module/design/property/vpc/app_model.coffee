#############################
#  View Mode for design/property/vpc (app)
#############################

define [ '../base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

    VPCAppModel = PropertyModel.extend {

        init : ( vpc_uid ) ->

          myVPCComponent = Design.instance().component( vpc_uid )

          appData = MC.data.resource_list[ Design.instance().region() ]
          vpc     = appData[ myVPCComponent.get 'appId' ]

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
            if not appData[ vpc.dhcpOptionsId ]
              vpc.default_dhcp = true

            else
              dhcpData = appData[ vpc.dhcpOptionsId ].dhcpConfigurationSet.item
              dhcp = {}

              for i in dhcpData
                if i.key is 'domain-name-servers'
                  for j, idx in i.valueSet
                    if j is 'AmazonProvidedDNS'
                      tmp = i.valueSet[0]
                      i.valueSet[0]   = j
                      i.valueSet[idx] = tmp
                      break
                dhcp[ MC.camelCase( i.key ) ] = i.valueSet

              vpc.dhcp = dhcp

          @set vpc
          null
    }

    new VPCAppModel()
