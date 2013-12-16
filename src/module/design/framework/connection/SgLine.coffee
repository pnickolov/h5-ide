
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  # SgRuleLine is used to draw lines in canvas
  SgRuleLine = ConnectionModel.extend {

    type : "SgRuleLine"

    defaults :
      lineType : "sg"
      dashLine : true

    portDefs :
      port1 :
        name : "subnet-assoc-out"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
      port2 :
        name      : "rtb-src"
        direction : "vertical"
        type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
  }

  SgRuleLine


