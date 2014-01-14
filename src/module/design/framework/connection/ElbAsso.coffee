
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
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      }
      {
        port1 :
          name : "elb-sg-out"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      }
      {
        port1 :
          name : "elb-sg-out"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : "ExpandedAsg"
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
          return

      new ElbSubnetAsso( subnet, elb )
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
