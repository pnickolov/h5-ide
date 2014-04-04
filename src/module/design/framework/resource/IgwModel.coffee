
define [ "../ComplexResModel", "./VpcModel", "Design", "constant", "i18n!nls/lang.js" ], ( ComplexResModel, VpcModel, Design, constant, lang )->

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 8
      height   : 8
      name     : "Internet-gateway"

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

    initialize : ()->
      @draw(true)
      null

    isRemovable : ()->
      # Deleting IGW when ELB/EIP in VPC, should show error
      ElbModel   = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_ELB )
      cannotDel  = ElbModel.allObjects().some ( elb )-> not elb.get("internal")

      if not cannotDel
        EniModel   = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface )
        cannotDel  = EniModel.allObjects().some ( eni )-> eni.hasEip() or eni.get("assoPublicIp")

      if cannotDel
        return { error : lang.ide.CVS_CFM_DEL_IGW }

      true

    serialize : ()->

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          InternetGatewayId : @get("appId")
          AttachmentSet     : [{ VpcId : @parent().createRef( "VpcId" ) }]

      { component : component, layout : @generateLayout() }

  }, {

    tryCreateIgw : ()->
      if not Design.instance().typeIsVpc() then return

      if Model.allObjects().length > 0 then return

      notification 'info', lang.ide.CVS_CFM_ADD_IGW_MSG
      resource_type = constant.AWS_RESOURCE_TYPE

      vpc = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_VPC ).theVPC()

      igwW = Model.prototype.defaults.width
      igwH = Model.prototype.defaults.height
      vpcX = vpc.x()
      vpcY = vpc.y()
      vpcH = vpc.height()

      new Model({
        x : vpcX - igwW / 2
        y : vpcY + ( vpcH - igwH ) / 2
        parent : vpc
      })
      null

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.InternetGatewayId
        parent : resolve( layout_data.groupUId )

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model

