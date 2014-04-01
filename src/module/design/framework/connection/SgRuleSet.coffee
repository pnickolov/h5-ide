
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

    toPlainObjects : ( filter, detailedInfo )->

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

          attr =
            ruleSetId  : @id
            port       : port
            protocol   : rule.protocol
            direction  : portion.direction
            relation   : portion.relation.get("name")
            color      : portion.relation.color

          if detailedInfo
            attr.relationId = portion.relation.id
            attr.ownerId    = portion.owner.id

          rules.push attr

      rules

    # return true, if there are rules to port
    hasRawRuleTo : ( port )->
      console.assert( port is @port1Comp() or port is @port2Comp(), "Invalid port for calling SgRuleSet.hasRawRuleTo()" )

      if port is @port1Comp()
        return @attributes.in1.length > 0 or @attributes.out2.length > 0
      else
        return @attributes.in2.length > 0 or @attributes.out1.length > 0

    # addRawRule() is used to create rules for one SG, the SG1 might not be connectable to SG2 even after calling addRawRule()
    # use addRule() to create rules for both SG. The SG1 is guaranteed to be connectable to SG2

    #  ruleOwner : name or id of the target which will hold the rule
    addRawRule : ( ruleOwner, direction, rawRule ) ->
      console.assert( ruleOwner is @port1Comp().id or ruleOwner is @port2Comp().id or ruleOwner is @port1Comp().get("name") or ruleOwner is @port2Comp().get("name"), "Invalid ruleOwner, when adding a raw rule to SgRuleSet : ", ruleOwner )
      console.assert( direction is SgRuleSet.DIRECTION.BIWAY or direction is SgRuleSet.DIRECTION.IN or direction is SgRuleSet.DIRECTION.OUT, "Invalid direction, when adding a raw rule to SgRuleSet : ", rawRule )
      console.assert( ("#{rawRule.protocol}" is "-1" or rawRule.protocol is "all" or parseInt(rawRule.protocol, 10) + "" is rawRule.protocol ) or rawRule.fromPort or rawRule.toPort, "Invalid rule, when adding a raw rule to SgRuleSet : ", rawRule )


      if Design.instance().typeIsClassic() and direction is SgRuleSet.DIRECTION.OUT
        console.warn( "Ignoring setting outbound rule in Classic Mode " )
        return

      # Some bookkeeping to see if we need to draw some sglines.
      shouldInitSgLine = @get("in1").length + @get("in2").length + @get("out1").length + @get("out2").length is 0

      oldPort1InRuleCout  = @get("in1").length
      oldPort2InRuleCout  = @get("in2").length
      oldPort1OutRuleCout = @get("out1").length
      oldPort2OutRuleCout = @get("out2").length

      # Ensure valid protocol and port
      rule = {
        protocol : rawRule.protocol
        fromPort : "" + rawRule.fromPort
        toPort   : "" + rawRule.toPort
      }
      if "#{rule.protocol}" is "-1" or rule.protocol is "all"
        rule.protocol = "all"
        rule.fromPort = "0"
        rule.toPort   = "65535"
      else if parseInt( rawRule.protocol, 10 ) + "" is rawRule.protocol
        # Custom protocol always have empty port.
        rule.fromPort = ""
        rule.toPort   = ""

      if rule.fromPort is rule.toPort and rule.protocol isnt "icmp"
        rule.toPort   = ""


      port1 = ruleOwner is @port1Comp().id or ruleOwner is @port1Comp().get("name")

      if not port1 and @getTarget("SgIpTarget")
        console.info "Ignoring adding sg rules for Ip Target."
        return

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



      if shouldInitSgLine
        # Check SgModel.connect() to see why we draw the SgLine here, instead of
        # drawing SgLine in SgModel.connect()

        # Only need to ask one SgModel to draw the line.
        p1 = @port1Comp()
        p2 = @port2Comp()
        if p1 isnt p2 and p1.type isnt "SgIpTarget" and p2.type isnt "SgIpTarget"
          p1.vlineAddBatch( p2 )
      else
        # One caveat of SgRuleSet is that: Most SgLines mean there are SgRule between
        # two components, but SgLine of Elb means there are in-rule for Elb.
        # So each time, a SgRuleSet change from 0-in-rule to 1-in-rule. We need to see
        # if there are some Elb here. And if there's elb. update its SgLine.
        SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
        if (oldPort1InRuleCout + oldPort2OutRuleCout is 0) and (@get("in1").length + @get("out2").length > 0)
          for elb in @port1Comp().connectionTargets "SgAsso"
            if elb.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
              SgModel.tryDrawLine( elb )

        if (oldPort2InRuleCout + oldPort1OutRuleCout is 0) and (@get("in2").length + @get("out1").length > 0)
          for elb in @port2Comp().connectionTargets "SgAsso"
            if elb.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
              SgModel.tryDrawLine( elb )

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

      # Some bookkeeping to see if we need to remove some sglines.
      oldPort1InRuleCout  = @get("in1").length
      oldPort2InRuleCout  = @get("in2").length
      oldPort1OutRuleCout = @get("out1").length
      oldPort2OutRuleCout = @get("out2").length

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

      found = false
      for portionName in portions
        portion = @get( portionName )

        for existRule, idx in portion

          if existRule.fromPort is rule.fromPort and existRule.toPort is rule.toPort and existRule.protocol is rule.protocol
            portion = portion.slice(0)
            portion.splice( idx, 1 )
            found = true
            @set portionName, portion
            break

      if @get("in1").length + @get("in2").length + @get("out1").length + @get("out2").length is 0
        @remove()
      else
        # One caveat of SgRuleSet is that: Most SgLines mean there are SgRule between
        # two components, but SgLine of Elb means there are in-rule for Elb.
        # So each time, a SgRuleSet change from 0-in-rule to 1-in-rule. We need to see
        # if there are some Elb here. And if there's elb. update its SgLine.
        SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )

        if (@get("in1").length + @get("out2").length is 0) and (oldPort1InRuleCout + oldPort2OutRuleCout > 0)
          for elb in @port1Comp().connectionTargets "SgAsso"
            if elb.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
              sgline.validate() for sgline in elb.connections("SgRuleLine")

        if (@get("in2").length + @get("out1").length is 0) and (oldPort2InRuleCout + oldPort1OutRuleCout > 0)
          for elb in @port2Comp().connectionTargets "SgAsso"
            if elb.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
              sgline.validate() for sgline in elb.connections("SgRuleLine")

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

      ports = ""+ruleObj.port
      if ports.indexOf("/") >= 0
        ports = ports.split("/")
      else
        ports = ports.split("-")

      ruleObj.fromPort = ports[0]
      ruleObj.toPort   = ports[1] or ""

      @removeRawRule( owner, ruleObj.direction, ruleObj )
      null

    serialize : ( components )->
      sg1 = @port1Comp()
      sg2 = @port2Comp()

      sg1Ref = sg1.createRef( "GroupId" )
      sg2Ref = if sg2.type is "SgIpTarget" then sg2.get("name") else sg2.createRef( "GroupId" )

      portions = [
        {
          ary    : @get("in1")
          owner  : components[ sg1.id ].resource.IpPermissions
          target : sg2Ref
        }
        {
          ary    : @get("out1")
          owner  : components[ sg1.id ].resource.IpPermissionsEgress
          target : sg2Ref
        }]

      if sg2.type isnt "SgIpTarget" and sg1 isnt sg2
        portions.push {
          ary    : @get("in2")
          owner  : components[ sg2.id ].resource.IpPermissions
          target : sg1Ref
        }
        portions.push {
          ary    : @get("out2")
          owner  : components[ sg2.id ].resource.IpPermissionsEgress
          target : sg1Ref
        }

      for portion in portions
        for rule in portion.ary
          portion.owner.push {
            FromPort   : rule.fromPort
            ToPort     : if rule.toPort then rule.toPort else rule.fromPort
            IpRanges   : portion.target
            IpProtocol : if rule.protocol is "all" then "-1" else rule.protocol
          }
      null

  }, {

    getResourceSgRuleSets : ( resource )->

      sgRuleMap = {}
      sgRuleAry = []

      # Find out what SG is used by this resource
      for sg in resource.connectionTargets("SgAsso")

        # Find out what rules has in this sg
        for ruleset in sg.connections( "SgRuleSet" )
          # Remove duplicate SgRuleSets
          if sgRuleMap[ ruleset.id ] then continue
          sgRuleMap[ ruleset.id ] = true

          sgRuleAry.push ruleset

      sgRuleAry

    # Get an array of SgRuleSet. All the rulesets are releated to both
    # res1 and res2
    getRelatedSgRuleSets : ( res1, res2 )->

      res1SgMap = {}

      # In classic, every elb associates to SgIpTarget( "amazon-elb/amazon-elb-sg" )
      if Design.instance().typeIsClassic()
        if res2.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
          res1 = temp
          res1 = res2
          res2 = temp

        if res1.type is constant.AWS_RESOURCE_TYPE.AWS_ELB
          SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
          amazon_elb_sg = SgModel.getClassicElbSg()
          res1SgMap[ amazon_elb_sg.id ] = true

      # Find out res1's RuleSets
      for sg in res1.connectionTargets("SgAsso")
        res1SgMap[ sg.id ] = true

      # Find out what Ruleset affects both resource
      foundRuleSet = []
      for sg in res2.connectionTargets("SgAsso")
        for ruleset in sg.connections("SgRuleSet")
          if res1SgMap[ ruleset.getOtherTarget( sg ).id ]
            foundRuleSet.push ruleset

      _.uniq foundRuleSet

    # Get plain objects from an ruleset array.
    # The objects are guaranteed to be unique
    getPlainObjFromRuleSets : ( sgRuleAry )->

      ruleMap = {}
      rules   = []
      for rule in sgRuleAry
        ruleString = rule.direction + rule.target + rule.protocol + rule.port
        if ruleMap[ ruleString ] then continue

        ruleMap[ ruleString ] = true
        rules.push rule

      rules

    getGroupedObjFromRuleSets : ( rulesetArray )->
      tempMap = {}

      for ruleset in rulesetArray
        ipTarget = ruleset.getTarget( "SgIpTarget" )
        if ipTarget and not ipTarget.isClassicElbSg()
          continue

        comp = ruleset.port1Comp()
        id   = comp.id
        if not tempMap[ id ]
          tempMap[ id ] = {
            ownerId    : id
            ownerName  : comp.get("name")
            ownerColor : comp.color
            rules      : []
          }

        comp = ruleset.port2Comp()
        id   = comp.id
        if not tempMap[ id ]
          tempMap[ id ] = {
            ownerId    : id
            ownerName  : comp.get("name")
            ownerColor : comp.color
            rules      : []
          }

        for plainObj in ruleset.toPlainObjects( null, true )
          tempMap[ plainObj.ownerId ].rules.push plainObj

      arr = []
      for uid, group of tempMap
        if group.rules.length
          arr.push group

      arr.sort (a,b)->
        if a.ownerName is "DefaultSG" then return -1
        if b.ownerName is "DefaultSG" then return 1
        if a.ownerName <  b.ownerName then return -1
        if a.ownerName >  b.ownerName then return 1
        return 0
  }

  SgRuleSet.DIRECTION = {
    BIWAY : "biway"
    IN    : "inbound"
    OUT   : "outbound"
  }

  SgRuleSet


