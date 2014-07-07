
define [ "constant"
         "Design"
         "../GroupModel"
         "../connection/RtbAsso"
         "../ConnectionModel"
         "i18n!/nls/lang.js"
], ( constant, Design, GroupModel, RtbAsso, ConnectionModel, lang )->

  SbAsso = ConnectionModel.extend {
    type : "SbAsso"

    constructor: ( p1Comp, p2Comp, attr, option ) ->
      ConnectionModel.prototype.constructor.apply @, arguments
      null

    initialize: ( attr, option ) ->
      @draw = @updateToolTip

    remove : ()->
      ConnectionModel.prototype.remove.apply this, arguments
      @updateToolTip()
      null

    updateToolTip : ()->
      m = @getTarget(constant.RESTYPE.DBSBG)
      if m and m.__view
        m.__view.updateTooltip()
      null
  }

  Model = GroupModel.extend {

    type    : constant.RESTYPE.DBSBG
    newNameTmpl : "subnet-group"

    defaults :
      x      : 2
      y      : 2
      width  : 17
      height : 17

      subnetIds: []


    initialize: ( attributes, option )->
      # Draw the node
      @draw(true)
      if not @get 'description'
        @set 'description', "#{@get('name')} default description"

      null

    constructor: -> GroupModel.prototype.constructor.apply @, arguments



    isRemovable: () -> !@children().length

    serialize: ()->
      sbArray = _.map @connectionTargets("SbAsso"), ( sb )-> sb.createRef( "SubnetId" )

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CreatedBy               : @get 'appId'
          DBSubnetGroupName       : @get 'name'
          SubnetIds               : sbArray
          DBSubnetGroupDescription: @get 'description'


      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.DBSBG

    deserialize : ( data, layout_data, resolve )->

      model = new Model {

        id          : data.uid
        name        : data.name || data.resource.DBSubnetGroupName
        appId       : data.resource.CreatedBy

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
