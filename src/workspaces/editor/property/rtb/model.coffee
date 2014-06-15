#############################
#  View Mode for design/property/rtb
#############################

define [ '../base/model', "Design", 'constant', "CloudResources" ], ( PropertyModel, Design, constant, CloudResources ) ->

  RTBModel = PropertyModel.extend {

    defaults :
      'isAppEdit' : false

    setMainRT : () ->
      Design.instance().component( @get("uid") ).setMain()
      if @isAppEdit
        @setMainMessage( @get("uid") )
        @set 'isMain', Design.instance().component( @get("uid") ).get("main")
      null

    reInit : () ->
      @init( @get( "uid" ) )
      null

    init : ( uid ) ->

      design    = Design.instance()

      component = design.component( uid )
      res_type  = constant.RESTYPE

      # uid might be a line connecting RTB and other resource
      if component.node_line
        subnet    = component.getTarget( res_type.SUBNET )
        component = component.getTarget( res_type.RT )

        if subnet
          @set {
            title : 'Subnet-RT Association'
            association :
              subnet : subnet.get("name")
              rtb    : component.get("name")
          }
          return

      VPCModel = Design.modelClassForType( res_type.VPC )

      # If this is RTB or this is RTB blue lines, show RTB property
      routes = []
      data =
        uid         : component.id # The component is guarantee to be RTB at this point, and we assign the uid of the property to be the RTB id, because we might need to set attributes of the rtb.
        title       : component.get("name")
        isMain      : component.get("main")
        local_route : VPCModel.theVPC().get("cidr")
        routes      : routes
        isAppEdit   : @isAppEdit

      for cn in component.connections()
        if cn.type isnt "RTB_Route"
          continue

        theOtherPort = cn.getOtherTarget( res_type.RT )

        routes.push {
          name     : theOtherPort.get("name")
          type     : theOtherPort.type
          ref      : cn.id
          isVgw    : theOtherPort.type is res_type.VGW
          isProp   : cn.get("propagate")
          cidr_set : cn.get("routes")
        }

      routes = _.sortBy routes, "type"

      if @isAppEdit

        @set 'vpcId', component.parent().get('appId')

        @set 'routeTableId', component.get('appId')

        @setMainMessage( uid )



      @set data
      true

    setMainMessage : ( uid ) ->

      component = Design.instance().component(uid)

      appData = CloudResources(constant.RESTYPE.RT, Design.instance().region()).get(component.get('appId'))?.toJSON()
      aws_rt_is_main = false

      if appData and appData.associationSet and appData.associationSet.length

        for asso in appData.associationSet

          if asso.main is true

            aws_rt_is_main = true

      now_main_rtb = Design.modelClassForType( constant.RESTYPE.RT ).getMainRouteTable()

      if aws_rt_is_main and now_main_rtb.id isnt component.id

        @set 'main', 'Yes (Set as No after applying updates)'

      else if aws_rt_is_main and now_main_rtb.id is component.id

        @set 'main', 'Yes'

      else if not aws_rt_is_main and now_main_rtb.id is component.id

        @set 'main', 'No (Set as Yes after applying updates)'

      else

        @set 'main', 'No'

    setPropagation : ( propagate ) ->

      component = Design.instance().component( @get("uid") )

      # Only one vgw will be in a stack. So, RTB can only connects to one VPN
      cn = _.find component.connections(), ( cn )->
        cn.getTarget( constant.RESTYPE.VGW ) isnt null

      cn.setPropagate propagate
      null

    setRoutes : ( routeId, routes ) ->
      Design.instance().component( routeId ).set( "routes", routes )
      null

    isCidrConflict : ( inputValue, cidr )->
      Design.modelClassForType(constant.RESTYPE.SUBNET).isCidrConflict( inputValue, cidr )
  }

  new RTBModel()
