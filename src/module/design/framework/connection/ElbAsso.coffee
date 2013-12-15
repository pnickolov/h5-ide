
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {

    type : "ElbAsso"

    defaults : ()->
      lineType : "elb-sg"

    portDefs : [
      {
        port1 :
          name : "elb-sg-out"
          type : constant.AWS_RESOURCE_TYPE.AWS_ELB
        port2 :
          name      : "launchconfig-sg"
          direction : "horizontal"
          type      : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
      }
    ]


  }

  C
