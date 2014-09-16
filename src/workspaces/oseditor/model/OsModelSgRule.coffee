
define [ "ComplexResModel", "constant" ], ( ComplexResModel, constant )->

  ComplexResModel.extend {

    type : constant.RESTYPE.OSSGRULE
    newNameTmpl : "SgRule-"

    defaults :
      direction : ""
      portMin   : ""
      portMax   : ""
      protocol  : ""
      sg        : null
      ip        : null
      appId     : ""

    setTarget : ( ipOrSgModel )->
      if typeof ip is "string"
        attr = {
          ip : ipOrSgModel
          sg : null
        }
      else
        attr = {
          ip : null
          sg : ipOrSgModel
        }

      @set attr
      return

    toJSON : ()->
      {
        direction        : @get( "direction" )
        port_range_min   : @get( "portMin" )
        port_range_max   : @get( "portMax" )
        protocol         : @get( "protocol" )
        remote_group_id  : @get( "sg" )?.createRef( "id" )
        remote_ip_prefix : @get( "ip" )
        id               : @get( "appId" )
      }

    fromJSON : ( json )->
      attr = @attributes

      attr.direction = json.direction
      attr.portMin   = json.port_range_min
      attr.portMax   = json.port_range_max
      attr.protocol  = json.protocol
      attr.sg        = json.remote_group_id
      attr.ip        = json.remote_ip_prefix
      attr.appId     = json.id
      return

  }
