
define [ "../ComplexResModel", "../connection/AclAsso", "constant" ], ( ComplexResModel, AclAsso, constant )->

  Model = ComplexResModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
    newNameTmpl : "CustomACL-"

    getRuleCount : ()->
      0

    getAssoCount : ()-> @connections().length

  }, {

    handleTypes  : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
    resolveFirst : true

    getDefaultAcl : ()->
      _.find Model.allObjects(), ( obj )-> obj.get("isDefault")

    deserialize : ( data, layout_data, resolve )->

      isDefault = data.name is "DefaultACL"
      subnets   = []

      if not isDefault and data.resource.AssociationSet
        # If this is not DefaultACL, then we need to get its subnets.
        # If the subnet cannot be resolve yet, then, we do not deserialize this ACL
        for asso in data.resource.AssociationSet
          subnet = resolve( MC.extractID( asso.SubnetId ) )
          if not subnet then return
          subnets.push subnet

      acl = new Model({
        id        : data.uid
        name      : data.name
        isDefault : isDefault
      })

      for sb in subnets
        new AclAsso( acl, sb )
  }

  Model
