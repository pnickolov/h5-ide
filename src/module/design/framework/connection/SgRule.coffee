
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  # SgRuleConnection is used to represent the connection between two SecurityGroup or Sg and Ip
  SgRule = ConnectionModel.extend {

    type : "SgRule"

    default :
      fromPort  : "0"
      toPort    : "65535"
      protocol  : "-1"

      ###
      |-------|   in1        out2   |-------|
      |       |  <=====     <=====  |       |
      | PORT1 |                     | PORT2 |
      |       |  =====>     =====>  |       |
      |-------|   out1        in2   |-------|
      ###

      in1  : false # Port1 accept in from Port2
      out1 : false # Port1 permit out to  Port2

      in2  : false # Port2 accept in from Port1
      out2 : false # Port2 permit out to  port1

    port : ()->
      fromPort = @get("fromPort")
      toPort   = @get("toPort")
      if fromPort is toPort
        return fromPort
      else
        return fromPort + "-" + toPort

    toPlainObjects : ( filter )->
      port     = @port()
      protocol = @get("protocol")
      if protocol is "-1" then protocol = "all"

      objects = []
      if not filter or filter( @port1Comp() )
        o = {
          port      : port
          protocol  : protocol
          target    : @port2Comp().get("name")
          color     : @port2Comp().color
          direction : SgRule.DIRECTION.IN
        }
        if @attributes.in1
          objects.push o
        if @attributes.out1
          objects.push $.extend( {}, o, {direction : SgRule.DIRECTION.OUT} )

      # Do not generate plain object if port1 is port2.
      # Because this rule means self reference
      if @port1Comp().id isnt @port2Comp().id and ( not filter or filter( @port2Comp() ) )
        o = {
          port      : port
          protocol  : protocol
          target    : @port1Comp().get("name")
          color     : @port1Comp().color
          direction : SgRule.DIRECTION.IN
        }
        if @attributes.in2
          objects.push o
        if @attributes.out2
          objects.push $.extend( {}, o, {direction : SgRule.DIRECTION.OUT} )

      objects

    setIn  : ( resource, enable ) ->
      console.assert( resource.id is @port1Comp().id or resource.id is @port2Comp().id, "This sg rule is not for target:", resource )

      isIPRule = @port1Comp.type is "SgIpTarget" or @port2Comp.type is "SgIpTarget"

      if @port1Comp().id is @port2Comp().id
        o = { in1 : enable, in2 : enable }

      else if resource.id is @port1Comp().id
        o = { in1 : enable }
        # Make two port fully connected if one port is IP
        if isIPRule then o.out2 = enable
      else
        o = { in2 : enable }
        if isIPRule then o.out1 = enable

      @set o
      null

    setOut : ( resource, enable ) ->
      console.assert( resource.id is @port1Comp().id or resource.id is @port2Comp().id, "This sg rule is not for target:", resource )

      isIPRule = @port1Comp.type is "SgIpTarget" or @port2Comp.type is "SgIpTarget"

      if @port1Comp().id is @port2Comp().id
        o = { out1 : enable, out2 : enable }

      else if resource.id is @port1Comp().id
        o = { out1 : enable }
        if isIPRule then o.in2 = enable
      else
        o = { out2 : enable }
        if isIPRule then o.in1 = enable

      @set o
      null

    setDirection : ( resource, direction )->
      console.assert( direction is SgRule.DIRECTION.BIWAY or direction is SgRule.DIRECTION.PORT1_IN or direction is SgRule.DIRECTION.PORT1_OUT, "Invalid direction for sgrule")

      if direction is SgRule.DIRECTION.BIWAY or @port1Comp().id is @port2Comp().id
        @set {
          in1 : true, out1 : true
          in2 : true, out2 : true
        }
        return

      if resource.id is @port1Comp().id
        in1 = direction is SgRule.DIRECTION.IN
      else
        in1 = direction is SgRule.DIRECTION.OUT

      @set {
        in1 : in1,     out1 : not in1
        in2 : not in1, out2 : in1
      }
      null

    addDirection : ( resource, direction )->
      console.assert( direction is SgRule.DIRECTION.BIWAY or direction is SgRule.DIRECTION.PORT1_IN or direction is SgRule.DIRECTION.PORT1_OUT, "Invalid direction for sgrule")

      # Port1Comp is Port2Comp means self reference
      if direction is SgRule.DIRECTION.BIWAY or @port1Comp().id is @port2Comp().id
        @set {
          in1 : true, out1 : true
          in2 : true, out2 : true
        }
        return

      if direction is SgRule.DIRECTION.IN
        if resource.id is @port1Comp().id
          @set { in1 : true, out2 : true }
        else
          @set { in2 : true, out1 : true }
      else
        if resource.id is @port1Comp().id
          @set { in2 : true, out1 : true }
        else
          @set { in1 : true, out2 : true }
      null
  }, {

    getResourceSgRule : ( resource )->

      sgAssos   = resource.connections("SgAsso")
      sgRuleMap = {}
      sgRuleAry = []

      for sgAsso in sgAssos
        # Find out what SG is used by this resource
        sg = sgAsso.getTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )

        # Find out what rules has in this sg
        for rule in sg.connections( "SgRule" )
          # Remove duplicate SgRules
          if sgRuleMap[ rule.id ] then continue
          sgRuleMap[ rule.id ] = true

          sgRuleAry.push rule

      sgRuleAry
  }

  SgRule.DIRECTION = {
    BIWAY : "biway"
    IN    : "inbound"
    OUT   : "outbound"
  }

  SgRule


