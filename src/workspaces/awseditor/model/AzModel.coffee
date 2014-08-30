
define [ "GroupModel", "constant", "i18n!/nls/lang.js", "Design", "CloudResources" ], ( GroupModel, constant, lang, Design, CloudResources )->

  Model = GroupModel.extend {

    type : constant.RESTYPE.AZ

    isRemovable : ()->
      if (_.some @children(), ( sb ) -> sb.connections("SubnetgAsso").length > 0)
        return { error : lang.ide.RDS_MSG_ERR_REMOVE_AZ_FAILED_CAUSEDBY_CHILD_USEDBY_SBG }

      if @children().length > 0
        # Return a warning, so that AZ's children will not be checked. ( Otherwise, Subnet will be check if it's connected to an ELB )
        return sprintf lang.ide.CVS_CFM_DEL_GROUP, @get("name")
      true

    createRef : ()-> Model.__super__.createRef( "ZoneName", true, @id )

    getAvailableIPCountInSubnet : ( cidr )->

      if not cidr then return true

      ipCount = 0
      for child in @children()
        if child.type is constant.RESTYPE.INSTANCE
          eni = child.getEmbedEni()
        else if child.type is constant.RESTYPE.ENI
          eni = child
        else
          continue

        ipCount += eni.get("ips").length * eni.serverGroupCount()

      maxIpCount = Design.modelClassForType(constant.RESTYPE.ENI).getAvailableIPCountInCIDR( cidr )
      maxIpCount - ipCount

    serialize : ()->
      n = @get("name")
      component =
        uid  : @id
        name : n
        type : @type
        resource :
          ZoneName : n
          RegionName : n.substring(0, n.length-1)

      { layout : @generateLayout(), component : component }

  }, {
    handleTypes : constant.RESTYPE.AZ

    deserialize : ( data, layout_data, resolve )->
      # If we are in app/appedit mode. Assign a appId to the AZ.
      # So that we can distinguish existing az from newly created one.
      if not Design.instance().modeIsStack()
        appId = data.name

      new Model({
        id    : data.uid
        name  : data.name
        appId : appId

        parent : resolve( layout_data.groupUId )

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })
      null

    # Get all az, including unused az.
    allPossibleAZ : ()->
      azMap = {}
      for az in Model.allObjects()
        azMap[ az.get("name") ] = az.id

      CloudResources( constant.RESTYPE.AZ, region ).where({category:region}).map (az)->
        {
          name : az.attributes.id
          id   : azMap[ az.attributes.id ] || ""
        }

    getAzByName : ( name )->
      for az in Model.allObjects()
        if az.get("name") is name
          return az
      null
  }

  Model
