
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
        name : "rtb-src"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable

    serialize : ( components )->
      # Do nothing if the line is implicit
      if @get("implicit") then return

      sb  = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
      rtb = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )

      rtb_data = components[ rtb.id ]

      rtb_data.resource.AssociationSet.push {
        SubnetId: sb.createRef( "SubnetId" )
        RouteTableAssociationId : @get("assoId") or ""
        Main : false
      }
      null

    remove : ()->
      # When an RtbAsso is removed, and its subnet still remains and the subnet has no
      # other RtbAsso, connects the subnet to the mainRTB.
      subnet = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )

      if not subnet.isRemoved()
        subnetRtbAsso = subnet.connections("RTB_Asso")

        if subnetRtbAsso.length is 0 or (subnetRtbAsso.length is 1 and subnetRtbAsso[0] is this)

          oldRtb = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )

          if oldRtb.get("main")
            # the RtbAsso will not be removed if the Rtb is MainRTB
            # But will set implicit to true
            @set "implicit", true
            return

          # Call base class to remove the line.
          ConnectionModel.prototype.remove.apply this, arguments

          # Connects to mainRTB
          RtbModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable )
          newRtb   = RtbModel.getMainRouteTable()

          # If the user disconnect the subent <=> mainRtb,
          # we must pass in { detectDuplicate : false } to disable ConnectionManager
          # to find duplicate connection, because at this time, the disconnecting
          # connection is not considered "Removed".
          new C( subnet, newRtb, { implicit : true } )
          return

      ConnectionModel.prototype.remove.apply this, arguments
      null
  }

  C
