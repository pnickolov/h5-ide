
define [ "../ComplexResModel", "CanvasManager", "Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 17
      height   : 10
      bgpAsn   : ""

    newNameTmpl : "customer-gateway-"

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

    isDynamic : ()-> !!@get("bgpAsn")

    serialize : ()->
      layout =
        uid        : @id
        coordinate : [ @x(), @y() ]

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CustomerGatewayId : @get("appId")
          BgpAsn            : @get("bgpAsn")
          State             : "available"
          Type              : "ipsec.1"
          IpAddress         : @get("ip")

      { component : component, layout : layout }

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_CustomerGateway

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

