
define [ "../ComplexResModel", "../connection/AclAsso", "constant" ], ( ComplexResModel, AclAsso, constant )->

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

      # For ICMP rule, port will be "IcmpTypeCode.Code/IcmTypeCode.Type"

      if r.Protocol is "1" and r.IcmpTypeCode and r.IcmpTypeCode.Code and r.IcmpTypeCode.Type
        rule.port = r.IcmpTypeCode.Code + "/" + r.IcmpTypeCode.Type
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
        isDefault : false
        rules     : []
      }

    remove : ()->
      console.assert( not this.get("isDefault"), "Cannot delete DefaultACL" )

      # When remove and acl, attach all its subnet to DefaultACL
      defaultAcl = Model.getDefaultAcl()
      for cn in @connections()
        new AclAsso( defaultAcl, cn.getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl ) )
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
      if @get("isDefault") and theRule.number is "100" then return false

      @set "rules", rules.slice(0).splice( idx, 1 )
      true

    getRuleCount : ()-> @get("rules").length
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
        rules     : formatRules( data.resource.EntrySet )
        isDefault : isDefault
      })

      for sb in subnets
        new AclAsso( acl, sb )

      null
  }

  Model
