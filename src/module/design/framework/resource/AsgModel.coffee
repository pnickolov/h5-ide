
define [ "../ResourceModel", "../ComplexResModel", "../GroupModel", "CanvasManager", "Design", "constant" ], ( ResourceModel, ComplexResModel, GroupModel, CanvasManager, Design, constant )->

  NotificationModel = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration

    initialize : ()->
      # Ensure there's a SNS_Topic
      TopicModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_SNS_Topic )
      if TopicModel.allObjects().length is 0
        new TopicModel()
  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration

    typeMap : {
      "autoscaling:EC2_INSTANCE_LAUNCH" : "instanceLaunch"
      "autoscaling:EC2_INSTANCE_LAUNCH_ERROR" : "instanceLaunchError"
      "autoscaling:EC2_INSTANCE_TERMINATE" : "instanceTerminate"
      "autoscaling:EC2_INSTANCE_TERMINATE_ERROR" : "instanceTerminateError"
      "autoscaling:TEST_NOTIFICATION" : "test"
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
      for expanded in attributes.originalAsg.get("expandedList")
        if expanded.parent is attributes.parent
          return

      # Call Superclass's consctructor to finish creating the ExpandAsg
      ComplexResModel.call( this, attributes, options )
      null


    initialize : ()->
      @get("originalAsg").__addExpandedAsg( this )

      #listen state update event
      Design.instance().on Design.EVENT.AwsResourceUpdated, _.bind( @draw, @ )

      null

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
            'id'         : @id + '_port-instance-sg-left'
            'class'      : 'port port-blue port-instance-sg port-instance-sg-left'
            'transform'  : 'translate(25, 45)' + MC.canvas.PORT_RIGHT_ROTATE
            'data-angle' : MC.canvas.PORT_LEFT_ANGLE
            'data-name'     : 'launchconfig-sg'
            'data-position' : 'left'
            'data-type'     : 'sg'
            'data-direction': 'in'
          }),

          # right port(blue)
          Canvon.path(MC.canvas.PATH_D_PORT2).attr({
            'id'         : @id + '_port-instance-sg-right'
            'class'      : 'port port-blue port-instance-sg port-instance-sg-right'
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

        CanvasManager.update( node.children(".asg-title"), label )
        CanvasManager.update( node.children(".node-label"), lcLabel )
        CanvasManager.update( node.children(".ami-icon"), @amiIconUrl(), "href" )


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
      mixSize  : 1
      maxSize  : 2

      healthCheckGracePeriod : 300
      healthCheckType        : "EC2"

      terminationPolicies : [ "Default" ]
      expandedList : []
      policies : []

    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
    newNameTmpl : "asg"

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
        n = new NotificationModel( data )
        @set("notification", n)
      null

    updateExpandedAsgAsso : ( elb, isRemove )->
      ElbAsso = Design.modelClassForType( "ElbAmiAsso" )

      for i in @get("expandedList")
        asso = new ElbAsso( i, elb )
        if isRemove then asso.remove()

      null

    addScalingPolicy : ( policy )->
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
            'id'           : @id + '_asg_resource_dragger'
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

        @__drawExpandedAsg()


      CanvasManager.toggle( node.children(".prompt_text"), !@get("lc") )
      null

  }, {

    handleTypes : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

    deserialize : ( data, layout_data, resolve )->

      asg = new Model({
        id    : data.uid
        name  : data.name
        appId : data.resource.AutoScalingGroupARN

        parent : resolve( MC.extractID( layout_data.groupUId ) )

        cooldown               : data.resource.DefaultCooldown
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

