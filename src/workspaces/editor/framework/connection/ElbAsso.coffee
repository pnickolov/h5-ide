
define [ "constant", "../ConnectionModel", "i18n!/nls/lang.js", "Design", "component/sgrule/SGRulePopup" ], ( constant, ConnectionModel, lang, Design, SGRulePopup )->

  # Elb <==> Subnet
  ElbSubnetAsso = ConnectionModel.extend {

    type : "ElbSubnetAsso"

    defaults :
      lineType     : "association"
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

      if @design().modeIsAppEdit()
        # In AppEdit, prevent the last existing asso to be deleted
        for asso in elb.connections( "ElbSubnetAsso" )
          if asso isnt @ and asso.get("deserialized")
            return false

        return true

      false

    isRemovable : ()->
      if @design().modeIsAppEdit()
        if @hasAppUpdateRestriction()
          return { error : lang.ide.CVS_MSG_ERR_DEL_ELB_LINE_2 }

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

      if connected then return { error : lang.ide.CVS_MSG_ERR_DEL_ELB_LINE_2 }
      true

  }, {
    # isConnectable : ( comp1, comp2 )->
    #   subnet = if comp1.type is constant.RESTYPE.SUBNET then comp1 else comp2

    #   if parseInt( subnet.get("cidr").split("/")[1] , 10 ) <= 27
    #     return true

    #   lang.ide.CVS_MSG_WARN_CANNOT_CONNECT_SUBNET_TO_ELB
  }

  # Elb <==> Ami
  ElbAmiAsso = ConnectionModel.extend {

    type : "ElbAmiAsso"

    defaults : ()->
      lineType : "elb-sg"

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

    constructor: ( p1Comp, p2Comp, attr, option ) ->

      # # #
      # Quick hack for disable elb connect to a running asg
      #

      if p1Comp.design().modeIsAppEdit() and
          ((p1Comp.type is constant.RESTYPE.LC and p1Comp.get('appId')) or (p2Comp.type is constant.RESTYPE.LC and p2Comp.get('appId')))

        notification "error", lang.ide.NOTIFY_MSG_WARN_ASG_CAN_ONLY_CONNECT_TO_ELB_ON_LAUNCH
        return
      #
      # #
      # # #

      ConnectionModel.prototype.constructor.apply @, arguments

    initialize : ( attibutes, option )->
      # If the line is created by user, show a popup to let user to add sg
      if option and option.createByUser
        new SGRulePopup( this.id )

      # When an Elb is connected to an Instance. Make sure the Instance's AZ has at least one subnet connects to Elb
      ami = @getOtherTarget( constant.RESTYPE.ELB )
      elb = @getTarget( constant.RESTYPE.ELB )

      subnet = ami
      while true
        subnet = subnet.parent()
        if not subnet then return
        if subnet.type is constant.RESTYPE.SUBNET
          break

      connectedSbs = elb.connectionTargets("ElbSubnetAsso")

      for sb in subnet.parent().children()
        if connectedSbs.indexOf( sb ) isnt -1
          # Found a subnet in this AZ that is connected to the Elb, do nothing
          foundSubnet = true
          break

      if not foundSubnet
        new ElbSubnetAsso( subnet, elb )

      # If there's a ElbAsso created for Lc and Elb
      # We also try to connect the Elb to any expanded Asg
      if ami.type is constant.RESTYPE.LC
        for asg in ami.parent().get("expandedList")
          new ElbAmiAsso( asg, elb )
      null

    remove : ( option )->
      # If the line is not deleted by the user or because of the Lc is removed.
      # Then we do nothing.
      if option and option.reason.type isnt constant.RESTYPE.LC
        ConnectionModel.prototype.remove.apply this, arguments
        return

      # The ElbAsso is removed by the user.
      expAsg = @getTarget "ExpandedAsg"
      if expAsg and not expAsg.isRemoved()
        # If the user is removing an ElbAsso from Elb to ExpandedAsg.
        # Then we just delete the ElbAsso from Elb to Lc
        elb = @getTarget( constant.RESTYPE.ELB )
        lc  = expAsg.getLc()
        (new ElbAmiAsso( elb, lc )).remove()
        return

      lc = @getTarget constant.RESTYPE.LC
      if lc
        # The user is removing an ElbAsso from Elb to Lc
        # Remove all the shadow ElbAsso from Elb to ExpandedAsg
        elb    = @getTarget( constant.RESTYPE.ELB )
        reason = { reason : this }

        asg = lc.parent()

        for eAsg in asg.get("expandedList")
          (new ElbAmiAsso( elb, eAsg )).remove( reason )

      ConnectionModel.prototype.remove.apply this, arguments
      null

    serialize : ( components )->
      instance = @getTarget( constant.RESTYPE.INSTANCE )
      if not instance then return
      elb = @getTarget( constant.RESTYPE.ELB )

      instanceArray = components[ elb.id ].resource.Instances

      for i in instance.getRealGroupMemberIds()
        instanceArray.push { InstanceId : @createRef( "InstanceId", i ) }
      null
  }

  null
