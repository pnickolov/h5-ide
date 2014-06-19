#############################
#  View Mode for design/property/subnet
#############################

define [ '../base/model', 'constant', 'Design', 'CloudResources' ], ( PropertyModel, constant, Design, CloudResources ) ->

    SubnetAppModel = PropertyModel.extend {

        init : ( uid )->

            mySubnetComponent = Design.instance().component( uid )

            subnet = CloudResources(constant.RESTYPE.SUBNET, Design.instance().region()).get(mySubnetComponent.get('appId'))?.toJSON()
            if not subnet
                return false

            subnet = _.clone subnet
            subnet.name = mySubnetComponent.get 'name'
            subnet.acl  = this.getACL( uid )
            subnet.uid  = uid

            # Get RouteTable ID

            routeTable = mySubnetComponent.connectionTargets( 'RTB_Asso' )[ 0 ]

            linkedRT = routeTable.get 'appId'
            if routeTable.get 'main'
                defaultRT = routeTable.get 'appId'

            subnet.routeTable = if linkedRT then linkedRT else defaultRT

            this.set subnet
            null

        getACL : ( uid ) ->

            acl = Design.instance().component( uid ).connectionTargets( 'AclAsso' )[0]
            if not acl then return null

            {
                id          : acl.id
                name        : acl.get("name")
                rule        : acl.getRuleCount()
                association : acl.getAssoCount()
            }
    }

    new SubnetAppModel()
