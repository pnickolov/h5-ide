
define [ "CanvasManager",
         "Design",
         "constant",
         "../ComplexResModel",
         "./VpcModel",
         "./SgModel",
         "../connection/SgAsso",
         "../connection/ElbAsso"
], ( CanvasManager, Design, constant, ComplexResModel, VpcModel, SgModel, SgAsso )->

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

    constructor : ( attr, option )->

      dontCreateSg = attr.dontCreateSg
      delete attr.dontCreateSg

      ComplexResModel.call this, attr, option

      if dontCreateSg isnt true
        sg = new SgModel({
          name : @get("name")+"-sg"
          description : "Automatically created SG for load-balancer"
        })
        sg.setAsElbSg()
        @__elbSg = sg

      null

    initialize : ()->
      vpc = VpcModel.theVPC()
      if vpc
        vpc.addChild( @ )
      null

    getElbSg : ()-> @__elbSg

    setName : ( name )->
      if @get("name") is name
        return

      @set "name", name
      # Update Elb's Sg's Name
      @__elbSg.set( "name", name+"-sg" )

      if @draw then @draw()
      null

    getHealthCheckTarget : ()->
      # Format ping
      pingArr  = @attributes.healthCheckTarget.split(":")
      protocol = pingArr[0]

      pingArr  = (pingArr[1] || "").split("/")
      port     = parseInt( pingArr[0], 10 )

      if isNaN( port ) then port = 80

      path = if pingArr.length is 2 then pingArr[1] else "index.html"

      [ protocol, port, path ]

    setHealthCheckTarget : ( protocol, port, path )->
      target = @getHealthCheckTarget()
      if protocol
        target[0] = protocol

      if port isnt undefined
        target[1] = port

      if path isnt undefined
        target[2] = path

      @set "healthCheckTarget", target[0] + ":" + target[1] + "/" + target[2]
      null

    iconUrl : ()->
      "ide/icon/elb-" + (if @get("internal") then "internal-canvas.png" else "internet-canvas.png")

    setInternal : ( isInternal )->
      @set "internal", !!isInternal
      @draw()

      if isInternal
        # Redraw SG Line
        SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
        SgModel.tryDrawLine( @ )

      else
        # Hide Sg Line when set to internal
        for line in @connections("SgRuleLine")
          line.remove()
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

      # Toggle left port
      CanvasManager.toggle node.children(".port-elb-sg-in"), @get("internal")

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_ELB

    deserialize : ( data, layout_data, resolve )->
      attr =
        id    : data.uid
        name  : data.name
        appId : data.resource.LoadBalancerName

        dontCreateSg : true

        internal  : data.resource.Scheme is 'internal'
        crossZone : !!data.resource.CrossZoneLoadBalancing

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]

      elb = new Model attr

      ElbAmiAsso    = Design.modelClassForType( "ElbAmiAsso" )
      ElbSubnetAsso = Design.modelClassForType( "ElbSubnetAsso" )

      # Elb <=> Subnet
      for sg in data.resource.SecurityGroups || []
        new SgAsso( elb, resolve( MC.extractID(sg) ) )

      # Elb <=> Ami
      for ami in data.resource.Instances || []
        new ElbAmiAsso( elb, resolve( MC.extractID(ami.InstanceId) ) )

      # Elb <=> Subnet
      for sb in data.resource.Subnets || []
        new ElbSubnetAsso( elb, resolve( MC.extractID(sb)  ) )

      null

    postDeserialize : ( data, layout_data )->

      elb = Design.instance().component( data.uid )

      # Find out which SG is this Elb's Sg
      sgName = elb.get("name") + "-sg"
      for sg in SgModel.allObjects()
        if sg.get("name") is sgName
          elb.__elbSg = sg
          sg.setAsElbSg()
          return
  }

  Model
