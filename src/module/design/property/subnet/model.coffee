#############################
#  View Mode for design/property/subnet
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    SubnetModel = PropertyModel.extend {

        defaults :
            uid  : null
            name : null
            CIDR : null
            networkACL : null # Array

        init : ( uid ) ->

            subnet_component = MC.canvas_data.component[ uid ]

            if !subnet_component then return false

            networkACLs = []

            ACL_TYPE = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl

            linkToDefault = true
            defaultACLIdx = -1

            for id, component of MC.canvas_data.component
                if component.type == ACL_TYPE
                    acl =
                        uid    : component.uid
                        rule   : component.resource.EntrySet.length
                        name   : component.name
                        association : component.resource.AssociationSet.length
                        isUsed  : false

                    for asscn in component.resource.AssociationSet
                        if asscn.SubnetId.indexOf( uid ) != -1
                            linkToDefault = false
                            acl.isUsed = true
                            break

                    if component.name == "DefaultACL"
                        defaultACLIdx = networkACLs.length

                    # if component.resource.AssociationSet.length isnt 0
                    #     acl.isUsed = true

                    if component.name == "DefaultACL"
                        # acl.isUsed = true
                        acl.isDefault = true
                        defaultACLIdx = networkACLs.length
                    else
                        acl.isDefault = false

                    networkACLs.push acl

            if defaultACLIdx == -1
                console.log "[Warning] Cannot find DefaultACL!!!"

            if defaultACLIdx != 0
                defaultACL = networkACLs.splice defaultACLIdx, 1
                networkACLs.splice 0, 0, defaultACL[0]
            else
                defaultACL = networkACLs[ 0 ]

            # if linkToDefault
            #     defaultACL.isUsed = true

            data =
                uid  : uid
                name : subnet_component.name
                CIDR : subnet_component.resource.CidrBlock
                networkACL : networkACLs

            this.set data
            null

        setName : ( name ) ->
            MC.canvas_data.component[ this.attributes.uid ].name = name
            subnetCIDR = MC.canvas_data.component[ this.attributes.uid ].resource.CidrBlock
            MC.canvas.update this.attributes.uid, "text", "label", name + ' (' + subnetCIDR + ')'
            null

        setCIDR : ( cidr ) ->

            # TODO : Validate CIDR
            MC.canvas_data.component[ this.attributes.uid ].resource.CidrBlock = cidr
            subnetName = MC.canvas_data.component[ this.attributes.uid ].name
            MC.canvas.update this.attributes.uid, "text", "label", subnetName + ' (' + cidr + ')'

            MC.aws.subnet.updateAllENIIPList(this.attributes.uid)

            null

        setACL : ( acl_uid ) ->

            ACL_TYPE = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
            for id, component of MC.canvas_data.component
                if component.type != ACL_TYPE
                    continue

                removed = false

                for asscn, idx in component.resource.AssociationSet
                    if asscn.SubnetId.indexOf( this.attributes.uid ) != -1
                        component.resource.AssociationSet.splice idx, 1
                        removed = true
                        break

                if removed
                    break

            acl = MC.canvas_data.component[ acl_uid ]
            acl.resource.AssociationSet.push
                SubnetId : "@" + this.attributes.uid + ".resource.SubnetId"
                NetworkAclAssociationId : ""
                NetworkAclId : ""
            null
    }

    new SubnetModel()
