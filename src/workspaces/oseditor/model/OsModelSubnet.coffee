
define [ "GroupModel", "constant" ], ( GroupModel, constant )->

  Model = GroupModel.extend {

    type : constant.RESTYPE.OSSUBNET
    newNameTmpl : "Subnet-"

    defaults :
      public : false

    serialize : ()->
      {
        layout : @generateLayout()
        component :
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            id   : @get("appId")
            name : @get("name")

            cidr        : @get("cidr")
            network_id  : "@{#{@parent().id}.resource.id}"
            gateway_ip  : ""
            ip_version  : ""
            enable_dhcp : ""
            allocation_pools :
              start : "192.168.199.2"
              end   : "192.168.199.254"
      }

  }, {

    handleTypes  : constant.RESTYPE.OSSUBNET

    deserialize : ( data, layout_data, resolve )->
      new Model({
        id    : data.uid
        name  : data.resource.name
        appId : data.resource.id

        parent : resolve( MC.extractID(data.resource.network_id) )

        cidr : data.resource.cidr

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })
      return
  }

  Model
