
define [ "../GroupModel", "./VpcModel", "constant", "i18n!nls/lang.js" ], ( GroupModel, VpcModel, constant, lang )->

  Model = GroupModel.extend {

    type : constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

    defaults :
      x      : 2
      y      : 2
      width  : 21
      height : 21

    initialize : ( attribute, option )->
      if option.createByUser and Design.instance().typeIsVpc()
        SubnetModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet )
        m = new SubnetModel( { x : @x() + 2, y : @y() + 2, parent : this } )
        ####
        # Quick hack to allow user to select another item,
        # instead of the newly created one.
        ####
        option.selectId = m.id

      @draw(true)
      null

    isRemovable : ()->
      if @children().length > 0
        # Return a warning, so that AZ's children will not be checked. ( Otherwise, Subnet will be check if it's connected to an ELB )
        return sprintf lang.ide.CVS_CFM_DEL_GROUP, @get("name")
      true

    getSubnetOfDefaultVPC : ()-> Model.getSubnetOfDefaultVPC( @get("name") )

    createRef : ()-> Model.__super__.createRef( "ZoneName", true, @id )

    isCidrEnoughForIps : ( cidr )->

      if not cidr
        defaultSubnet = @getSubnetOfDefaultVPC()
        if defaultSubnet
          cidr = defaultSubnet.cidrBlock
        else
          return true

      ipCount = 0
      for child in @children()
        if child.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
          eni = child.getEmbedEni()
        else if child.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
          eni = child
        else
          continue

        ipCount += eni.get("ips").length

      maxIpCount = MC.aws.eni.getAvailableIPCountInCIDR( cidr )
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
    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

    diffJson : ()-> # Disable diff for this Model

    getSubnetOfDefaultVPC : (azName) ->
      MC.data.account_attribute[ Design.instance().region() ].default_subnet[ azName ]

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

      zones = MC.data.config[ Design.instance().region() ].zone
      if zones
        for z in zones.item
          if not azMap.hasOwnProperty( z.zoneName )
            azMap[ z.zoneName ] = ""

      azArr = []
      for azName, id of azMap
        azArr.push {
          name : azName
          id   : id
        }

      azArr


    getAzByName : ( name )->
      for az in Model.allObjects()
        if az.get("name") is name
          return az
      null
  }

  Model
