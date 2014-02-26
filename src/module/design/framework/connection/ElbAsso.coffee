
define [ "constant", "../ConnectionModel", "i18n!nls/lang.js", "Design", "component/sgrule/SGRulePopup" ], ( constant, ConnectionModel, lang, Design, SGRulePopup )->

  # Elb <==> Subnet
  ElbSubnetAsso = ConnectionModel.extend {

    type : "ElbSubnetAsso"

    defaults : ()->
      lineType : "association"

    portDefs : [
      {
        port1 :
          name : "elb-assoc"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name : "subnet-assoc-in"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
      }
    ]

    initialize : ()->
      # Elb can only connect to one subnet in one az
      newSubnet = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
      az = newSubnet.parent()

      for cn in @getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB ).connections( "ElbSubnetAsso" )
        if cn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet ).parent() is az
          cn.remove()

      null

    isRemovable : ()->
      elb    = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB )
      subnet = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )

      # 1. Find out if any child of this subnet connects to the elb
      elbTargets = elb.connectionTargets( "ElbAmiAsso" )
      for child in subnet.children()
        if child.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
          child = child.get("lc")

        if elbTargets.indexOf( child ) isnt -1
          connected = true
          break

      if not connected then return true

      # 2. Find out if there's other subnet in my az connects to the elb
      connected = false
      for sb in elb.connectionTargets( "ElbSubnetAsso" )
        if sb isnt subnet and sb.parent() is subnet.parent()
          connected = true
          break

      if connected then return true

      return { error : lang.ide.CVS_MSG_ERR_DEL_ELB_LINE_2 }

    # serialize : ( components )->
    #   sb  = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
    #   elb = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB )

    #   components[ elb.id ].resource.Subnets.push sb.createRef( "SubnetId" )
    #   null

  }, {
    isConnectable : ( comp1, comp2 )->
      subnet = if comp1.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet then comp1 else comp2

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
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name : "instance-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      }
      {
        port1 :
          name : "elb-sg-out"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name : "launchconfig-sg"
          type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      }
      {
        port1 :
          name : "elb-sg-out"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
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
      ami = @getOtherTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB )
      elb = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB )

      subnet = ami
      while true
        subnet = subnet.parent()
        if not subnet then return
        if subnet.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
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
      if ami.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        for asg in ami.parent().get("expandedList")
          new ElbAmiAsso( asg, elb )
      null

    remove : ( option )->
      # If the line is not deleted by the user or because of the Lc is removed.
      # Then we do nothing.
      if option and option.reason.type isnt constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        ConnectionModel.prototype.remove.apply this, arguments
        return

      # The ElbAsso is removed by the user.
      expAsg = @getTarget "ExpandedAsg"
      if expAsg and not expAsg.isRemoved()
        # If the user is removing an ElbAsso from Elb to ExpandedAsg.
        # Then we just delete the ElbAsso from Elb to Lc
        elb = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB )
        lc  = expAsg.getLc()
        (new ElbAmiAsso( elb, lc )).remove()
        return

      lc = @getTarget constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      if lc
        # The user is removing an ElbAsso from Elb to Lc
        # Remove all the shadow ElbAsso from Elb to ExpandedAsg
        elb    = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB )
        reason = { reason : this }

        for asg in lc.parent().get("expandedList")
          (new ElbAmiAsso( elb, asg )).remove( reason )

      ConnectionModel.prototype.remove.apply this, arguments
      null

    serialize : ( components )->
      instance = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance )
      if not instance then return
      elb = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB )

      instanceArray = components[ elb.id ].resource.Instances

      for i in instance.getRealGroupMemberIds()
        instanceArray.push { InstanceId : @createRef( "InstanceId", i ) }
      null
  }

  null
