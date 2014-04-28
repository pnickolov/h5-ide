
define [ "constant", "../ConnectionModel", "i18n!nls/lang.js", "Design", "component/sgrule/SGRulePopup" ], ( constant, ConnectionModel, lang, Design, SGRulePopup )->

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

      else
        elb = @getTarget( constant.RESTYPE.ELB )
        # Elb should at least connects to a subnet if it connects to some ami
        if elb.connections( "ElbAmiAsso" ).length > 0 and elb.connections( "ElbSubnetAsso" ).length <= 1
          return { error : lang.ide.CVS_MSG_ERR_DEL_ELB_LINE_1 }

      true

  }, {
    isConnectable : ( comp1, comp2 )->
      subnet = if comp1.type is constant.RESTYPE.SUBNET then comp1 else comp2

      if parseInt( subnet.get("cidr").split("/")[1] , 10 ) <= 27
        return true

      lang.ide.CVS_MSG_WARN_CANNOT_CONNECT_SUBNET_TO_ELB
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

    initialize : ( attibutes, option )->
      if not Design.instance().typeIsVpc() then return

      # If the line is created by user, show a popup to let user to add sg
      if option and option.createByUser
        new SGRulePopup( this.id )

      # When an Elb is connected to an Instance. Make sure the Instance's AZ has at least one subnet connects to Elb
      ami = @getOtherTarget( constant.RESTYPE.ELB )
      elb = @getTarget( constant.RESTYPE.ELB )

      if elb.connections( "ElbSubnetAsso" ).length == 0
        subnet = ami.parent()
        while subnet.type isnt constant.RESTYPE.SUBNET
          subnet = subnet.parent()
        if subnet
          new ElbSubnetAsso( elb, subnet )

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

        for asg in lc.parent().get("expandedList")
          (new ElbAmiAsso( elb, asg )).remove( reason )

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
