
define [ "../ComplexResModel", "./VpcModel", "Design", "constant", "i18n!/nls/lang.js" ], ( ComplexResModel, VpcModel, Design, constant, lang )->

  Model = ComplexResModel.extend {

    defaults :
      name : "Internet-gateway"

    type : constant.RESTYPE.IGW

    isRemovable : ()->
      # Deleting IGW when ELB/EIP in VPC, should show error
      ElbModel   = Design.modelClassForType( constant.RESTYPE.ELB )
      cannotDel  = ElbModel.allObjects().some ( elb )-> not elb.get("internal")

      if not cannotDel
        EniModel   = Design.modelClassForType( constant.RESTYPE.ENI )
        cannotDel  = EniModel.allObjects().some ( eni )-> eni.hasEip() or eni.get("assoPublicIp")

      if not cannotDel
        LcModel = Design.modelClassForType( constant.RESTYPE.LC )
        cannotDel = LcModel.allObjects().some ( lc )-> lc.get("publicIp")

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
      if Model.allObjects().length > 0 then return

      notification 'info', lang.ide.CVS_CFM_ADD_IGW_MSG

      vpc = Design.modelClassForType( constant.RESTYPE.VPC ).theVPC()
      new Model({
        x      : -1
        y      : -1
        parent : vpc
      })
      null

    handleTypes : constant.RESTYPE.IGW

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

