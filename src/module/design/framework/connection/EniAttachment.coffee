
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {

    lineType : "attachment"

    portDefs :
      port1 :
        name : "instance-attach"
        type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

      port2 :
        name : "eni-attach"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

  }

  C
