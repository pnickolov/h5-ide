
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  # Elb <==> Subnet
  ConnectionModel.extend {

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
  }

  # Elb <==> Ami
  ConnectionModel.extend {

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
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
      }
      {
        port1 :
          name : "elb-sg-out"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name      : "instance-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      }
    ]
  }

  null
