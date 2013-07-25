#############################
#  View Mode for design/property/subnet
#############################

define [ 'constant', 'backbone', 'jquery', 'underscore', 'MC' ], ( constant ) ->

    SubnetModel = Backbone.Model.extend {

        defaults :
            uid  : null
            name : null
            CIDR : null
            networkACL : null # Array

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

        setId : ( uid ) ->

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
                        isUsed  : false

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

            # if linkToDefault
            #     defaultACL.isUsed = true

            this.set data
            null

        setName : ( name ) ->
            MC.canvas_data.component[ this.attributes.uid ].name = name
            null

        setCIDR : ( cidr ) ->

            # TODO : Validate CIDR

            MC.canvas_data.component[ this.attributes.uid ].resource.CidrBlock = cidr
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

    model = new SubnetModel()

    return model
