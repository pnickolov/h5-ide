
define [ "constant", "../GroupModel", "../ConnectionModel" ], ( constant, GroupModel, ConnectionModel )->

  SbAsso = ConnectionModel.extend {
    type : "SubnetgAsso"
  }


  Model = GroupModel.extend {

    type    : constant.RESTYPE.DBSBG
    newNameTmpl : "subnet-group"

    defaults :
      x      : 2
      y      : 2
      width  : 17
      height : 17

      createdBy: ""

    constructor : ()->
      # If we don't have enough subnet. Don't create the subnet group.
      design = Design.instance()
      az = {}
      for subnet in design.componentsOfType(constant.RESTYPE.SUBNET)
        az[ subnet.parent().get("name") ] = true

      if _.keys( az ).length < 2
        return this

      GroupModel.apply this, arguments

    initialize: ( attributes, option )->

      if not @get 'description'
        @set 'description', "#{@get('name')} default description"

      null

    serialize: ()->
      sbArray = _.map @connectionTargets("SubnetgAsso"), ( sb )-> sb.createRef( "SubnetId" )

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CreatedBy               : @get 'createdBy'
          DBSubnetGroupName       : @get 'appId'
          SubnetIds               : sbArray
          DBSubnetGroupDescription: @get 'description'


      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.DBSBG

    deserialize : ( data, layout_data, resolve )->

      model = new Model {

        id          : data.uid
        name        : data.name || data.resource.DBSubnetGroupName
        appId       : data.resource.DBSubnetGroupName
        createdBy   : data.resource.CreatedBy

        description : data.resource.DBSubnetGroupDescription

        x           : layout_data.coordinate[0]
        y           : layout_data.coordinate[1]
        width       : layout_data.size[0]
        height      : layout_data.size[1]

        parent : resolve( layout_data.groupUId )
      }


      # Asso Subnet
      for sb in data.resource.SubnetIds || []
        new SbAsso( model, resolve( MC.extractID(sb) ) )

      null
  }

  Model
