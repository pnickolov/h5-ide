
define [ "constant", "ConnectionModel", "i18n!/nls/lang.js", "Design", "component/sgrule/SGRulePopup" ], ( constant, ConnectionModel, lang, Design, SGRulePopup )->

  # Elb <==> Subnet
  ElbSubnetAsso = ConnectionModel.extend {

    type : "ElbSubnetAsso"

    defaults :
      deserialized : false # Indicate that this line is created by deserialize.


    portDefs : [
      {
        port1 :
          name : "elb-assoc"
          type : constant.RESTYPE.ELB
        port2 :
          name : "subnet-assoc-in"
          type : constant.RESTYPE.SUBNET
      }
    ]

    initialize : ()->
      # Elb can only connect to one subnet in one az
      newSubnet = @getTarget( constant.RESTYPE.SUBNET )
      az = newSubnet.parent()

      for cn in @getTarget( constant.RESTYPE.ELB ).connections( "ElbSubnetAsso" )
        if cn.getTarget( constant.RESTYPE.SUBNET ).parent() is az
          if cn.hasAppUpdateRestriction()
            @setDestroyAfterInit()
          else
            cn.remove()

      null

    hasAppUpdateRestriction : ()->
      elb = @getTarget( constant.RESTYPE.ELB )

      if @design().modeIsAppEdit() and @get("deserialized")
        # In AppEdit, prevent the last existing asso to be deleted
        for asso in elb.connections( "ElbSubnetAsso" )
          if asso isnt @ and asso.get("deserialized")
            return false

        return true

      false

    isRemovable : ()->
      if @design().modeIsAppEdit()
        if @hasAppUpdateRestriction()
          return { error : lang.CANVAS.ERR_DEL_ELB_LINE_2 }

      elb    = @getTarget( constant.RESTYPE.ELB )
      subnet = @getTarget( constant.RESTYPE.SUBNET )
      az     = subnet.parent()

      # 1. Find out if any child of this subnet connects to the elb
      for child in elb.connectionTargets( "ElbAmiAsso" )
        childAZ = child.parent()
        while childAZ
          if childAZ.type is constant.RESTYPE.AZ
            break
          childAZ = childAZ.parent()
        if not childAZ then continue
        if childAZ is az
          connected = true
          break

      if not connected then return true

      # 2. Find out if there's other subnet in my az connects to the elb
      for sb in elb.connectionTargets( "ElbSubnetAsso" )
        if sb isnt subnet and sb.parent() is az
          connected = false
          break

      if connected then return { error : lang.CANVAS.ERR_DEL_ELB_LINE_2 }
      true

  }, {
    # isConnectable : ( comp1, comp2 )->
    #   subnet = if comp1.type is constant.RESTYPE.SUBNET then comp1 else comp2

    #   if parseInt( subnet.get("cidr").split("/")[1] , 10 ) <= 27
    #     return true

    #   lang.CANVAS.WARN_CANNOT_CONNECT_SUBNET_TO_ELB
  }

  # Elb <==> Ami
  ElbAmiAsso = ConnectionModel.extend {

    type : "ElbAmiAsso"

    portDefs : [
      {
        port1 :
          name : "elb-sg-out"
          type : constant.RESTYPE.ELB
        port2 :
          name : "instance-sg"
          type : constant.RESTYPE.INSTANCE
      }
      {
        port1 :
          name : "elb-sg-out"
          type : constant.RESTYPE.ELB
        port2 :
          name : "launchconfig-sg"
          type : constant.RESTYPE.LC
      }
      {
        port1 :
          name : "elb-sg-out"
          type : constant.RESTYPE.ELB
        port2 :
          name : "launchconfig-sg"
          type : "ExpandedAsg"
      }
    ]

    initialize : ( attibutes, option )->
      # When an Elb is connected to an Instance. Make sure the Instance's AZ has at least one subnet connects to Elb
      ami = @getOtherTarget( constant.RESTYPE.ELB )
      elb = @getTarget( constant.RESTYPE.ELB )

      if ami.type is constant.RESTYPE.LC
        @listenTo ami, "change:expandedList", @updateLcSubnetAsso
        @listenTo ami, "change:connections",  @updateLcSubnetAssoIfNeeded

        # Only update subnet when the asso is created by user
        if option.createByUser
          @updateLcSubnetAsso()
        return

      else
        connectedSbs = elb.connectionTargets("ElbSubnetAsso")

        for sb in ami.parent().parent().children()
          if connectedSbs.indexOf( sb ) isnt -1
            # Found a subnet in this AZ that is connected to the Elb, do nothing
            foundSubnet = true
            break

        if not foundSubnet
          new ElbSubnetAsso( ami.parent(), elb )

        return

    updateLcSubnetAssoIfNeeded : ( cn )-> if cn.type is "LcUsage" then @updateLcSubnetAsso()
    updateLcSubnetAsso : ()->
      # Do nothing if the design is deserializing.
      if @design().initializing() then return

      elb = @getTarget( constant.RESTYPE.ELB )
      lc  = @getTarget( constant.RESTYPE.LC )
      azs = lc.design().componentsOfType( constant.RESTYPE.AZ )
      azMap = {}
      for az in azs
        azName = az.get("name")
        for subnet in az.children()
          for e in subnet.connectionTargets( "ElbSubnetAsso" )
            if e is elb
              azMap[ azName ] = true
              break
          if azMap[ azName ] then break

      for asg in lc.connectionTargets("LcUsage")
        asgs = asg.get("expandedList").slice(0)
        asgs.push( asg )
        for asg in asgs
          azName = asg.parent().parent().get("name")
          if not azMap[ azName ]
            new ElbSubnetAsso( asg.parent(), elb )
            azMap[ azName ] = true

      return

    serialize : ( components )->
      instance = @getTarget( constant.RESTYPE.INSTANCE )
      if not instance then return
      elb = @getTarget( constant.RESTYPE.ELB )

      instanceArray = components[ elb.id ].resource.Instances

      for i in instance.getRealGroupMemberIds()
        instanceArray.push { InstanceId : @createRef( "InstanceId", i ) }
      null
  }, {
    isConnectable : ( comp1, comp2 )->
      if comp1.design().modeIsAppEdit()
        if comp1.type is constant.RESTYPE.LC
          lc = comp1
        else if comp2.type is constant.RESTYPE.LC
          lc = comp2

        if lc and lc.get("appId")
          return lang.NOTIFY.WARN_ASG_CAN_ONLY_CONNECT_TO_ELB_ON_LAUNCH

      true
  }

  null
