
define [ "GroupModel", "constant" ], ( GroupModel, constant )->

  Model = GroupModel.extend {

    type : constant.RESTYPE.OSSUBNET
    newNameTmpl : "Subnet-"

    defaults: ()->
      public : false
      cidr   : ""
      dhcp   : true

    initialize: (attributes, option) ->

      if option.createByUser
        @set('cidr', @generateCidr())

    generateCidr : () ->

      currentVPCCIDR = '10.0.0.0/8'

      vpcCIDRAry      = currentVPCCIDR.split('/')
      vpcCIDRIPStr    = vpcCIDRAry[0]
      vpcCIDRIPStrAry = vpcCIDRIPStr.split('.')
      vpcCIDRSuffix   = Number(vpcCIDRAry[1])

      # get max subnet number
      maxSubnetNum = -1
      for comp in Model.allObjects()

        subnetCIDR       = comp.get("cidr")
        subnetCIDRAry    = subnetCIDR.split('/')
        subnetCIDRIPStr  = subnetCIDRAry[0]
        subnetCIDRSuffix = Number(subnetCIDRAry[1])
        subnetCIDRIPAry  = subnetCIDRIPStr.split('.')

        currentSubnetNum = Number(subnetCIDRIPAry[1])

        if maxSubnetNum < currentSubnetNum
          maxSubnetNum = currentSubnetNum

      resultSubnetNum = maxSubnetNum + 1
      if resultSubnetNum > 255 then return ""

      vpcCIDRIPStrAry[1] = String(resultSubnetNum)
      vpcCIDRIPStrAry.join('.') + '/16'

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
