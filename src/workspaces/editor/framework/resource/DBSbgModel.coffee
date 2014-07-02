
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

    initialize : ( attributes, option )->
      # Draw the node
      @draw(true)

      null

    constructor: -> GroupModel.prototype.constructor.apply @, arguments



    isRemovable : () -> !@children().length

    serialize : ()->

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          AvailabilityZone : @parent().createRef()
          VpcId            : @parent().parent().createRef( "VpcId" )
          SubnetId         : @get("appId")
          CidrBlock        : @get("cidr")

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.DBSBG

    deserialize : ( data, layout_data, resolve )->

      new Model {

        id          : data.uid
        name        : data.name || data.DBSubnetGroupName

        description : data.DBSubnetGroupDescription
        status      : data.DBSubnetGroupName

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]

        parent : resolve( layout_data.groupUId )
      }

      null
  }

  Model
