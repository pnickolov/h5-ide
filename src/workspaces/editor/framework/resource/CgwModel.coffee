
define [ "../ComplexResModel", "Design", "constant" ], ( ComplexResModel, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      bgpAsn : ""

    newNameTmpl : "customer-gateway-"

    type : constant.RESTYPE.CGW

    isDynamic : ()-> !!@get("bgpAsn")

    serialize : ()->
      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CustomerGatewayId : @get("appId")
          BgpAsn            : @get("bgpAsn")
          Type              : "ipsec.1"
          IpAddress         : @get("ip")

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.CGW

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.CustomerGatewayId
        bgpAsn : data.resource.BgpAsn
        ip     : data.resource.IpAddress

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model

