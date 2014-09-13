
define [ "GroupModel", "constant" ], ( GroupModel, constant )->

  Model = GroupModel.extend {

    type : constant.RESTYPE.OSSUBNET
    newNameTmpl : "Subnet-"

    defaults :
      public : false
      cidr   : ""
      dhcp   : true

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
            enable_dhcp : @get("dhcp")
            network_id  : @parent().createRef("id")
            gateway_ip  : ""
            ip_version  : "4"
            allocation_pools : {
              #start : "192.168.199.2"
              #end   : "192.168.199.254"
            }
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
        dhcp : data.resource.enable_dhcp

        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]
        width  : layout_data.size[0]
        height : layout_data.size[1]
      })
      return
  }

  Model
