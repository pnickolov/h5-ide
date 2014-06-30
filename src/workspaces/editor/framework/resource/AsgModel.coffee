
define [ "../ResourceModel", "../ComplexResModel", "../GroupModel", "Design", "constant", "i18n!/nls/lang.js" ], ( ResourceModel, ComplexResModel, GroupModel, Design, constant, lang )->

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
    # Even though the ExpandedAsgModel doesn't inherit from GroupModel,
    # The canvas wants to treat it as a group
    node_group : true

    defaults :
      x           : 0
      y           : 0
      width       : 13
      height      : 13
      originalAsg : null

    constructor : ( attributes, options )->
      console.assert( attributes.parent and attributes.originalAsg, "Invalid parameter for expanding asg" )

      # If the originalAsg has been expanded to the same parent.
      # Then we do not create the ExpandAsg
      list = [ attributes.originalAsg ].concat( attributes.originalAsg.get("expandedList") )
      for expanded in list
        if attributes.parent.type is constant.RESTYPE.SUBNET
          if attributes.parent.parent() is expanded.parent().parent()
            return
        else
          if attributes.parent is expanded.parent()
            return

      # Call Superclass's constructor to finish creating the ExpandAsg
      ComplexResModel.call( this, attributes, options )
      null

    isReparentable : ( newParent )->
      asg = @attributes.originalAsg

      for expanded in [asg].concat( asg.get("expandedList") )
        if expanded is @ then continue

        if newParent.type is constant.RESTYPE.SUBNET
          if newParent.parent() is expanded.parent().parent()
            return false
        else
          if newParent.parent is expanded.parent()
            return false

      true

    # Override connections / connectionTargets for "SgAsso"
    connections : ( type )->
      context = if type is "SgAsso" then @getLc() else this
      ComplexResModel.prototype.connections.call( context, type )

    connectionTargets : ( type )->
      context = if type is "SgAsso" then @getLc() else this
      ComplexResModel.prototype.connectionTargets.call( context, type )

    initialize : ()->
      # Draw must be call first
      @draw(true)

      @get("originalAsg").__addExpandedAsg( this )
      null

    getLc : ( origin )->
      lc = @attributes.originalAsg.get("lc")
      not origin and lc.getBigBrother() or lc

    # disconnect : ( cn )->
    #   if cn.type isnt "ElbAmiAsso" then return

    #   asg = @get("originalAsg")
    #   expandedList = asg.get("expandedList")
    #   # Need to temperory detach ExpandedAsg from original asg's expandedList
    #   # Because, we are going to remove originalAsg's LC's connection.
    #   # Which will affect all the expandedList
    #   expandedList.splice( expandedList.indexOf(@), 1 )

    #   ElbAmiAsso = Design.modelClassForType( "ElbAmiAsso" )
    #   lcAsso = new ElbAmiAsso( asg.get("lc"), cn.getTarget( constant.RESTYPE.ELB ))
    #   lcAsso.remove()

    #   expandedList.push( @ )
    #   null

    serialize : ()->
      layout = @generateLayout()
      layout.type = "ExpandedAsg"
      layout.originalId = @get("originalAsg").id

      { layout : layout }

  }, {

    handleTypes : "ExpandedAsg"

    deserialize : ( data, layout_data, resolve )->

      new ExpandedAsgModel({
        id          : data.uid
        originalAsg : resolve( layout_data.originalId )
        parent      : resolve( layout_data.groupUId )
        x           : layout_data.coordinate[0]
        y           : layout_data.coordinate[1]
      })
      null
  }






  Model = GroupModel.extend {

    defaults : ()->
      x            : 0
      y            : 0
      width        : 13
      height       : 13

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

    constructor: ( attributes, options ) ->
      GroupModel.prototype.constructor.apply @, arguments

      if attributes.lcId
        lc = Design.instance().component attributes.lcId
        dolly = lc.clone()
        @addChild dolly
        dolly.draw true
        for conn in dolly.connections()
          conn.draw() if conn.isVisual() or conn.type is 'SgAsso'

      @

    isReparentable : ( newParent )->
      for expand in @get("expandedList")
        if newParent.type is constant.RESTYPE.SUBNET
          if newParent.parent() is expand.parent().parent()
            return sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, @get("name"), newParent.parent().get("name")
        else
          if newParent.parent is expand.parent()
            return sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, @get("name"), newParent.get("name")

      true

    getCost : ( priceMap, currency )->
      lc = @get("lc")
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

    addChild : ( lc )->

      GroupModel.prototype.addChild.call this, lc
      lc.listenTo @, 'change:x', () ->
        lc.getCanvasView().resetPosition()

      lc.listenTo @, 'change:y', () ->
        lc.getCanvasView().resetPosition()


      oldLc = @get("lc")
      if oldLc
        @stopListening( oldLc )
        for elb in oldLc.connectionTargets("ElbAmiAsso")
          @updateExpandedAsgAsso( elb, true )

      @set "lc", lc
      @listenTo lc, "change:name change:imageId", @drawExpanedAsg
      @listenTo lc, "destroy", @removeChild

      for elb in lc.connectionTargets("ElbAmiAsso")
        @updateExpandedAsgAsso( elb )

      @draw()
      @drawExpanedAsg false

      null

    removeChild: ( lc ) ->
      GroupModel.prototype.removeChild.call this, lc

      # disconnect all asso of expanded asg
      @removeExpandedAsso()

      # Remove lc from parent ASG
      @unset "lc"
      @draw()

      null

    drawExpanedAsg: ( isCreate ) ->
      lc = @get 'lc'
      if lc
        for asg in @get("expandedList")
          asg.draw isCreate

      null

    getNotification : ()->
      n = @get("notification")
      if n then n.toJSON() else {}

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

    setNotificationTopic: ( appId, name ) ->
      n = @get("notification")
      n?.setTopic appId, name

    getNotificationTopicName: ->
      n = @get("notification")
      if n
        return n.getTopicName()
      null


    updateExpandedAsgAsso : ( elb, isRemove )->

      if @attributes.expandedList.length is 0 then return

      # Temperory clear expandList. So that removing ElbAmiAsso will not trigger
      # this method again.
      old_expandedList = @attributes.expandedList
      @attributes.expandedList = []

      ElbAsso = Design.modelClassForType( "ElbAmiAsso" )

      for i in old_expandedList
        asso = new ElbAsso( i, elb )
        if isRemove then asso.remove()

      @attributes.expandedList = old_expandedList
      null

    updateExpandedAsgSgLine : ( sgTarget, isRemove ) ->

      if @attributes.expandedList.length is 0 then return

      # Temperory clear expandList. So that removing ElbAmiAsso will not trigger
      # this method again.
      old_expandedList = @attributes.expandedList
      @attributes.expandedList = []

      SgLine = Design.modelClassForType( "SgRuleLine" )

      createOption = { createByUser : false }
      removeReason = { reason : sgTarget }

      for i in old_expandedList
        if i isnt sgTarget
          sgline = new SgLine( i, sgTarget, createOption )
          if isRemove then sgline.silentRemove()

      @attributes.expandedList = old_expandedList
      null

    removeExpandedAsso: () ->
      for expandedAsg in @get 'expandedList'
        connections = expandedAsg.connections()
        while connections.length
          _.first(connections).remove()

      null


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
      lc = @get("lc")
      if lc and lc.connections("ElbAmiAsso").length and @get("healthCheckType") is "ELB"
        return false

      return true

    remove : ()->
      # Remove ExpandedAsg
      for asg in @get("expandedList")
        asg.off() # Need to off() first, because we are listening to expandedAsg.
        asg.remove()

      # Remove Policies
      for p in @get("policies")
        p.off()
        p.remove()

      # Remove Notification
      if @get("notification")
        @get("notification").remove()

      GroupModel.prototype.remove.call this
      null

    __addExpandedAsg : ( expandedAsg )->
      console.assert( @get("expandedList").indexOf(expandedAsg) is -1 and (not expandedAsg.originalAsg ), "The expandedAsg is already in the Asg" )

      @get("expandedList").push( expandedAsg )
      expandedAsg.originalAsg = this

      @listenTo( expandedAsg, "destroy", @__onExpandedAsgRemove )

      lc = @get("lc")
      if lc
        # Connect Elb to ExpandedAsg
        ElbAsso = Design.modelClassForType( "ElbAmiAsso" )
        for elb in lc.connectionTargets( "ElbAmiAsso" )
          new ElbAsso( elb, expandedAsg )

        # Connect other sglilne to expandedAsg
        Sgline = Design.modelClassForType( "SgRuleLine" )
        for sgTarget in lc.connectionTargets( "SgRuleLine" )
          new Sgline( sgTarget, expandedAsg )
      null

    __onExpandedAsgRemove : ( target )->
      console.assert( target.type is "ExpandedAsg", "Invalid Parameter" )
      @get("expandedList").splice( @get("expandedList").indexOf(target), 1 )
      null

    getExpandSubnets : ()->
      if @parent().type isnt constant.RESTYPE.SUBNET
        return []

      subnets = [ @parent() ]
      for expand in @get("expandedList")
        subnets.push expand.parent()

      _.uniq subnets

    getExpandAzs : ()->
      subnets = [ @parent() ]
      for expand in @get("expandedList")
        subnets.push expand.parent()
      subnets = _.uniq subnets

      if @parent().type is constant.RESTYPE.SUBNET
        azs = _.uniq( _.map subnets, (sb)-> sb.parent() )
      else
        azs = subnets

      azs

    serialize : ()->
      subnets = [ @parent() ]
      for expand in @get("expandedList")
        subnets.push expand.parent()
      subnets = _.uniq subnets

      if @parent().type is constant.RESTYPE.SUBNET
        azs = _.uniq( _.map subnets, (sb)-> sb.parent().createRef() )
        subnets = _.map subnets, (sb)-> sb.createRef( "SubnetId" )
      else
        azs = _.uniq( _.map subnets, (az)-> az.createRef() )
        newSubnets = []
        for sb in subnets
          sbRef = sb.getSubnetRef()
          if sbRef then newSubnets.push sbRef
        subnets = newSubnets

      lc = @get("lc")
      if lc
        lcId = ( lc.getBigBrother() or lc ).createRef( "LaunchConfigurationName" )
      else
        lcId = ""

      healthCheckType = "EC2"
      if @get("lc")
        elbs = @get("lc").connectionTargets( "ElbAmiAsso" )
        if elbs.length
          healthCheckType = @get("healthCheckType")
          elbArray = _.map elbs, ( elb )-> elb.createRef( "LoadBalancerName" )

      component =
        uid  : @id
        name : @get("name")
        type : @type
        resource :
          AvailabilityZones : azs
          VPCZoneIdentifier : subnets.join(" , ")
          LoadBalancerNames : elbArray or []
          AutoScalingGroupARN : @get("appId")
          DefaultCooldown        : @get("cooldown")
          MinSize                : @get("minSize")
          MaxSize                : @get("maxSize")
          HealthCheckType        : healthCheckType
          HealthCheckGracePeriod : @get("healthCheckGracePeriod")
          TerminationPolicies    : @get("terminationPolicies")
          AutoScalingGroupName   : @get("groupName") or @get("name")
          DesiredCapacity        : @get("capacity")
          LaunchConfigurationName : lcId

      { component : component, layout : @generateLayout() }

  }, {

    handleTypes : constant.RESTYPE.ASG

    resolveLc   : ( uid ) ->
      if not uid then return null

      obj = Design.__instance.__componentMap[ uid ]
      if obj and not obj.parent() then return obj

      obj.clone()



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
        lc = @resolveLc( MC.extractID(data.resource.LaunchConfigurationName) )
        asg.addChild( lc )

        # Elb Association to LC
        ElbAsso = Design.modelClassForType( "ElbAmiAsso" )
        for elbName in data.resource.LoadBalancerNames || []
          elb = resolve MC.extractID elbName
          new ElbAsso( lc, elb )
      null

  }

  Model

