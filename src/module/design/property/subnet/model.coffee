#############################
#  View Mode for design/property/subnet
#############################

define [ '../base/model', 'constant', "Design" ], ( PropertyModel, constant, Design ) ->

  SubnetModel = PropertyModel.extend {

    init : ( uid ) ->

      subnet_component = Design.instance().component( uid )

      if !subnet_component then return false

      ACLModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )

      subnet_acl = subnet_component.getAcl()

      defaultACL  = null
      networkACLs = []
      _.each ACLModel.allObjects(), ( acl )->
        aclObj = {
          uid         : acl.id
          name        : acl.get("name")
          isUsed      : acl is subnet_acl
          rule        : acl.getRuleCount()
          association : acl.getAssoCount()
        }

        if acl.get("isDefault")
          defaultACL = aclObj
          aclObj.isDefault = true
        else
          networkACLs.splice( _.sortedIndex( networkACLs, aclObj, "name" ), 0, aclObj )

      console.assert( defaultACL, "Cannot find DefaultACL" )
      networkACLs.splice( 0, 0, defaultACL )

      @set {
        uid        : uid
        name       : subnet_component.get("name")
        CIDR       : subnet_component.get("cidr")
        networkACL : networkACLs
      }
      null

    createAcl : ()->
      ACLModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )
      acl = new ACLModel()
      # Assign acl to the newly created acl
      @setACL( acl.id )
      acl.id

    removeAcl : ( acl_uid )->
      Design.instance().component( acl_uid ).remove()
      null

    setCIDR : ( cidr ) ->
      Design.instance().component( @get("uid") ).setCIDR( cidr )

    setACL : ( acl_uid ) ->
      Design.instance().component( @get("uid") ).setAcl( acl_uid )
      null
  }

  new SubnetModel()
