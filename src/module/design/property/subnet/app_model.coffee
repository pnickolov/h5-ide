#############################
#  View Mode for design/property/subnet
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    SubnetAppModel = PropertyModel.extend {

        init : ( subnet_uid )->

            mySubnetComponent = MC.canvas_data.component[ subnet_uid ]

            appData = MC.data.resource_list[ MC.canvas_data.region ]
            subnet  = appData[ mySubnetComponent.resource.SubnetId ]

            if not subnet
                return false

            subnet      = $.extend true, {}, subnet
            subnet.name = mySubnetComponent.name
            subnet.acl  = this.getACL subnet_uid
            subnet.uid  = subnet_uid

            # Get RouteTable ID
            ACL_TYPE = constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
            for key, value of MC.canvas_data.component
                if value.type == ACL_TYPE

                    for i in value.resource.AssociationSet
                        if i.SubnetId.indexOf( subnet_uid ) != -1
                            linkedRT = value.resource.RouteTableId
                        if i.Main == "true"
                            defaultRT = value.resource.RouteTableId

            subnet.routeTable = if linkedRT then linkedRT else defaultRT

            this.set subnet
            null

        getACL : ( uid ) ->

            ACL_TYPE = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl

            for id, component of MC.canvas_data.component
                if component.type == ACL_TYPE
                    acl =
                        uid    : component.uid
                        rule   : component.resource.EntrySet.length
                        name   : component.name
                        association : component.resource.AssociationSet.length

                    for asscn in component.resource.AssociationSet
                        if asscn.SubnetId.indexOf( uid ) != -1
                            linkedACL = acl
                            break

                    if component.name == "DefaultACL"
                        defaultACL = acl

            if linkedACL then linkedACL else defaultACL
    }

    new SubnetAppModel()
