
define [ "GroupModel", "constant" ], ( GroupModel, constant )->

  Model = GroupModel.extend {

    type : constant.RESTYPE.OSSUBNET
    newNameTmpl : "Subnet-"

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          id   : @get("appId")
          name : @get("name")

          network_id     : ""
          gateway_ip     : ""
          ip_version     : ""
          cidr           : ""
          enable_dhcp    : ""
          admin_state_up : ""
          shared         : ""
          allocation_pools :
            start : "192.168.199.2"
            end   : "192.168.199.254"

      { component : component }

  }, {

    handleTypes  : constant.RESTYPE.OSSUBNET

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        parent : resolve( MC.extractID(data.resource.network_id) )

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })
      return
  }

  Model
