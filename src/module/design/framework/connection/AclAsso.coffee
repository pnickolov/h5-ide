
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {
    type : "ACL_Asso"
    oneToMany : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkAcl
  }

  C


