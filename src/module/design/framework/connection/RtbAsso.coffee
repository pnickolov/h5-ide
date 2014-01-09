
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {

    type : "RTB_Asso"
    oneToMany : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

    defaults :
      lineType : "association"
      implicit : false

    portDefs :
      port1 :
        name : "subnet-assoc-out"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
      port2 :
        name      : "rtb-src"
        direction : "vertical"
        type      : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

    serialize : ( components )->
      sb  = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
      rtb = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )

      rtb_data = components[ rtb.id ]

      rtb_data.resource.AssociationSet.push {
        SubnetId: "@#{sb.id}.resource.SubnetId"
        RouteTableId : ""
        Main : false
        RouteTableAssociationId : ""
      }
      null
  }

  C
