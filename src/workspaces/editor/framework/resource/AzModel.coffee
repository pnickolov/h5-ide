
define [ "../GroupModel", "./VpcModel", "constant", "i18n!nls/lang.js", "Design", "CloudResources" ], ( GroupModel, VpcModel, constant, lang, Design, CloudResources )->

  Model = GroupModel.extend {

    type : constant.RESTYPE.AZ

    defaults :
      x      : 2
      y      : 2
      width  : 21
      height : 21

    initialize : ( attribute, option )->
      if option.createByUser
        SubnetModel = Design.modelClassForType( constant.RESTYPE.SUBNET )
        m = new SubnetModel( { x : @x() + 2, y : @y() + 2, parent : this } )
        ####
        # Quick hack to allow user to select another item,
        # instead of the newly created one.
        ####
        option.selectId = m.id

      @draw(true)
      null

    setName : ()->
      GroupModel.prototype.setName.apply this, arguments
      @design().trigger Design.EVENT.AzUpdated
      return

    isRemovable : ()->
      if @children().length > 0
        # Return a warning, so that AZ's children will not be checked. ( Otherwise, Subnet will be check if it's connected to an ELB )
        return sprintf lang.ide.CVS_CFM_DEL_GROUP, @get("name")
      true

    createRef : ()-> Model.__super__.createRef( "ZoneName", true, @id )

    isCidrEnoughForIps : ( cidr )->

      if not cidr then return true

      ipCount = 0
      for child in @children()
        if child.type is constant.RESTYPE.INSTANCE
          eni = child.getEmbedEni()
        else if child.type is constant.RESTYPE.ENI
          eni = child
        else
          continue

        ipCount += eni.get("ips").length

      maxIpCount = Design.modelClassForType(constant.RESTYPE.ENI).getAvailableIPCountInCIDR( cidr )
      maxIpCount >= ipCount

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

    diffJson : ()-> # Disable diff for this Model

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.name

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
