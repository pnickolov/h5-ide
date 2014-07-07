
define [ "../ComplexResModel", "./VpcModel", "Design", "constant" ], ( ComplexResModel, VpcModel, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 8
      height   : 8
      name     : "VPN-gateway"

    type : constant.RESTYPE.VGW

    serialize : ()->

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          Type         : "ipsec.1"
          VpnGatewayId : @get("appId")
          Attachments  : [{ VpcId : @parent().createRef( "VpcId" ) }]

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.VGW

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.VpnGatewayId
        parent : resolve( layout_data.groupUId )

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

      null

  }

  Model

