
define [ "../ResourceModel", "../ComplexResModel", "../GroupModel", "CanvasManager", "Design", "constant", "i18n!nls/lang.js" ], ( ResourceModel, ComplexResModel, GroupModel, CanvasManager, Design, constant, lang )->

  NotificationModel = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration

    isUsed : ()->
      @get("instanceLaunch") or @get("instanceLaunchError") or @get("instanceTerminate") or @get("instanceTerminateError") or @get("test")

    initialize : ()->
      Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic ).ensureExistence()
      null

    serialize : ()->
      if not @isUsed() or not @get("asg")
        return

      # Ensure there's a SNS_Topic
      topic = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic ).ensureExistence()

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
            TopicARN : topic.createRef( "TopicArn" )
            NotificationType : notifies
      }

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration

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
        if attributes.parent.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
          if attributes.parent.parent() is expanded.parent().parent()
            return
        else
          if attributes.parent is expanded.parent()
            return

      # Call Superclass's consctructor to finish creating the ExpandAsg
      ComplexResModel.call( this, attributes, options )
      null

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

    getLc : ()-> @attributes.originalAsg.get("lc")

    amiIconUrl : ()->
      lc = @get("originalAsg").get("lc")

      if lc then lc.iconUrl() else "ide/ami/ami-not-available.png"

    disconnect : ( cn )->
      if cn.type isnt "ElbAmiAsso" then return

      asg = @get("originalAsg")
      expandedList = asg.get("expandedList")
      # Need to temperory detach ExpandedAsg from original asg's expandedList
      # Because, we are going to remove originalAsg's LC's connection.
      # Which will affect all the expandedList
      expandedList.splice( expandedList.indexOf(@), 1 )

      ElbAmiAsso = Design.modelClassForType( "ElbAmiAsso" )
      lcAsso = new ElbAmiAsso( asg.get("lc"), cn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB ))
      lcAsso.remove()

      expandedList.push( @ )
      null

    draw : ( isCreate )->

      originalAsg = @get("originalAsg")

      label   = originalAsg.get("name")
      lcLabel = originalAsg.get("lc").get("name")

      if isCreate

        design = Design.instance()

        x      = @x()
        y      = @y()
        width  = @width()  * MC.canvas.GRID_WIDTH
        height = @height() * MC.canvas.GRID_HEIGHT

        node = Canvon.group().append(

          Canvon.rectangle( 1, 1, width - 1, height - 1 ).attr({
            'class' : 'group group-asg'
            'rx'    : 5
            'ry'    : 5
          }),

          # title bg
          Canvon.path( MC.canvas.PATH_ASG_TITLE ).attr({'class':'asg-title'})

          # title
          Canvon.text( 4, 14, label ).attr({'class':'group-label'})

          # lc icon
          Canvon.image( MC.IMG_URL + "ide/icon/instance-canvas.png", 35, 39, 61, 62 )
          Canvon.image( MC.IMG_URL + @amiIconUrl(), 50, 45, 39, 27 ).attr({"class":'ami-icon'})

          # lc label
          Canvon.text( 65, 116, lcLabel ).attr({'class':'node-label'})

          # left port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-launchconfig-sg-left'
            'class'      : 'port port-blue port-launchconfig-sg port-launchconfig-sg-left'
            'transform'  : 'translate(25, 45)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            'data-name'     : 'launchconfig-sg'
            'data-position' : 'left'
            'data-type'     : 'sg'
            'data-direction': 'in'
          }),

          # right port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-launchconfig-sg-right'
            'class'      : 'port port-blue port-launchconfig-sg port-launchconfig-sg-right'
            'transform'  : 'translate(95, 45)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_RIGHT_ANGLE
            'data-name'     : 'launchconfig-sg'
            'data-position' : 'right'
            'data-type'     : 'sg'
            'data-direction': 'out'
          })

        ).attr({
          'id'         : @id
          'class'      : 'dragable AWS-AutoScaling-Group asg-expand'
          'data-type'  : 'group'
          'data-class' : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
        })

        # Move the node to right place
        $("#asg_layer").append node
        CanvasManager.position node, @x(), @y()

      else
        node = $( document.getElementById( @id ) )

        CanvasManager.update( node.children(".group-label"), label )
        CanvasManager.update( node.children(".node-label"), lcLabel )
        CanvasManager.update( node.children(".ami-icon"), @amiIconUrl(), "href" )

    serialize : ()->
      layout =
        uid  : @id
        type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
        groupUId   : @parent().id
        originalId : @get("originalAsg").id
        coordinate : [ @x(), @y() ]

      { layout : layout }

  }, {

    handleTypes : "ExpandedAsg"

    deserialize : ( data, layout_data, resolve )->

      new ExpandedAsgModel({
        originalAsg : resolve( layout_data.originalId )
        parent      : resolve( layout_data.groupUId )
        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })
      null
  }






  Model = GroupModel.extend {

    defaults : ()->
      x            : 0
      y            : 0
      width        : 13
      height       : 13

      cooldown : 300
      capacity : 1
      minSize  : 1
      maxSize  : 2

      healthCheckGracePeriod : 300
      healthCheckType        : "EC2"

      terminationPolicies : [ "Default" ]
      expandedList : []
      policies : []

    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
    newNameTmpl : "asg"

    isReparentable : ( newParent )->
      for expand in @get("expandedList")
        if expand.parent() is newParent
          return sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, @get("name"), newParent.get("name")
      true

    getCost : ( priceMap, currency )->
      lc = @get("lc")
      if not lc then return null

      InstanceModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance )
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
      oldLc = @get("lc")
      if oldLc
        @stopListening( oldLc )
        for elb in oldLc.connectionTargets("ElbAmiAsso")
          @updateExpandedAsgAsso( elb, true )

      @listenTo( lc, "change:name", @__drawExpandedAsg )
      @set "lc", lc

      for elb in lc.connectionTargets("ElbAmiAsso")
        @updateExpandedAsgAsso( elb )

      @draw()
      null

    getNotification : ()->
      n = @get("notification")
      if n then n.toJSON() else {}

    setNotification : ( data )->
      n = @get("notification")
      if n
        n.set( data )
      else
        data.asg = this
        n = new NotificationModel( data )
        @set("notification", n)
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
      null

    __addExpandedAsg : ( expandedAsg )->
      console.assert( @get("expandedList").indexOf(expandedAsg) is -1 and (not expandedAsg.originalAsg ), "The expandedAsg is already in the Asg" )

      @get("expandedList").push( expandedAsg )
      expandedAsg.originalAsg = this

      @listenTo( expandedAsg, "destroy", @__onExpandedAsgRemove )

      # Connect Elb to expandedAsg
      ElbAsso = Design.modelClassForType( "ElbAmiAsso" )
      for elb in @get("lc").connectionTargets( "ElbAmiAsso" )
        new ElbAsso( elb, expandedAsg )

      # Connect other sglilne to expandedAsg
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sgTarget in @get("lc").connectionTargets( "SgAsso" )
        new SgAsso( expandedAsg, sgTarget )
      null

    __onExpandedAsgRemove : ( target )->
      console.assert( target.type is "ExpandedAsg", "Invalid Parameter" )
      @get("expandedList").splice( @get("expandedList").indexOf(target), 1 )
      null

    __drawExpandedAsg : ()->
      for asg in @get("expandedList")
        asg.draw()
      null

    draw : ( isCreate )->

      if isCreate

        design = Design.instance()

        x      = @x()
        y      = @y()
        width  = @width()  * MC.canvas.GRID_WIDTH
        height = @height() * MC.canvas.GRID_HEIGHT

        node = Canvon.group().append(

          Canvon.rectangle( 1, 1, width - 1, height - 1 ).attr({
            'class' : 'group group-asg'
            'rx'    : 5
            'ry'    : 5
          }),

          # title bg
          Canvon.path( MC.canvas.PATH_ASG_TITLE ).attr({'class':'asg-title'}),

          # dragger
          Canvon.image(MC.IMG_URL + 'ide/icon/asg-resource-dragger.png', width - 21, 0, 22, 21).attr({
            'class'        : 'asg-resource-dragger tooltip'
            'data-tooltip' : 'Expand the group by drag-and-drop in other availability zone.'
          }),

          # prompt
          Canvon.group().append(
            Canvon.text(25, 45,  'Drop AMI from'),
            Canvon.text(20, 65,  'resource panel to'),
            Canvon.text(30, 85,  'create launch'),
            Canvon.text(30, 105, 'configuration')
          ).attr({ 'class' : 'prompt_text'}),

          # title
          Canvon.text( 4, 14, @get("name") ).attr({'class':'group-label'})

        ).attr({
          'id'         : @id
          'class'      : 'dragable AWS-AutoScaling-Group'
          'data-type'  : 'group'
          'data-class' : @type
        })

        # Move the node to right place
        $("#asg_layer").append node
        CanvasManager.position node, @x(), @y()

      else
        node = $( document.getElementById( @id ) )
        CanvasManager.update( node.children(".group-label"), @get("name") )
        @__drawExpandedAsg()


      hasLC = !!@get("lc")
      CanvasManager.toggle( node.children(".prompt_text"), !hasLC )
      CanvasManager.toggle( node.children(".asg-resource-dragger"), hasLC )
      null

    serialize : ()->
      layout =
        uid  : @id
        type : @type
        groupUId   : @parent().id
        originalId : ""
        coordinate : [ @x(), @y() ]

      subnets = [ @parent() ]
      for expand in @get("expandedList")
        subnets.push expand.parent()
      subnets = _.uniq subnets

      if @parent().type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
        azs = _.uniq( _.map subnets, (sb)-> sb.parent().get("name") )
        subnets = _.map subnets, (sb)-> sb.createRef( "SubnetId" )
      else
        azs = _.uniq( _.map subnets, (az)-> az.get("name") )
        newSubnets = []
        for sb in subnets
          sbRef = sb.getSubnetRef()
          if sbRef then newSubnets.push sbRef
        subnets = newSubnets

      if @get("lc")
        lcId = @get('lc').createRef( "LaunchConfigurationName" )
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
          PlacementGroup : ""
          AvailabilityZones : azs
          VPCZoneIdentifier : subnets.join(",")
          LoadBalancerNames : elbArray or []
          AutoScalingGroupARN : @get("appId")
          DefaultCooldown        : @get("cooldown")
          MinSize                : @get("minSize")
          MaxSize                : @get("maxSize")
          HealthCheckType        : healthCheckType
          HealthCheckGracePeriod : @get("healthCheckGracePeriod")
          TerminationPolicies    : @get("terminationPolicies")
          AutoScalingGroupName   : @get("name")
          DesiredCapacity        : @get("capacity")
          LaunchConfigurationName : lcId
          EnabledMetrics                 : [{ Metric : "", Granularity : "" }]
          Instances                      : []
          SuspendedProcesses             : [ ProcessName: "", SuspensionReason : "" ]
          ShouldDecrementDesiredCapacity : ""
          #reserved
          CreatedTime : ""
          InstanceId  : ""
          Status      : ""
          Tags        : ""

      { component : component, layout : layout }

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

    deserialize : ( data, layout_data, resolve )->

      asg = new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.AutoScalingGroupARN

        parent : resolve( MC.extractID( layout_data.groupUId ) )

        cooldown               : data.resource.DefaultCooldown
        capacity               : data.resource.DesiredCapacity
        minSize                : data.resource.MinSize
        maxSize                : data.resource.MaxSize
        healthCheckType        : data.resource.HealthCheckType
        healthCheckGracePeriod : data.resource.HealthCheckGracePeriod
        terminationPolicies    : data.resource.TerminationPolicies

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })


      # Associate with LC
      if data.resource.LaunchConfigurationName
        lc = resolve( MC.extractID(data.resource.LaunchConfigurationName) )
        asg.addChild( lc )

        # Elb Association to LC
        ElbAsso = Design.modelClassForType( "ElbAmiAsso" )
        for elbName in data.resource.LoadBalancerNames || []
          elb = resolve MC.extractID elbName
          new ElbAsso( lc, elb )
      null

  }

  Model

