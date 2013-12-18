
define [ "constant", "../ConnectionModel", "Design" ], ( constant, ConnectionModel, Design )->

  # SgRuleConnection is used to represent the connection between two SecurityGroup or Sg and Ip
  SgRuleSet = ConnectionModel.extend {

    type : "SgRuleSet"

    ###
    |-------|   in1        out2   |-------|
    |       |  <=====     <=====  |       |
    | PORT1 |                     | PORT2 |
    |       |  =====>     =====>  |       |
    |-------|   out1        in2   |-------|
    ###

    default :
      in1  : null  # Collection for represent `inbound  rules for port1`
      out1 : null  # Collection for represent `outbound rules for port1`
      in2  : null
      out2 : null

    initialize : ()->
      # Make sure SgIpTarget is always be port2
      if @port1Comp().type is "SgIpTarget"
        tmp = @port2Comp()
        @__port2Comp = @__port1Comp
        @__port1Comp = tmp

      @attributes.in1  = []
      @attributes.out1 = []

      if @port1Comp() is @port2Comp()
        @attributes.in2  = @attributes.in1
        @attributes.out2 = @attributes.out1
      else
        @attributes.in2  = []
        @attributes.out2 = []
      null

    # port : name or id of the SG
    ruleCount : ( port )->
      if port is @port1Comp().id or port is @port1Comp().get("name")
        return @attributes.in1.length + @attributes.out1.length
      else
        return @attributes.in2.length + @attributes.out2.length

    toPlainObjects : ( filter )->

      portions = [ {
        ary       : @attributes.in1
        direction : SgRuleSet.DIRECTION.IN
        relation  : @port2Comp()
        owner     : @port1Comp()
      }, {
        ary       : @attributes.out1
        direction : SgRuleSet.DIRECTION.OUT
        relation  : @port2Comp()
        owner     : @port1Comp()
      } ]

      if not ( @port1Comp() is @port2Comp() or @getTarget( "SgIpTarget" ) )
        portions.push {
          ary       : @attributes.in2
          direction : SgRuleSet.DIRECTION.IN
          relation  : @port1Comp()
          owner     : @port2Comp()
        }
        portions.push {
          ary       : @attributes.out2
          direction : SgRuleSet.DIRECTION.OUT
          relation  : @port1Comp()
          owner     : @port2Comp()
        }

      rules = []
      for portion in portions
        if filter
          if _.isString filter
            if portion.owner.id isnt filter and portion.owner.get("name") isnt filter
              continue
          else if not filter( portion.owner )
            continue

        for rule in portion.ary
          if rule.protocol is "icmp"
            port = rule.fromPort + "/" + rule.toPort
          else if rule.fromPort is rule.toPort or not rule.toPort
            port = rule.fromPort
          else
            port = rule.fromPort + "-" + rule.toPort

          rules.push {
            ruleSetId : @id
            port      : port
            protocol  : rule.protocol
            direction : portion.direction
            relation  : portion.relation.get("name")
            color     : portion.relation.color
          }

      rules

    # addRawRule() is used to create rules for one SG, the SG1 might not be connectable to SG2 even after calling addRawRule()
    # use addRule() to create rules for both SG. The SG1 is guaranteed to be connectable to SG2

    #  ruleOwner : name or id of the target which will hold the rule
    addRawRule : ( ruleOwner, direction, rule ) ->
      console.assert( ruleOwner is @port1Comp().id or ruleOwner is @port2Comp().id or ruleOwner is @port1Comp().get("name") or ruleOwner is @port2Comp().get("name"), "Invalid ruleOwner, when adding a raw rule to SgRuleSet : ", ruleOwner )
      console.assert( direction is SgRuleSet.DIRECTION.BIWAY or direction is SgRuleSet.DIRECTION.IN or direction is SgRuleSet.DIRECTION.OUT, "Invalid direction, when adding a raw rule to SgRuleSet : ", rule )
      console.assert( rule.fromPort isnt undefined and rule.toPort isnt undefined and typeof rule.protocol is "string", "Invalid rule, when adding a raw rule to SgRuleSet : ", rule )

      if Design.instance().typeIsClassic() and direction is SgRuleSet.DIRECTION.OUT
        console.warn( "Ignoring setting outbound rule in Classic Mode " )
        return

      # Ensure valid protocol and port
      rule = $.extend {}, rule
      if rule.protocl is "-1" or rule.protocol is "all"
        rule.protocol = "all"
        rule.fromPort = "0"
        rule.toPort   = "65535"

      if rule.fromPort is rule.toPort
        rule.toPort   = ""


      port1 = ruleOwner is @port1Comp().id or ruleOwner is @port1Comp().get("name")

      switch direction
        when SgRuleSet.DIRECTION.IN
          portions = [ if port1 then "in1" else "in2" ]
        when SgRuleSet.DIRECTION.OUT
          portions = [ if port1 then "out1"  else "out2"  ]
        when SgRuleSet.DIRECTION.BIWAY
          portions = [
            if port1 then "in1"  else "in2" ,
            if port1 then "out1"  else "out2"
          ]

      for portionName in portions
        exist = false
        portion = @get( portionName )

        for existRule in portion
          if existRule.fromPort is rule.fromPort and existRule.toPort is rule.toPort and existRule.protocol is rule.protocol
            exist = true
            break
        # If we don't have that rule, add that rule to portion
        if not exist
          portion = portion.slice(0)
          portion.push rule
          @set portionName, portion

      null

    # For SG1 <=> SG2
    # if `target` is "SG1" and `direction` is "inbound",  it means: SG1 <= SG2, it reads: target's inbound
    # if `target` is "SG1" and `direction` is "outbound", it means: SG1 => SG2, it reads: target's outbound
    addRule : ( target, direction, rule )->

      console.assert( target is @port1Comp().id or target is @port2Comp().id or target is @port1Comp().get("name") or target is @port2Comp().get("name"), "Invalid target, when adding a rule to SgRuleSet : ", target )

      if target is @port1Comp().id or target is @port1Comp().get("name")
        target2 = @port2Comp().id
      else
        target  = @port2Comp().id
        target2 = @port1Comp().id

      if direction is SgRuleSet.DIRECTION.IN or direction is SgRuleSet.DIRECTION.BIWAY
        @addRawRule( target,  SgRuleSet.DIRECTION.IN,  rule )
        @addRawRule( target2, SgRuleSet.DIRECTION.OUT, rule )

      if direction is SgRuleSet.DIRECTION.OUT or direction is SgRuleSet.DIRECTION.BIWAY
        @addRawRule( target,  SgRuleSet.DIRECTION.OUT, rule )
        @addRawRule( target2, SgRuleSet.DIRECTION.IN,  rule )
      null

    removeRawRule : ( ruleOwner, direction, rule ) ->
      console.assert( ruleOwner is @port1Comp().id or ruleOwner is @port2Comp().id or ruleOwner is @port1Comp().get("name") or ruleOwner is @port2Comp().get("name"), "Invalid ruleOwner, when removing a raw rule from SgRuleSet : ", ruleOwner )
      console.assert( direction is SgRuleSet.DIRECTION.BIWAY or direction is SgRuleSet.DIRECTION.IN or direction is SgRuleSet.DIRECTION.OUT, "Invalid direction, when removing a raw rule from SgRuleSet : ", rule )
      console.assert( rule.fromPort isnt undefined and rule.toPort isnt undefined and rule.protocol isnt undefined, "Invalid rule, when removing a raw rule from SgRuleSet : ", rule )

      if Design.instance().typeIsClassic() and direction is SgRuleSet.DIRECTION.OUT
        console.warn( "Ignoring removing outbound rule in Classic Mode " )
        return

      if rule.protocol is "-1"        then rule.protocol = "all"
      if rule.fromPort is rule.toPort then rule.toPort   = ""

      port1 = ruleOwner is @port1Comp().id or ruleOwner is @port1Comp().get("name")

      switch direction
        when SgRuleSet.DIRECTION.IN
          portions = [ if port1 then "in1" else "in2" ]
        when SgRuleSet.DIRECTION.OUT
          portions = [ if port1 then "out1"  else "out2"  ]
        when SgRuleSet.DIRECTION.BIWAY
          portions = [
            if port1 then "in1"  else "in2" ,
            if port1 then "out1"  else "out2"
          ]

      checkEmpty = false
      found      = false

      for portionName in portions
        portion = @get( portionName )

        for existRule, idx in portion

          if existRule.fromPort is rule.fromPort and existRule.toPort is rule.toPort and existRule.protocol is rule.protocol
            portion = portion.slice(0)
            portion.splice( idx, 1 )
            checkEmpty = portion.length is 0
            found = true
            @set portionName, portion
            break

      if checkEmpty and @attributes.in1.length is 0 and @attributes.in2.length is 0 and @attributes.out1.length is 0 and @attributes.out2.length is 0
        @remove()

      console.assert( found, "Rule is not found when removing SG Rule", rule )
      null

    removeRuleByPlainObj : ( ruleObj )->
      console.assert( ruleObj.relation is @port1Comp().id or ruleObj.relation is @port1Comp().get("name") or ruleObj.relation is @port2Comp().id or ruleObj.relation is @port2Comp().get("name"), "Invalid ruleObj.relation, when removing a rule : ", ruleObj )

      console.assert( ruleObj.direction is SgRuleSet.DIRECTION.BIWAY or ruleObj.direction is SgRuleSet.DIRECTION.IN or ruleObj.direction is SgRuleSet.DIRECTION.OUT, "Invalid direction, when removing a raw rule from SgRuleSet : ", ruleObj )

      console.assert( ruleObj.relation isnt undefined and ruleObj.port isnt undefined and ruleObj.protocol isnt undefined and ruleObj.direction isnt undefined, "Invalid ruleObj, when removing a rule : ", ruleObj )

      if ruleObj.relation is @port1Comp().id or ruleObj.relation is @port1Comp().get("name")
        owner = @port2Comp().id
      else
        owner = @port1Comp().id

      ports = (""+ruleObj.port).split("-")
      ruleObj.fromPort = ports[0]
      ruleObj.toPort   = if ports.length >= 2 then ruleObj[1] else ""

      @removeRawRule( owner, ruleObj.direction, ruleObj )
      null

  }, {

    getResourceSgRuleSet : ( resource )->

      sgAssos   = resource.connections("SgAsso")
      sgRuleMap = {}
      sgRuleAry = []

      for sgAsso in sgAssos
        # Find out what SG is used by this resource
        sg = sgAsso.getTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )

        # Find out what rules has in this sg
        for ruleset in sg.connections( "SgRuleSet" )
          # Remove duplicate SgRuleSets
          if sgRuleMap[ ruleset.id ] then continue
          sgRuleMap[ ruleset.id ] = true

          sgRuleAry.push ruleset

      sgRuleAry
  }

  SgRuleSet.DIRECTION = {
    BIWAY : "biway"
    IN    : "inbound"
    OUT   : "outbound"
  }

  SgRuleSet


