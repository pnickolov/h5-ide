
define [ "ComplexResModel", "ConnectionModel", "constant" ], ( ComplexResModel, ConnectionModel, constant )->

  __emptyIcmp      = { Code : "", Type : "" }
  __emptyPortRange = { From : "", To : "" }


  # AclAsso represent a connection between a subnet and a networkacl
  AclAsso = ConnectionModel.extend {
    type : "AclAsso"
    oneToMany : constant.RESTYPE.ACL

    defaults :
      associationId : ""

    serialize : ( components )->
      sb  = @getTarget( constant.RESTYPE.SUBNET )
      acl = @getTarget( constant.RESTYPE.ACL )

      components[ acl.id ].resource.AssociationSet.push {
        NetworkAclAssociationId : @get("associationId")
        SubnetId: sb.createRef( "SubnetId" )
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
        protocol : parseInt(r.Protocol, 10)
        number   : parseInt(r.RuleNumber, 10)
        action   : r.RuleAction
        port     : ""
      }

      # For ICMP rule, port will be "IcmTypeCode.Type/IcmpTypeCode.Code"

      if rule.protocol is 1 and r.IcmpTypeCode and r.IcmpTypeCode.Code and r.IcmpTypeCode.Type
        rule.port = r.IcmpTypeCode.Type + "/" + r.IcmpTypeCode.Code
      else if r.PortRange.From and r.PortRange.To
        if r.PortRange.From is r.PortRange.To
          rule.port = r.PortRange.From + ""
        else
          rule.port = r.PortRange.From + "-" + r.PortRange.To

      rule

  Model = ComplexResModel.extend {

    type : constant.RESTYPE.ACL
    newNameTmpl : "CustomACL-"

    defaults : ()->
      {
        rules : [{
          action   : "deny"
          cidr     : "0.0.0.0/0"
          egress   : true
          id       : _.uniqueId( "aclrule_" )
          number   : 32767
          port     : ""
          protocol : -1
        }, {
          action   : "deny"
          cidr     : "0.0.0.0/0"
          egress   : false
          id       : _.uniqueId( "aclrule_" )
          number   : 32767
          port     : ""
          protocol : -1
        }]
      }

    isVisual  : ()-> false
    isDefault : ()-> @attributes.name is "DefaultACL"

    remove : ()->
      console.assert( not this.isDefault(), "Cannot delete DefaultACL" )

      # When remove an acl, attach all its subnet to DefaultACL
      defaultAcl = Model.getDefaultAcl()
      for target in @connectionTargets()
        new AclAsso( defaultAcl, target )

      ComplexResModel.prototype.remove.call this
      null

    addRule : ( rule )->
      console.assert( rule.number isnt undefined && rule.protocol isnt undefined && rule.egress isnt undefined && rule.action isnt undefined && rule.cidr isnt undefined && rule.port isnt undefined, "Invalid ACL Rule data")

      # Make sure protocol and number is `int`
      rule.protocol = parseInt( rule.protocol, 10 )
      rule.number   = parseInt( rule.number, 10 )

      # Set CIDR to Valid e.g. (10.0.0.1/16 -> 10.0.0.0/16)
      rule.cidr = MC.getValidCIDR(rule.cidr)

      currentRules = @get("rules")

      for r in currentRules
        if r.number is rule.number
          return false

      # Add rule Id for the rule
      rule.id = _.uniqueId( "aclrule_" )

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

      if theRule.number is 32767 then return false
      if @isDefault() and theRule.number is 100 then return false

      rules = rules.slice(0)
      rules.splice( idx, 1 )
      @set "rules", rules
      true

    getRuleCount : ()-> @get("rules").length
    getAssoCount : ()-> @connections().length

    serialize : ()->
      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()

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
          VpcId          : vpc.createRef( "VpcId" )

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

        if rule.protocol is 1
          port = rule.port.split("/")
          r.IcmpTypeCode = { Code : port[1], Type : port[0] }
        else if rule.port
          port = ( rule.port + "-" + rule.port ).split("-")
          r.PortRange = { From : port[0], To : port[1] }

        ruleSet.push r

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.ACL
    resolveFirst : true

    getDefaultAcl : ()->
      _.find Model.allObjects(), ( obj )-> obj.isDefault()

    preDeserialize : ( data, layout_data )->
      new Model({
        id    : data.uid
        name  : if data.resource.Default then "DefaultACL" else data.name
        appId : data.resource.NetworkAclId
        rules : formatRules( data.resource.EntrySet )
      })

      null

    deserialize : ( data, layout_data, resolve )->
      acl = resolve( data.uid )

      for asso in data.resource.AssociationSet || []
        c = new AclAsso( acl, resolve( MC.extractID(asso.SubnetId) ) )
        # Must use set. Because new AclAsso might return an object that already exists.
        # Resulting the associationId is not set.
        c.set "associationId", asso.NetworkAclAssociationId
      null
  }

  Model
