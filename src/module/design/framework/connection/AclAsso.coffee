
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {
    type : "ACL_Asso"
    manyToOne : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
  }

  C


