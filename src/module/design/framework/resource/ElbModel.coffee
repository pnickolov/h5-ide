
define [ "../ComplexResModel", "../CanvasManager", "Design", "./VpcModel", "../connection/SgAsso", "constant", "../connection/ElbAsso"  ], ( ComplexResModel, CanvasManager, Design, VpcModel, SgAsso, constant )->

  Model = ComplexResModel.extend {

    defaults : ()->
      {
        x        : 0
        y        : 0
        width    : 9
        height   : 9

        internal  : true
        crossZone : false

        # HealthCheck
        healthyThreshold    : "9"
        unHealthyThreshold  : "4"
        healthCheckTarget   : "HTTP:80/index.html"
        healthCheckInterval : "30"
        healthCheckTimeout  : "5"

        # Listener
        listeners : []
      }

    type : constant.AWS_RESOURCE_TYPE.AWS_ELB
    newNameTmpl : "load-balancer-"

    initialize : ()->
      vpc = VpcModel.theVPC()
      if vpc
        vpc.addChild( @ )
      null

    iconUrl : ()->
      "ide/icon/elb-" + (if @get("internal") then "internal-canvas.png" else "internet-canvas.png")

    setInternal : ( isInternal )->
      @set "internal", !!isInternal
      @draw()
      null

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

        # Call parent's createNode to do basic creation
        node = @createNode({
          image  : @iconUrl()
          imageX : 9
          imageY : 11
          imageW : 70
          imageH : 53
          label  : @get "name"
          sg     : not design.typeIsClassic()
        })

        # Port
        if not design.typeIsClassic()
          node.append(
            # Left
            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-elb-sg-in'
              'class'      : 'port port-blue port-elb-sg-in'
              'transform'  : 'translate(2, 30)' + MC.canvas.PORT_RIGHT_ROTATE
              'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            }),
            # Right gray
            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-elb-assoc'
              'class'      : 'port port-gray port-elb-assoc'
              'transform'  : 'translate(79, 45)' + MC.canvas.PORT_RIGHT_ROTATE
              'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            })
          )

        node.append(
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-elb-sg-out'
            'class'      : 'port port-blue port-elb-sg-out'
            'transform'  : 'translate(79, 15)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
          })
        )

        # Move the node to right place
        $("#node_layer").append node
        CanvasManager.position node, @x(), @y()

      else
        node = $( document.getElementById( @id ) )
        # Update label
        CanvasManager.update node.children(".node-label"), @get("name")

        # Update Image
        CanvasManager.update node.children("image"), @iconUrl(), "href"

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_ELB

    deserialize : ( data, layout_data, resolve )->

      elb = new Model({

        id           : data.uid
        name         : data.name

        internal  : data.resource.Scheme is 'internal'
        crossZone : !!data.resource.CrossZoneLoadBalancing

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]

      })

      if data.resource.SecurityGroups
        for sg in data.resource.SecurityGroups
          new SgAsso( elb, resolve( MC.extractID( sg ) ) )

      if data.resource.Instances
        InstanceModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance )
        ElbAmiAsso = Design.modelClassForType( "ElbAmiAsso" )

        for ami in data.resource.Instances
          new ElbAmiAsso( elb, resolve( MC.extractID( ami.InstanceId ) ) )

      if data.resource.Subnets
        ElbSubnetAsso = Design.modelClassForType( "ElbSubnetAsso" )
        for sb in data.resource.Subnets
          new ElbSubnetAsso( elb, resolve( MC.extractID sb  ) )

      null
  }

  Model
