
define [ "Design",
         "constant",
         "../ResourceModel",
         "../ComplexResModel",
         "./VpcModel",
         "./SgModel",
         "./SslCertModel",
         "../connection/SgAsso"
         "../connection/ElbAsso"
], ( Design, constant, ResourceModel, ComplexResModel, VpcModel, SgModel, SslCertModel, SgAsso )->

  Model = ComplexResModel.extend {

    defaults : ()->
      {
        x        : 0
        y        : 0
        width    : 9
        height   : 9

        internal  : true
        crossZone : true

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
          sslCertName      : null
        } ]

        # AvailabilityZones ( This attribute is used to store which AZ is attached to Elb in Classic ). It stores AZ's name, not reference
        AvailabilityZones : []

        # Connection draining
        ConnectionDraining: {
          Enabled: true,
          Timeout: 300
        }

        # Advanced
        otherPoliciesMap: {}
      }

    type : constant.RESTYPE.ELB

    newNameTmpl : "load-balancer-"

    initialize : ( attr, option )->
      @draw(true)

      if option.createByUser
        sg = new SgModel({
          name        : @getElbSgName()
          isElbSg     : true
          description : "Automatically created SG for load-balancer"
        })
        @__elbSg = sg
        SgAssoModel = Design.modelClassForType( "SgAsso" )
        new SgAssoModel( this, sg )
      null

    isRemovable : ()->
      elbsg = @getElbSg()
      if elbsg and elbsg.connections("SgAsso").length > 1
        return MC.template.ElbRemoveConfirmation {
          name : @get("name")
          sg : elbsg.get("name")
        }

      true

    remove : ()->
      # sslCert = @get("sslCert")
      # if sslCert then sslCert.remove()

      # Remove elb will only remove my elb sg
      if @getElbSg() then @getElbSg().remove()

      ComplexResModel.prototype.remove.call this
      null

    # Always use this method to get the sg of this elb
    getElbSg : ()->
      if @__elbSg
        # If the elbsg is removed, we would like to nullify it.
        if @__elbSg.isRemoved()
          @__elbSg = undefined

      @__elbSg

    getElbSgName : ()-> "elbsg-"+ @get("name")

    setName : ( name )->
      if @get("name") is name
        return

      @set "name", name

      if @getElbSg()
        # Update Elb's Sg's Name
        @getElbSg().set( "name", @getElbSgName() )

      if @draw then @draw()
      null

    setListener : ( idx, value )->
      console.assert( value.port and value.protocol and value.instanceProtocol and value.instancePort, "Invalid parameter for setListener" )

      listeners = @get("listeners")
      if idx >= listeners.length
        listeners.push value
      else
        listeners[idx] = {} if not listeners[idx]
        listeners[idx] = $.extend listeners[idx], value

      if not (listeners[idx].protocol in ['HTTPS', 'SSL'])
        listeners[idx].sslCert = null

      null

    removeListener : ( idx ) ->
      if idx is 0 then return
      listeners = @get("listeners")
      listeners.splice( idx, 1 )
      @set "listeners", listeners
      null

    setSSLCert : ( idx, sslCertId ) ->

      listeners = @get("listeners")
      sslCertData = sslCertCol.get(sslCertId)
      listeners[idx].sslCert = SslCertModel.createNew(sslCertData)

    removeSSLCert : ( idx ) ->

      listeners = @get("listeners")
      listeners[idx].sslCert = null

    getSSLCert : ( idx ) ->

      listeners = @get("listeners")
      return listeners[idx].sslCert

    getHealthCheckTarget : ()->
      # Format ping
      target = @attributes.healthCheckTarget
      splitIndex = target.indexOf(":")
      protocol = target.substring(0, splitIndex)

      target = target.substring(splitIndex+1)
      port   = parseInt( target, 10 )
      if isNaN( port ) then port = 80

      path = target.replace( /[^\/]+\//, "" )

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

    setInternal : ( isInternal )->
      @set "internal", !!isInternal
      @draw()

      if isInternal
        # Redraw SG Line
        SgModel = Design.modelClassForType( constant.RESTYPE.SG )
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
          type        : constant.RESTYPE.ELB
          fee         : fee * 24 * 30
          formatedFee : fee + "/hr"
        }

    getAvailabilityZones : ()->
      azs = _.map @connectionTargets("ElbSubnetAsso"), ( subnet )->
        subnet.parent().createRef()

      return _.uniq azs

    # Other Policy
    setPolicyProxyProtocol : (enable, portAry) ->

      otherPoliciesMap = @get('otherPoliciesMap')
      if enable
        otherPoliciesMap.EnableProxyProtocol = {
          'PolicyName' : 'EnableProxyProtocol',
          'PolicyTypeName' : 'ProxyProtocolPolicyType',
          'PolicyAttributes' :{
            'ProxyProtocol' : true
          },
          'InstancePort' : portAry
        }
      else
        delete otherPoliciesMap.EnableProxyProtocol

      @set('otherPoliciesMap', otherPoliciesMap)

    serialize : ()->
      hcTarget = @get("healthCheckTarget")
      if hcTarget.indexOf("TCP") isnt -1 or hcTarget.indexOf("SSL") isnt -1
        # If target is TCP or SSL, remove path.
        hcTarget = hcTarget.split("/")[0]

      listeners = []
      # ssl = @connectionTargets("SslCertUsage")[0]
      # if ssl
      #   sslcertId = ssl.createRef("ServerCertificateMetadata.Arn")
      # else
      #   sslcertId = ""

      for l in @get("listeners")
        id = ""
        if (l.protocol is "SSL" or l.protocol is "HTTPS") and l.sslCert
          id = l.sslCert.createRef("ServerCertificateMetadata.Arn")

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

      subnets = _.map @connectionTargets( "ElbSubnetAsso" ), ( sb )-> sb.createRef("SubnetId")

      otherPoliciesMap = @get('otherPoliciesMap')
      otherPoliciesAry = _.map otherPoliciesMap, (policyObj) ->
        return policyObj
      if not otherPoliciesAry
        otherPoliciesAry = []

      # Remove AZs in Elb JSON because VPC doesn't need it.
      component =
        type : @type
        uid  : @id
        name : @get("name")
        resource :
          AvailabilityZones : [] # @getAvailabilityZones()
          Subnets : subnets
          Instances : []
          CrossZoneLoadBalancing : @get("crossZone")
          ConnectionDraining: @get("ConnectionDraining")
          VpcId                  : @getVpcRef()
          LoadBalancerName       : @get("elbName") or @get("name")
          SecurityGroups         : sgs

          Scheme : if @get("internal") then "internal" else "internet-facing"
          ListenerDescriptions : listeners
          HealthCheck :
            Interval               : @get("healthCheckInterval")
            Target                 : hcTarget
            Timeout                : @get("healthCheckTimeout")
            HealthyThreshold       : @get("healthyThreshold")
            UnhealthyThreshold     : @get("unHealthyThreshold")
          DNSName : @get("dnsName") or ""
          Policies: {
              LBCookieStickinessPolicies : [{ PolicyName : "", CookieExpirationPeriod : "" }]
              AppCookieStickinessPolicies : [{ PolicyName : "", CookieName : ""}]
              OtherPolicies : otherPoliciesAry
            }
          BackendServerDescriptions : [ { InstantPort : "", PoliciyNames : "" } ]

      return { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.ELB

    deserialize : ( data, layout_data, resolve )->

      # Handle Elb
      attr =
        id     : data.uid
        name   : data.name
        appId  : data.resource.DNSName
        parent : resolve( layout_data.groupUId )

        internal  : data.resource.Scheme is 'internal'
        crossZone : !!data.resource.CrossZoneLoadBalancing
        ConnectionDraining : data.resource.ConnectionDraining || {
          Enabled: true,
          Timeout: 300
        }
        listeners : []
        dnsName   : data.resource.DNSName
        elbName   : data.resource.LoadBalancerName

        healthyThreshold    : data.resource.HealthCheck.HealthyThreshold
        unHealthyThreshold  : data.resource.HealthCheck.UnhealthyThreshold
        healthCheckTarget   : data.resource.HealthCheck.Target
        healthCheckInterval : data.resource.HealthCheck.Interval
        healthCheckTimeout  : data.resource.HealthCheck.Timeout

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]

        otherPoliciesMap: {}

      # Other Policies
      if data.resource.Policies
        if data.resource.Policies.OtherPolicies
          _.each data.resource.Policies.OtherPolicies, (policyObj) ->
            attr.otherPoliciesMap[policyObj.PolicyName] = policyObj
            null

      # AZ is used in classic mode
      attr.AvailabilityZones = _.map data.resource.AvailabilityZones || [], ( azRef )->
        # azRef might be azName
        if azRef[0] is "@"
          return resolve( MC.extractID( azRef ) ).get("name")
        else
          return azRef

      # listener
      for l, idx in data.resource.ListenerDescriptions || []
        l = l.Listener
        attr.listeners.push {
          port             : l.LoadBalancerPort
          protocol         : l.Protocol
          instanceProtocol : l.InstanceProtocol
          instancePort     : l.InstancePort
        }
        if l.SSLCertificateId
          # Cannot resolve the same component multiple times within one deserialize.
          # Because Design might consider it as recursive dependency.
          sslCert = resolve( MC.extractID( l.SSLCertificateId ) )
          attr.listeners[idx].sslCert = sslCert if sslCert

      elb = new Model( attr )
      # if sslCert then sslCert.assignTo( elb )

      ElbAmiAsso    = Design.modelClassForType( "ElbAmiAsso" )
      ElbSubnetAsso = Design.modelClassForType( "ElbSubnetAsso" )

      # Elb <=> Sg
      for sg in data.resource.SecurityGroups || []
        new SgAsso( elb, resolve( MC.extractID(sg) ) )

      # Elb <=> Subnet ( ElbSubnetAsso must created before ElbAmiAsso )
      for sb in data.resource.Subnets || []
        new ElbSubnetAsso( elb, resolve( MC.extractID(sb) ), { deserialized : true } )

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
      sgName = elb.getElbSgName()
      for sg in SgModel.allObjects()
        if sg.get("name") is sgName
          elb.__elbSg = sg
          sg.setAsElbSg()
          return
  }

  Model
