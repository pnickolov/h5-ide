
define [ "ComplexResModel", "constant" ], ( ComplexResModel, ConnectionModel, constant )->

  Model = ComplexResModel.extend {

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
        name  : data.name
        appId : data.resource.id
      })
      return
  }

  Model
