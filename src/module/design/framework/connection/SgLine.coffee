
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  # SgRuleLine is used to draw lines in canvas
  SgRuleLine = ConnectionModel.extend {

    ### env:dev ###
    initialize : ()->
      console.assert( @port1Comp() isnt @port2Comp(), "Sgline should connect to different resources." )
    ### env:dev:end ###

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


