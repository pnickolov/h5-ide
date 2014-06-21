
define [ "constant", "../ConnectionModel" ], ( constant, ConnectionModel )->

  C = ConnectionModel.extend {

    type : "RTB_Asso"

    oneToMany : constant.RESTYPE.RT

    defaults :
      lineType : "association"
      implicit : false

    portDefs :
      port1 :
        name : "subnet-assoc-out"
        type : constant.RESTYPE.SUBNET
      port2 :
        name : "rtb-src"
        type : constant.RESTYPE.RT

    serialize : ( components )->
      # Do nothing if the line is implicit
      if @get("implicit") then return

      sb  = @getTarget( constant.RESTYPE.SUBNET )
      rtb = @getTarget( constant.RESTYPE.RT )

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
      subnet = @getTarget( constant.RESTYPE.SUBNET )

      if not subnet.isRemoved()
        subnetRtbAsso = subnet.connections("RTB_Asso")

        if subnetRtbAsso.length is 0 or (subnetRtbAsso.length is 1 and subnetRtbAsso[0] is this)

          oldRtb = @getTarget( constant.RESTYPE.RT )

          if oldRtb.get("main")
            # the RtbAsso will not be removed if the Rtb is MainRTB
            # But will set implicit to true
            @set "implicit", true
            return

          # Call base class to remove the line.
          ConnectionModel.prototype.remove.apply this, arguments

          # Connects to mainRTB
          RtbModel = Design.modelClassForType( constant.RESTYPE.RT )
          newRtb   = RtbModel.getMainRouteTable()

          # If the user disconnect the subnet <=> mainRtb,
          # we must pass in { detectDuplicate : false } to disable ConnectionManager
          # to find duplicate connection, because at this time, the disconnecting
          # connection is not considered "Removed".
          new C( subnet, newRtb, { implicit : true } )
          return

      ConnectionModel.prototype.remove.apply this, arguments
      null
  }

  C
