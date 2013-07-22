#############################
#  View Mode for design/property/subnet
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    SubnetModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        getRenderData : ( uid ) ->

            subnet_component = MC.canvas_data.component[ uid ]
            networkACLs = []

            data =
                uid  : uid
                name : subnet_component.name
                CIDR : subnet_component.resource.CidrBlock
                networkACL : networkACLs


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

                    for asscn in component.resource.AssociationSet
                        if asscn.SubnetId.indexOf( uid ) != -1
                            linkToDefault = false
                            acl.isUsed = true
                            break

                    if component.name == "DefaultACL"
                        defaultACLIdx = networkACLs.length

                    networkACLs.push acl

            if defaultACLIdx == -1
                console.log "[Warning] Cannot find DefaultACL!!!"

            if defaultACLIdx != 0
                defaultACL = networkACLs.splice defaultACLIdx, 1
                networkACLs.splice 0, 0, defaultACL
            else
                defaultACL = networkACLs[ 0 ]

            if linkToDefault
                defaultACL.isUsed = true

            data

        setName : ( uid, name ) ->
            MC.canvas_data.component[ uid ].name = name
            null

        setCIDR : ( uid, cidr ) ->
            MC.canvas_data.component[ uid ].resource.CidrBlock = cidr
            null

        setACL : ( uid, acl_uid ) ->
            
            ACL_TYPE = constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
            for id, component of MC.canvas_data.component
                if component.type != ACL_TYPE
                    continue

                removed = false

                for asscn, idx in component.resource.AssociationSet
                    if asscn.SubnetId.indexOf( uid ) != -1
                        component.resource.AssociationSet.splice idx, 1
                        removed = true
                        break

                if removed
                    break

            acl = MC.canvas_data.component[ acl_uid ]
            acl.resource.AssociationSet.push
                SubnetId : "@" + uid + ".resource.SubnetId"
                NetworkAclAssociationId : ""
                NetworkAclId : ""
            null
    }

    model = new SubnetModel()

    return model
