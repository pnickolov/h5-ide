#############################
#  View Mode for design/property/vpc (app)
#############################

define ['constant', 'backbone', 'MC' ], ( constant ) ->

    VPCAppModel = Backbone.Model.extend {

        ###
            defaults :

        ###

        init : ( vpc_uid ) ->

          myVPCComponent = MC.canvas_data.component[ vpc_uid ]

          appData = MC.data.resource_list[ MC.canvas_data.region ]

          vpc = $.extend true, {}, appData[ myVPCComponent.resource.VpcId ]
          vpc.name = myVPCComponent.name

          if vpc.state == "available"
            vpc.available = true

          TYPE_RTB = constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
          TYPE_ACL = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl

          # Get Main Route Table and Default ACL
          for key, value of MC.canvas_data.component
            if value.type == TYPE_RTB
              if value.resource.AssociationSet[0] && value.resource.AssociationSet[0].Main == "true"
                vpc.mainRTB = value.resource.RouteTableId
                if vpc.defaultACL
                  break
            else if value.type == TYPE_ACL
              if value.resource.Default == "true"
                vpc.defaultACL = value.resource.NetworkAclId
                if vpc.mainRTB
                  break

          if vpc.dhcpOptionsId
            dhcpData = appData[ vpc.dhcpOptionsId ].dhcpConfigurationSet.item
            dhcp = {}

            for i in dhcpData
              dhcp[ MC.camelCase( i.key ) ] = i.valueSet

            vpc.dhcp = dhcp

          this.set vpc
    }

    new VPCAppModel()
