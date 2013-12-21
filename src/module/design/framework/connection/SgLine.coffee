
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  # SgRuleLine is used to draw lines in canvas
  SgRuleLine = ConnectionModel.extend {

    initialize : ()->
      console.assert( @port1Comp() isnt @port2Comp(), "Sgline should connect to different resources." )


      # If Eni is attached to Ami, then hide sg line
      ami = @getTarget constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      eni = @getTarget constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      if ami and eni
        for e in ami.connectionTargets( "EniAttachment" )
          if e is eni
            @setDestroyAfterInit()
            return

      # Only show sg line for inbound rules of elb
      # If the target is elb and the elb is internet-facing, don't show sgline
      elb = @getTarget constant.AWS_RESOURCE_TYPE.AWS_ELB
      if elb
        if not elb.get("internal")
          @setDestroyAfterInit()
        else
          elbSgMap  = {}
          hasInRule = false
          for sg in elb.connectionTargets( "SgAsso" )
            elbSgMap[ sg.id ] = sg

          for sg in @getOtherTarget( elb ).connectionTargets( "SgAsso" )
            for ruleset in sg.connections( "SgRuleSet" )
              target = ruleset.getOtherTarget( sg )
              if not elbSgMap[ target.id ] then continue

              if ruleset.hasRawRuleTo( elbSgMap[ target.id ] )
                hasInRule = true
                break
            if hasInRule
              break

          if not hasInRule
            @setDestroyAfterInit()

      null


    type : "SgRuleLine"

    defaults :
      lineType : "sg"
      dashLine : true

    portDefs : [

      # Instance
      {
        port1 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      }
      {
        port1 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      }
      {
        port1 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "elb-sg-in"
          type      : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }

      # Eni
      {
        port1 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
        port2 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }
      {
        port1 :
          name      : "elb-sg-in"
          type      : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name      : "eni-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      }

      # LC
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      }
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name      : "elb-sg-in"
          type      : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }

      # Elb
      {
        port1 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
        port2 :
          name      : "elb-sg-in"
          type      : constant.AWS_RESOURCE_TYPE.AWS_ELB
      }
    ]
  }

  SgRuleLine


