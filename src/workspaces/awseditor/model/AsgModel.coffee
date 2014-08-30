
define [ "ResourceModel", "ComplexResModel", "Design", "constant", "i18n!/nls/lang.js", "./connection/LcUsage" ], ( ResourceModel, ComplexResModel, Design, constant, lang, LcUsage )->

  NotificationModel = ComplexResModel.extend {
    type : constant.RESTYPE.NC

    isUsed : ()->
      @get("instanceLaunch") or @get("instanceLaunchError") or @get("instanceTerminate") or @get("instanceTerminateError") or @get("test")

    initialize : ()->
      Design.modelClassForType( constant.RESTYPE.TOPIC ).ensureExistence()
      null

    isVisual: () -> false

    getTopic: () -> @connectionTargets('TopicUsage')[ 0 ]

    removeTopic: ->
      @connections('TopicUsage')[ 0 ]?.remove()

    isEffective: ->
      n = @toJSON()
      n.instanceLaunch or n.instanceLaunchError or n.instanceTerminate or n.instanceTerminateError or n.test

    getTopicName: () -> @getTopic()?.get 'name'

    setTopic: ( appId, name ) ->
      TopicModel = Design.modelClassForType( constant.RESTYPE.TOPIC )
      TopicModel.get( appId, name ).assignTo @

    serialize : ()->
      if not @isUsed() or not @get("asg")
        return

      topic = @getTopic()

      notifies = []
      for key, name of NotificationModel.typeMap
        if @get(name) then notifies.push( key )

      {
        component :
          name     : "SnsNotification"
          type     : @type
          uid      : @id
          resource :
            AutoScalingGroupName : @get("asg").createRef( "AutoScalingGroupName" )
            TopicARN : topic and topic.createRef( "TopicArn" ) or ''
            NotificationType : notifies
      }

  }, {

    handleTypes : constant.RESTYPE.NC

    typeMap : {
      "autoscaling:EC2_INSTANCE_LAUNCH"          : "instanceLaunch"
      "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"    : "instanceLaunchError"
      "autoscaling:EC2_INSTANCE_TERMINATE"       : "instanceTerminate"
      "autoscaling:EC2_INSTANCE_TERMINATE_ERROR" : "instanceTerminateError"
      "autoscaling:TEST_NOTIFICATION"            : "test"
    }

    deserialize : ( data, layout_data, resolve ) ->

      attr =
        id : data.uid

      for t in data.resource.NotificationType
        attr[ NotificationModel.typeMap[t] ] = true

      notify = new NotificationModel( attr )

      asg = resolve( MC.extractID( data.resource.AutoScalingGroupName ) )
      if asg
        asg.set("notification", notify)
        notify.set("asg", asg)

      resolve( MC.extractID( data.resource.TopicARN ) )?.assignTo notify

      null
  }





  ExpandedAsgModel = ComplexResModel.extend {

    type : "ExpandedAsg"

    defaults :
      originalAsg : null

    constructor : ( attributes, options )->
      console.assert( attributes.parent and attributes.originalAsg, "Invalid parameter for expanding asg" )

      # If the originalAsg has been expanded to the same parent.
      # Then we do not create the ExpandAsg
      asg = attributes.originalAsg
      for expanded in [asg].concat( asg.get("expandedList") )
        if attributes.parent.parent() is expanded.parent().parent()
          return

      # Call Superclass's constructor to finish creating the ExpandAsg
      ComplexResModel.call( this, attributes, options )
      null

    isReparentable : ( newParent )->
      asg = @attributes.originalAsg

      for expanded in [asg].concat( asg.get("expandedList") )
        if expanded isnt @ and newParent.parent() is expanded.parent().parent()
          return false

      true

    initialize : ()->
      console.assert( @get("originalAsg").get("expandedList").indexOf( @ ) is -1, "The expandedAsg is already in the Asg" )

      @get("originalAsg").get("expandedList").push @
      @getLc()?.trigger "change:expandedList", @
      null

    remove : ()->

      siblings = @get("originalAsg").get("expandedList")
      siblings.splice( siblings.indexOf( @ ), 1 )

      @getLc()?.trigger "change:expandedList", @

      ComplexResModel.prototype.remove.call this



    getLc : ()-> @attributes.originalAsg.getLc()

    serialize : ()->
      layout = @generateLayout()
      layout.type = "ExpandedAsg"
      layout.originalId = @get("originalAsg").id

      { layout : layout }

  }, {

    handleTypes : "ExpandedAsg"

    deserialize : ( data, layout_data, resolve )->

      originalAsg = resolve( layout_data.originalId )
      if not originalAsg
        console.warn "The ExpandedAsg is removed because its ASG is not found."
        return

      new ExpandedAsgModel({
        id          : data.uid
        originalAsg : originalAsg
        parent      : resolve( layout_data.groupUId )
        x           : layout_data.coordinate[0]
        y           : layout_data.coordinate[1]
      })
      null
  }






  Model = ComplexResModel.extend {

    defaults : ()->
      cooldown : "300"
      capacity : "1"
      minSize  : "1"
      maxSize  : "2"

      healthCheckGracePeriod : "300"
      healthCheckType        : "EC2"

      terminationPolicies : [ "Default" ]
      expandedList : []
      policies : []

    type : constant.RESTYPE.ASG
    newNameTmpl : "asg"

    isReparentable : ( newParent )->
      for expand in @get("expandedList")
        if newParent.parent() is expand.parent().parent()
          return sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, @get("name"), newParent.parent().get("name")

      true

    setLc : ( lc )->
      if @getLc() or not lc then return
      if _.isString( lc )
        lc = @design().component( lc )
      new LcUsage( @, lc )

    getLc : ()-> @connectionTargets("LcUsage")[0]

    getCost : ( priceMap, currency )->
      lc = @getLc()
      if not lc then return null

      InstanceModel = Design.modelClassForType( constant.RESTYPE.INSTANCE )
      lcPrice = InstanceModel.prototype.getCost.call( lc, priceMap, currency )
      if not lcPrice then return null

      if lcPrice.length then lcPrice = lcPrice[0]

      lcPrice.resource = @get("name")
      lcFee = lcPrice.fee

      volumeList = lc.get("volumeList")
      if volumeList and volumeList.length
        for v in volumeList
          vp = v.getCost( priceMap, currency, true )
          if vp then lcFee += vp.fee

      if lcPrice.fee isnt lcFee
        lcPrice.resource += " (& volumes)"
        lcPrice.fee = lcFee

      lcPrice.type = parseInt( @get("capacity") or @get("minSize"), 10 )
      lcPrice.fee *= lcPrice.type
      lcPrice.fee  = Math.round(lcPrice.fee * 100) / 100
      lcPrice.formatedFee = lcPrice.fee + "/mo"
      return lcPrice

    getNotification : ()-> @get("notification")?.toJSON() or {}

    getNotiObject: () ->
      @get("notification")

    setNotification : ( data )->
      n = @get("notification")
      if n
        n.set( data )
      else
        data.asg = this
        n = new NotificationModel( data )
        @set("notification", n)

      n

    setNotificationTopic: ( appId, name ) -> @get("notification")?.setTopic appId, name

    getNotificationTopicName: -> @get("notification")?.getTopicName()

    addScalingPolicy : ( policy )->
      policy.__asg = this
      @get("policies").push( policy )
      @listenTo( policy, "destroy", @__removeScalingPolicy )
      null

    __removeScalingPolicy : ( policy )->
      @stopListening( policy )
      @get("policies").splice( @get("policies").indexOf(policy), 1 )
      null

    # Use this method to see if Asg's healthCheckType is EC2 or not.
    # Do not use `@get("healthCheckType") is "EC2"`
    isEC2HealthCheckType : ()->
      lc = @getLc()
      if lc and lc.connections("ElbAmiAsso").length and @get("healthCheckType") is "ELB"
        return false

      return true

    remove : ()->
      # Remove ExpandedAsg
      asg.remove() for asg in @get("expandedList")

      # Remove Policies
      for p in @get("policies")
        p.off()
        p.remove()

      # Remove Notification
      @get("notification")?.remove()

      ComplexResModel.prototype.remove.call this
      null

    getExpandSubnets : ()->
      subnets = [ @parent() ]
      for expand in @get("expandedList")
        subnets.push expand.parent()
      subnets

    getExpandAzs : ()->
      az = []
      for sb in @getExpandSubnets()
        az.push sb.parent()

      _.uniq az

    serialize : ()->
      subnets = @getExpandSubnets()

      azs     = _.uniq( _.map subnets, (sb)-> sb.parent().createRef() )
      subnets = _.map subnets, (sb)-> sb.createRef( "SubnetId" )

      lc = @getLc()

      if lc
        elbs = lc.connectionTargets( "ElbAmiAsso" )
        if elbs.length
          healthCheckType = @get("healthCheckType")
          elbArray = _.map elbs, ( elb )-> elb.createRef( "LoadBalancerName" )

      component =
        uid  : @id
        name : @get("name")
        type : @type
        resource :
          AvailabilityZones       : azs
          VPCZoneIdentifier       : subnets.join(" , ")
          LoadBalancerNames       : elbArray or []
          AutoScalingGroupARN     : @get("appId")
          DefaultCooldown         : @get("cooldown")
          MinSize                 : @get("minSize")
          MaxSize                 : @get("maxSize")
          HealthCheckType         : healthCheckType || "EC2"
          HealthCheckGracePeriod  : @get("healthCheckGracePeriod")
          TerminationPolicies     : @get("terminationPolicies")
          AutoScalingGroupName    : @get("groupName") or @get("name")
          DesiredCapacity         : @get("capacity")
          LaunchConfigurationName : lc?.createRef( "LaunchConfigurationName" ) || ""

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.ASG

    deserialize : ( data, layout_data, resolve )->

      asg = new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.AutoScalingGroupARN

        parent : resolve( MC.extractID( layout_data.groupUId ) )

        cooldown               : String(data.resource.DefaultCooldown)
        capacity               : String(data.resource.DesiredCapacity)
        minSize                : String(data.resource.MinSize)
        maxSize                : String(data.resource.MaxSize)
        healthCheckType        : data.resource.HealthCheckType
        healthCheckGracePeriod : String(data.resource.HealthCheckGracePeriod)
        terminationPolicies    : data.resource.TerminationPolicies
        groupName              : data.resource.AutoScalingGroupName

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })


      # Associate with LC
      if data.resource.LaunchConfigurationName
        lc = resolve( MC.extractID(data.resource.LaunchConfigurationName) )
        new LcUsage( asg, lc )

        # Elb Association to LC
        ElbAsso = Design.modelClassForType( "ElbAmiAsso" )
        for elbName in data.resource.LoadBalancerNames || []
          elb = resolve MC.extractID elbName
          new ElbAsso( lc, elb )
      null

  }

  Model

