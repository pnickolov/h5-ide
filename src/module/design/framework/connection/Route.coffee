
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {

    defaults : ()->
      lineType : "rtb-target"
      dashLine : true
      routes   : []

    portDefs : [
      {
        port1 :
          name : "igw-tgt"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway
        port2 :
          name      : "rtb-tgt"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
      }
      {
        port1 :
          name : "instance-rtb"
          type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        port2 :
          name      : "rtb-tgt"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
      }
      {
        port1 :
          name : "eni-rtb"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
        port2 :
          name      : "rtb-tgt"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
      }
      {
        port1 :
          name : "vgw-tgt"
          type : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway
        port2 :
          name      : "rtb-tgt"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
      }
    ]


  }

  C
