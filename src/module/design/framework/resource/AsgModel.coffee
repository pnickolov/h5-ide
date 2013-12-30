
define [ "../ComplexResModel", "CanvasManager", "Design", "constant" ], ( ComplexResModel, CanvasManager, Design, constant )->

  NotificationModel = ResourceModel.extend {
    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_NotificationConfiguration
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

      notifcation = new Model( attr )

      asg = resolve( MC.extractID( data.resource.AutoScalingGroupName ) )
      if asg
        asg.set("notification", notification)
      null
  }


  ExpandedAsgModel = ComplexResModel.extend {

    type : "ExpandedAsg"
    defaults :
      x           : 0
      y           : 0
      width       : 13
      height      : 13
      originalAsg : null

    initialize : ()->
      @get("originalAsg").__addExpandedAsg( this )
      null

    amiIconUrl : ()->
      lc = @get("originalAsg").get("lc")[0]

      if lc then lc.iconUrl() else "ide/ami/ami-not-available.png"

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
          'data-class' : @type
        })

        # Move the node to right place
        $("#asg_layer").append node
        CanvasManager.position node, @x(), @y()

      else
        node = $( document.getElementById( @id ) )

        CanvasManager.update( node.children(".asg-title"), label )
        CanvasManager.update( node.children(".node-label"), lcLabel )
        CanvasManager.update( node.children(".ami-image"), @amiIconUrl(), "href" )


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


  Model = ComplexResModel.extend {

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


      expandedList : []

    type : constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group
    newNameTmpl : "asg"

    setLC : ( lc )->
      oldLc = @get("lc")
      if oldLc
        @stopListening( oldLc )

      @listenTo( lc, "change:name", @__updateExpandedAsg )
      @set "lc", lc

      @addChild( lc )

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

    isEC2HealthCheckType : ()->
      lc = @get("lc")
      if lc and lc.connections("ElbAmiAsso").length and @get("healthCheckType") is "ELB"
        return false

      return true

    __updateExpandedAsg : ()->

    remove : ()->
      for asg in @get("expandedList")
        asg.off() # Need to off() first, because we are listening to expandedAsg.
        asg.remove()
      null

    __addExpandedAsg : ( expandedAsg )->
      console.assert( @get("expandedList").indexOf(expandedAsg) is -1 and (not expandedAsg.originalAsg ), "The expandedAsg is already in the Asg" )

      @get("expandedList").push( expandedAsg )
      expandedAsg.originalAsg = this

      @listenTo( expandedAsg, "destroy", @__onExpandedAsgRemove )
      null


    __onExpandedAsgRemove : ( target )->
      console.assert( target.type is "ExpandedAsg", "Invalid Parameter" )
      @get("expandedList").splice( @get("expandedList").indexOf(target), 1 )
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
          'class'      : 'dragable node AWS-AutoScaling-Group'
          'data-type'  : 'group'
          'data-class' : @type
        })

        # Move the node to right place
        $("#asg_layer").append node
        CanvasManager.position node, @x(), @y()

      else
        node = $( document.getElementById( @id ) )

        @__updateExpandedAsg()


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

        x : layout_data.coordinate[0]
        y : layout_data.coordinate[1]
      })


      # Associate with LC
      if data.resource.LaunchConfigurationName
        lc = resolve( MC.extractID(data.resource.LaunchConfigurationName) )
        asg.setLC( lc )


      # Elb Association to LC
      ElbAsso = Design.modelClassForType( "ElbAmiAsso" )
      for elbName in data.resource.LoadBalancerNames || []
        elb = resolve MC.extractID elbName
        new ElbAsso( lc, elb )
      null

  }

  Model

