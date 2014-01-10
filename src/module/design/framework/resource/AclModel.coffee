
define [ "../ComplexResModel", "../ConnectionModel", "constant" ], ( ComplexResModel, ConnectionModel, constant )->

  __emptyIcmp      = { Code : "", Type : "" }
  __emptyPortRange = { From : "", To : "" }


  # AclAsso represent a connection between a subnet and a networkacl
  AclAsso = ConnectionModel.extend {
    type : "AclAsso"
    oneToMany : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl

    serialize : ( components )->
      sb  = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
      acl = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl )

      acl_data =

      components[ acl.id ].resource.AssociationSet.push {
        NetworkAclAssociationId : ""
        NetworkAclId : ""
        SubnetId: "@#{sb.id}.resource.SubnetId"
      }
      null
  }



  formatRules = ( JsonRuleEntrySet )->

    if not JsonRuleEntrySet or not JsonRuleEntrySet.length
      return []

    _.map JsonRuleEntrySet, ( r )->

      rule = {
        id       : _.uniqueId( "aclrule_" )
        cidr     : r.CidrBlock
        egress   : r.Egress
        protocol : r.Protocol
        action   : r.RuleAction
        number   : r.RuleNumber
        port     : ""
      }

      # For ICMP rule, port will be "IcmTypeCode.Type/IcmpTypeCode.Code"

      if r.Protocol is "1" and r.IcmpTypeCode and r.IcmpTypeCode.Code and r.IcmpTypeCode.Type
        rule.port = r.IcmpTypeCode.Type + "/" + r.IcmpTypeCode.Code
      else if r.PortRange.From and r.PortRange.To
        if r.PortRange.From is r.PortRange.To
          rule.port = r.PortRange.From
        else
          rule.port = r.PortRange.From + "-" + r.PortRange.To

      rule

  Model = ComplexResModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
    newNameTmpl : "CustomACL-"

    defaults : ()->
      {
        rules : []
      }

    isDefault : ()-> @attributes.name is "DefaultACL"

    remove : ()->
      console.assert( not this.isDefault(), "Cannot delete DefaultACL" )

      # When remove an acl, attach all its subnet to DefaultACL
      defaultAcl = Model.getDefaultAcl()
      for target in @connectionTargets()
        new AclAsso( defaultAcl, target )
      null

    addRule : ( rule )->
      console.assert( rule.number isnt undefined && rule.protocol isnt undefined && rule.egress isnt undefined && rule.action isnt undefined && rule.cidr isnt undefined && rule.port isnt undefined, "Invalid ACL Rule data")

      ruleExist = false

      currentRules = @get("rules")

      for r in currentRules
        if r.number is rule.number
          ruleExist = true
          break

      if ruleExist then return false

      currentRules = currentRules.slice(0)
      currentRules.push rule
      @set "rules", currentRules
      true

    removeRule : ( ruleId )->
      rules = @get("rules")
      for rule, idx in rules
        if rule.id is ruleId
          theRule = rule
          break

      if theRule.number is "32767" then return false
      if @get.isDefault() and theRule.number is "100" then return false

      @set "rules", rules.slice(0).splice( idx, 1 )
      true

    getRuleCount : ()-> @get("rules").length
    getAssoCount : ()-> @connections().length

    serialize : ()->
      vpcId = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC().id

      ruleSet = []

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          AssociationSet : []
          Default        : @isDefault()
          EntrySet       : ruleSet
          NetworkAclId   : @get("appId")
          RouteTableId   : ""
          VpcId          : "@{#vpcId}.resource.VpcId"

      for rule in @get("rules")
        r = {
          Egress       : rule.egress
          Protocol     : rule.protocol
          RuleAction   : rule.action
          RuleNumber   : rule.number
          CidrBlock    : rule.cidr
          IcmpTypeCode : __emptyIcmp
          PortRange    : __emptyPortRange
        }

        if rule.protocol is "1"
          port = rule.port.split("/")
          r.IcmpTypeCode = { Code : port[1], Type : port[0] }
        else if rule.port
          port = ( rule.port + "-" + rule.port ).split("-")
          r.PortRange = { From : port[0], To : port[1] }

        ruleSet.push r

      { component : component }

  }, {

    handleTypes  : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
    resolveFirst : true

    getDefaultAcl : ()->
      _.find Model.allObjects(), ( obj )-> obj.isDefault()

    preDeserialize : ( data, layout_data )->
      new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.NetworkAclId
        rules : formatRules( data.resource.EntrySet )
      })

      null

    deserialize : ( data, layout_data, resolve )->
      acl = resolve( data.uid )

      for asso in data.resource.AssociationSet
        new AclAsso( acl, resolve( MC.extractID(asso.SubnetId) ) )
      null
  }

  Model
