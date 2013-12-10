#############################
#  View Mode for design/property/rtb
#############################

define [ '../base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

  RTBModel = PropertyModel.extend {

    setName : ( name )->
      Design.instance().component( @get("uid") ).setName( name )
      null

    setMainRT : () ->

      uid = @get 'uid'


      for id, comp of MC.canvas_data.component
        if comp.type isnt constant.AWS_RESOURCE_TYPE.AWS_VPC_RouteTable
          continue

        if comp.resource.AssociationSet.length and "" + comp.resource.AssociationSet[0].Main is 'true'
          comp.resource.AssociationSet.splice 0, 1
          MC.canvas.update comp.uid, 'image', 'rt_status', MC.canvas.IMAGE.RT_CANVAS_NOT_MAIN


      asso =
        "Main"                    : "true"
        "RouteTableId"            : ""
        "SubnetId"                : ""
        "RouteTableAssociationId" : ""

      comp = MC.canvas_data.component[ uid ]
      comp.resource.AssociationSet.splice 0, 0, asso
      MC.canvas.update uid, 'image', 'rt_status', MC.canvas.IMAGE.RT_CANVAS_MAIN

      MC.aws.rtb.updateRT_SubnetLines()

      @init( uid )
      null

    reInit : () ->
      @init( @get( "uid" ) )
      null

    init : ( uid ) ->

      design    = Design.instance()

      component = design.component( uid )
      res_type  = constant.AWS_RESOURCE_TYPE

      # uid might be a line connecting RTB and other resource
      if component.get("connection")
        subnet    = component.getTarget( res_type.AWS_VPC_Subnet )
        component = component.getTarget( res_type.AWS_VPC_RouteTable )

        if subnet
          @set {
            title : 'Subnet-RT Association'
            association :
              subnet : subnet.get("name")
              rtb    : component.get("name")
          }
          return

      VPCModel = Design.modelClassForType( res_type.AWS_VPC_VPC )

      # If this is RTB or this is RTB blue lines, show RTB property
      routes = []
      data =
        uid         : uid
        title       : component.get("name")
        isMain      : component.get("main")
        local_route : VPCModel.theVPC().get("cidr")
        routes      : routes

      for cn in component.connections()
        if cn.type isnt "RTB_Route"
          continue

        theOtherPort = cn.getOtherTarget( res_type.AWS_VPC_RouteTable )

        routes.push {
          name     : theOtherPort.get("name")
          isVgw    : theOtherPort.type is res_type.AWS_VPC_VPNGateway
          isProp   : cn.get("propagate")
          cidr_set : cn.get("routes")
        }

      @set data
      true

    setPropagation : ( value ) ->

      uid = @get 'uid'

      vgw_set = MC.canvas_data.component[uid].resource.PropagatingVgwSet

      vgw_ref = '@' + value + '.resource.VpnGatewayId'

      if vgw_set.length == 0

        vgw_set.push vgw_ref

      else
        MC.canvas_data.component[uid].resource.PropagatingVgwSet = []

      null

    setRoutes : ( data, routes ) ->

      uid = @get 'uid'

      # remove all routes
      delete_idx = []

      switch data.type

        when 'gateway'

          $.each MC.canvas_data.component[uid].resource.RouteSet, ( idx, route ) ->

            if route.GatewayId == data.ref

              delete_idx.push idx

        when 'instance'

          $.each MC.canvas_data.component[uid].resource.RouteSet, ( idx, route ) ->

            if route.InstanceId == data.ref

              delete_idx.push idx

        when 'eni'

          $.each MC.canvas_data.component[uid].resource.RouteSet, ( idx, route ) ->

            if route.NetworkInterfaceId == data.ref

              delete_idx.push idx

      delete_idx.sort ( x, y )->

        if x <= y
          return 1

        else
          return -1

      $.each delete_idx, ( i, v ) ->

        MC.canvas_data.component[uid].resource.RouteSet.splice v, 1


      # add all routes
      $.each routes, ( idx, route ) ->

        if route.children[1].children[0].value != ''

          route_tmpl = {
            'DestinationCidrBlock'      :   route.children[1].children[0].value,
            'GatewayId'                 :   '',
            'InstanceId'                :   '',
            'InstanceOwnerId'           :   '',
            'NetworkInterfaceId'        :   '',
            'State'                     :   '',
            'Origin'                    :   ''
          }

          switch data.type

            when 'gateway'

              route_tmpl.GatewayId = data.ref

            when 'instance'

              route_tmpl.InstanceId = data.ref

            when 'eni'

              route_tmpl.NetworkInterfaceId = data.ref


          MC.canvas_data.component[uid].resource.RouteSet.push route_tmpl
  }

  new RTBModel()
