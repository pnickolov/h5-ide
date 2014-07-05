
define [ "constant",
         "Design",
         "../GroupModel",
         "../connection/RtbAsso",
         "i18n!/nls/lang.js"
], ( constant, Design, GroupModel, RtbAsso, lang )->

  Model = GroupModel.extend {

    type    : constant.RESTYPE.DBSBG
    newNameTmpl : "subnet-group"

    defaults :
      x      : 2
      y      : 2
      width  : 17
      height : 17

      subnetIds: []


    initialize : ( attributes, option )->
      # Draw the node
      @draw(true)
      if not @get 'description'
        @set 'description', "#{@get('name')} default description"

      null

    constructor: -> GroupModel.prototype.constructor.apply @, arguments



    isRemovable : () -> !@children().length

    serialize : ()->
      subnetIds = @get 'subnetIds'
      subnetArray = []
      Design.modelClassForType(constant.RESTYPE.SUBNET).each (sb) ->
        if sb.get('name') in subnetIds
          subnetArray.push sb.createRef( "SubnetId" )

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CreatedBy               : @get 'appId'
          DBSubnetGroupName       : @get 'name'
          SubnetIds               : subnetArray
          DBSubnetGroupDescription: @get 'description'


      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.DBSBG

    deserialize : ( data, layout_data, resolve )->

      new Model {

        id          : data.uid
        name        : data.name || data.resource.DBSubnetGroupName
        appId       : data.resource.CreatedBy

        description : data.resource.DBSubnetGroupDescription
        subnetIds   : data.resource.SubnetIds

        x           : layout_data.coordinate[0]
        y           : layout_data.coordinate[1]
        width       : layout_data.size[0]
        height      : layout_data.size[1]

        parent : resolve( layout_data.groupUId )
      }

      null
  }

  Model
