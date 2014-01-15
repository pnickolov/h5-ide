
define [ "CanvasManager",
         "Design",
         "constant",
         "../ResourceModel",
         "../ComplexResModel",
         "./VpcModel",
         "./SgModel",
         "../connection/SgAsso"
         "../connection/ElbAsso"
], ( CanvasManager, Design, constant, ResourceModel, ComplexResModel, VpcModel, SgModel, SgAsso )->

  Model = ComplexResModel.extend {

    defaults : ()->
      {
        x        : 0
        y        : 0
        width    : 9
        height   : 9

        internal  : if Design.instance().typeIsClassic() then false else true
        crossZone : false

        # HealthCheck
        healthyThreshold    : "9"
        unHealthyThreshold  : "4"
        healthCheckTarget   : "HTTP:80/index.html"
        healthCheckInterval : "30"
        healthCheckTimeout  : "5"

        # Listener
        listeners : [ {
          port             : "80"
          protocol         : "HTTP"
          instanceProtocol : "HTTP"
          instancePort     : "80"
        } ]

        # AvailabilityZones ( This attribute is used to store which AZ is attached to Elb in Classic ). It stores AZ's name, not reference
        AvailabilityZones : []
      }

    type : constant.AWS_RESOURCE_TYPE.AWS_ELB

    newNameTmpl : "load-balancer-"

    initialize : ( attr, option )->
      vpc = VpcModel.theVPC()
      if vpc then vpc.addChild( @ )

      @draw(true)

      if option.createByUser and not Design.instance().typeIsClassic()
        sg = new SgModel({
          name        : @get("name")+"-sg"
          isElbSg     : true
          description : "Automatically created SG for load-balancer"
        })
        @__elbSg = sg
        SgAssoModel = Design.modelClassForType( "SgAsso" )
        new SgAssoModel( this, sg )
      null

    remove : ()->
      sslCert = @get("sslCert")
      if sslCert then sslCert.remove()

      # Remove my elb sg, if the sg is not used by anyone.
      for elbSg in @.connectionTargets( "SgAsso" )
        if elbSg.isElbSg()
          cannotDelete = false
          for elb in elbSg.connectionTargets("SgAsso")
            if elb isnt this
              cannotDelete = true
              break
          if not cannotDelete
            elbSg.remove()
      null

    getElbSg : ()-> @__elbSg

    setName : ( name )->
      if @get("name") is name
        return

      @set "name", name

      if @__elbSg
        # Update Elb's Sg's Name
        @__elbSg.set( "name", name+"-sg" )

      if @draw then @draw()
      null

    setListener : ( idx, value )->
      console.assert( value.port and value.protocol and value.instanceProtocol and value.instancePort, "Invalid parameter for setListener" )

      listeners = @get("listeners")
      if idx >= listeners.length
        listeners.push value
      else
        listeners[ idx ] = $.extend {}, value

      null

    removeListener : ( idx ) ->
      if idx is 0 then return
      listeners = @get("listeners")
      listeners.splice( idx, 1 )
      @set "listeners", listeners
      null

    setSslCert : ( cert )->
      console.assert( cert.body isnt undefined and cert.chain isnt undefined and cert.key isnt undefined and cert.name isnt undefined, "Invalid parameter for setSslCert" )

      sslCert = @get("sslCert")
      if sslCert
        for key, value of cert
          sslCert.set(key, value)
      else
        sslCert = new ResourceModel( cert )
        @set("sslCert", sslCert)
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
          line.remove( this )
      null

    getCost : ( priceMap, currency )->
      if not priceMap.elb or not priceMap.elb.types
        return null

      for p in priceMap.elb.types
        if p.unit is "perELBHour"
          fee = parseFloat( p[ currency ], 10 ) || 0
          break

      if fee
        return {
          resource    : @get("name")
          type        : constant.AWS_RESOURCE_TYPE.AWS_ELB
          fee         : fee * 24 * 30
          formatedFee : fee + "/hr"
        }

    getAvailabilityZones : ()->
      if Design.instance().typeIsVpc()
        azs = _.map @connectionTargets("ElbSubnetAsso"), ( subnet )->
          subnet.parent().get("name")

        return _.uniq azs
      else
        azs = _.map @connectionTargets("ElbAmiAsso"), ( ami )->
          if ami.parent().type is constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
            return ami.parent().get("name")
          else
            return ami.parent().parent().get("name")

        return _.uniq azs.concat( @get("AvailabilityZones") )

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
              'data-name'     : 'elb-sg-in'
              'data-position' : 'left'
              'data-type'     : 'sg'
              'data-direction': "in"
            }),
            # Right gray
            Canvon.path(MC.canvas.PATH_D_PORT).attr({
              'id'         : @id + '_port-elb-assoc'
              'class'      : 'port port-gray port-elb-assoc'
              'transform'  : 'translate(79, 45)' + MC.canvas.PORT_RIGHT_ROTATE
              'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
              'data-name'     : 'elb-assoc'
              'data-position' : 'right'
              'data-type'     : 'association'
              'data-direction': 'out'
            })
          )

          sgOutY = 15
        else
          sgOutY = 30

        node.append(
          Canvon.path(MC.canvas.PATH_D_PORT).attr({
            'id'         : @id + '_port-elb-sg-out'
            'class'      : 'port port-blue port-elb-sg-out'
            'transform'  : 'translate(79, ' + sgOutY + ')' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            'data-name'     : 'elb-sg-out'
            'data-position' : 'right'
            'data-type'     : 'sg'
            'data-direction': 'out'
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


      # Update Resource State in app view
      if not Design.instance().modeIsStack() and @.get("appId")
        @updateState()

      null



    serialize : ()->
      layout =
        coordinate : [ @x(), @y() ]
        uid        : @id
        groupUId   : if @parent() then @parent().id else ""

      hcTarget = @get("healthCheckTarget")
      if hcTarget.indexOf("TCP") isnt -1 or hcTarget.indexOf("SSL") isnt -1
        # If target is TCP or SSL, remove path.
        hcTarget = hcTarget.split("/")[0]

      listeners = []
      if @get("sslCert")
        sslcertId = @get('sslCert').createRef("ServerCertificateMetadata.Arn")
      else
        sslcertId = ""

      for l in @get("listeners")
        if l.protocol is "SSL" or l.protocol is "HTTPS"
          id = sslcertId
        else
          id = ""

        listeners.push {
          PolicyNames : ""
          Listener :
            LoadBalancerPort : l.port
            Protocol         : l.protocol
            InstanceProtocol : l.instanceProtocol
            InstancePort     : l.instancePort
            SSLCertificateId : id
        }

      sgs = _.map @connectionTargets("SgAsso"), ( sg ) -> sg.createRef( "GroupId" )

      if Design.instance().typeIsClassic()
        subnets = []
      else
        # In defaultVpc, the subnet is created
        subnets = _.map @connectionTargets( "ElbAmiAsso" ), ( ami )-> ami.getSubnetRef()
        subnets = _.uniq( subnets )

      component =
        type : @type
        uid  : @id
        name : @get("name")
        resource :
          AvailabilityZones : @getAvailabilityZones()
          Subnets : subnets
          CanonicalHostedZoneNameID : ""
          CanonicalHostedZoneName : ""
          Instances : []
          CrossZoneLoadBalancing : @get("crossZone")
          VpcId                  : @getVpcRef()
          LoadBalancerName       : @get("name")
          SecurityGroups         : sgs

          Scheme : if @get("internal") then "internal" else "internet-facing"
          ListenerDescriptions : listeners
          HealthCheck :
            Interval               : @get("healthCheckInterval")
            Target                 : hcTarget
            Timeout                : @get("healthCheckTimeout")
            HealthyThreshold       : @get("healthyThreshold")
            UnhealthyThreshold     : @get("unHealthyThreshold")
          DNSName : ""
          Policies: {
              LBCookieStickinessPolicies : [{ PolicyName : "", CookieExpirationPeriod : "" }]
              AppCookieStickinessPolicies : [{ PolicyName : "", CookieName : ""}]
              OtherPolicies : []
            }
          BackendServerDescriptions : [ { InstantPort : "", PoliciyNames : "" } ]
          SourceSecurityGroup : { OwnerAlias : "", GroupName : "" }
          #reserved
          CreatedTime  : ""

      json_object = { component : component, layout : layout }

      if @get("sslCert")
        ssl = @get("sslCert")
        sslComponent =
          uid : ssl.id
          type : "AWS.IAM.ServerCertificate"
          name : ssl.get("name")
          resource :
            PrivateKey : ssl.get("key")
            CertificateBody : ssl.get("body")
            CertificateChain : ssl.get("chain")
            ServerCertificateMetadata :
              ServerCertificateName : ssl.get("name")
              Arn : ssl.get("arn")
              ServerCertificateId : ""
              UploadDate : ""
              Path : ""
        return [ json_object, { component : sslComponent } ]
      else
        return json_object

  }, {

    handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_ELB, constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate ]

    deserialize : ( data, layout_data, resolve )->

      # Handle Certificate
      if data.type is constant.AWS_RESOURCE_TYPE.AWS_IAM_ServerCertificate
        cert = new ResouceModel({
          uid   : data.uid
          name  : data.name
          body  : data.resource.CertificateBody
          chain : data.resource.CertificateChain
          key   : data.resource.PrivateKey
          arn   : data.resource.ServerCertificateMetadata.Arn
        })
        return

      # Handle Elb
      attr =
        id    : data.uid
        name  : data.name
        appId : data.resource.LoadBalancerName

        internal  : data.resource.Scheme is 'internal'
        crossZone : !!data.resource.CrossZoneLoadBalancing
        listeners : []

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]

      # AZ is used in classic mode
      attr.AvailabilityZones = _.map data.resource.AvailabilityZones || [], ( azRef )->
        # azRef might be azName
        if azRef[0] is "@"
          return resolve( MC.extractID( azRef ) ).get("name")
        else
          return azRef

      elb = new Model( attr )

      # listener
      for l in data.resource.ListenerDescriptions || []
        l = l.Listener
        attr.listeners.push {
          port             : l.LoadBalancerPort
          protocol         : l.Protocol
          instanceProtocol : l.InstanceProtocol
          instancePort     : l.InstancePort
        }
        if l.SSLCertificateId
          attr.sslCert = resolve( MC.extractID( l.SSLCertificateId ) )

      ElbAmiAsso    = Design.modelClassForType( "ElbAmiAsso" )
      ElbSubnetAsso = Design.modelClassForType( "ElbSubnetAsso" )

      # Elb <=> Sg
      for sg in data.resource.SecurityGroups || []
        new SgAsso( elb, resolve( MC.extractID(sg) ) )

      if Design.instance().typeIsVpc()
        # Elb <=> Subnet ( ElbSubnetAsso must created before ElbAmiAsso )
        for sb in data.resource.Subnets || []
          new ElbSubnetAsso( elb, resolve( MC.extractID(sb)  ) )

      # Elb <=> Ami
      for ami in data.resource.Instances || []
        # The instance might be servergroup member
        # thus it cannot be resolved.
        instance = resolve( MC.extractID(ami.InstanceId) )
        if instance then new ElbAmiAsso( elb, instance )
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
