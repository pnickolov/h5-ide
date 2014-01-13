
define [ "../ComplexResModel", "CanvasManager", "./VpcModel", "Design", "constant", "i18n!nls/lang.js" ], ( ComplexResModel, CanvasManager, VpcModel, Design, constant, lang )->

  Model = ComplexResModel.extend {

    defaults :
      x        : 0
      y        : 0
      width    : 8
      height   : 8
      name     : "Internet-gateway"

    type : constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

    initialize : ()->
      VpcModel.theVPC().addChild( this )

      @draw(true)

      @listenTo Design.instance(), Design.EVENT.AwsResourceUpdated, @draw
      null

    isRemovable : ()->
      # Deleting IGW when ELB/EIP in VPC, should show error
      ElbModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_ELB )
      cannotDel = ElbModel.allObjects().some ( elb )-> not elb.get("internal")

      if not cannotDel
        EniModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface )
        cannotDel = EniModel.allObjects().some ( eni )-> eni.hasEip()

      if cannotDel
        return { error : lang.ide.CVS_CFM_DEL_IGW }

      true

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

        # Call parent's createNode to do basic creation
        node = @createNode({
          image   : "ide/icon/igw-canvas.png"
          imageX  : 10
          imageY  : 16
          imageW  : 60
          imageH  : 46
          label   : @get("name")
        })

        node.append(
          # Port
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-igw-tgt'
            'class'      : 'port port-blue port-igw-tgt'
            'transform'  : 'translate(70, 30)' + MC.canvas.PORT_LEFT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            'data-name'     : 'igw-tgt'
            'data-position' : 'right'
            'data-type'     : 'sg'
            'data-direction': 'in'
          })
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()


      # Update Resource State in app view
      if not Design.instance().modeIsStack() and @.get("appId")
        @updateState()

      null


    serialize : ()->

      layout =
        coordinate : [ @x(), @y() ]
        uid        : @id
        groupUId   : @parent().id

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          InternetGatewayId : @get("appId")
          AttachmentSet     : [{
            State : "available"
            VpcId : "@#{@parent().id}.resource.VpcId"
          }]

      { component : component, layout : layout }

  }, {

    tryCreateIgw : ()->
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
      })
      null

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

    deserialize : ( data, layout_data, resolve )->

      new Model({

        id    : data.uid
        name  : data.name
        appId : data.resource.InternetGatewayId

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })

  }

  Model

