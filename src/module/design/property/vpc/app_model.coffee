#############################
#  View Mode for design/property/vpc (app)
#############################

define [ '../base/model', "Design", 'constant', "CloudResources" ], ( PropertyModel, Design, constant, CloudResources ) ->

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
              @dhcpCollection = CloudResources constant.RESTYPE.DHCP, Design.instance().region()
              that = this
              @dhcpCollection.fetchForce().then (result)->
                  dhcp = that.dhcpCollection.findWhere( id: vpc.dhcpOptionsId ).toJSON()
                  newDhcp = {}
                  for key of dhcp
                      if key is 'domain-name'
                        newDhcp['domainName'] = dhcp[key]
                      else if key is 'domain-name-servers'
                        newDhcp['domainNameServers'] = dhcp[key]
                      else if key is 'netbios-name-servers'
                        newDhcp['netbiosNameServers'] = dhcp[key]
                      else if key is 'netbios-node-type'
                        newDhcp['netbiosNodeTypes'] = dhcp[key]
                      else if key is 'ntp-servers'
                        newDhcp['ntpServers'] = dhcp[key]

                  vpc.dhcp = newDhcp
                  that.set vpc
            else
              dhcpData = appData[myVPCComponent.toJSON().dhcp.toJSON().appId]?.dhcpConfigurationSet.item
              vpc.dhcpOptionsId = myVPCComponent.toJSON().dhcp.toJSON().appId
              dhcp = null
              if dhcpData
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
