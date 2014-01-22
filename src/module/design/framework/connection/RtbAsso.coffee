
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {

    type : "RTB_Asso"

    defaults :
      lineType : "association"
      implicit : false

    portDefs :
      port1 :
        name : "subnet-assoc-out"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
      port2 :
        name : "rtb-src"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

    initialize : ()->
      for asso in @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet ).connections( "RTB_Asso" )
        if asso isnt this
          asso.remove( this )
      null

    serialize : ( components )->
      # Do nothing if the line is implicit
      if @get("implicit") then return

      sb  = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
      rtb = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )

      rtb_data = components[ rtb.id ]

      rtb_data.resource.AssociationSet.push {
        SubnetId: sb.createRef( "SubnetId" )
        RouteTableId : ""
        Main : false
        RouteTableAssociationId : ""
      }
      null

    remove : ( reason )->
      # If no reason, it means the user try to delete the line.
      # So we connect the subnet to MainRTB
      if not reason
        subnet = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
        oldRtb = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )

        # When an RtbAsso is disconnected create a connection between this subnet and mainRtb
        RtbModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )
        newRtb   = RtbModel.getMainRouteTable()

        # If the user disconnect the subent <=> mainRtb,
        # we must pass in { detectDuplicate : false } to disable ConnectionManager
        # to find duplicate connection, because at this time, the disconnecting
        # connection is not considered "Removed".
        new C( subnet, newRtb, { implicit : true }, { detectDuplicate : oldRtb isnt newRtb } )
      null
  }

  C
