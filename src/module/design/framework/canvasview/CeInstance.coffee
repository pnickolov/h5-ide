
define [ "i18n!nls/lang.js", "./CanvasElement", "constant", "CanvasManager", "Design" ], ( lang, CanvasElement, constant, CanvasManager, Design )->

  CeInstance = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeInstance, constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance )
  ChildElementProto = CeInstance.prototype


  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "instance-sg-left"  : [ 10, 20, MC.canvas.PORT_LEFT_ANGLE ]
    "instance-sg-right" : [ 80, 20, MC.canvas.PORT_RIGHT_ANGLE ]
    "instance-attach"   : [ 78, 50, MC.canvas.PORT_RIGHT_ANGLE ]
    "instance-rtb"      : [ 45, 0,  MC.canvas.PORT_UP_ANGLE  ]
  }
  ChildElementProto.portDirMap = {
    "instance-sg" : "horizontal"
  }

  ChildElementProto.detach = ()->
    # Remove state icon
    MC.canvas.nodeAction.remove @id
    CanvasElement.prototype.detach.call this
    null

  ChildElementProto.iconUrl = ()->
    ami = @model.getAmi() || @model.get("cachedAmi")

    if not ami
      "ide/ami/ami-not-available.png"
    else
      "ide/ami/#{ami.osType}.#{ami.architecture}.#{ami.rootDeviceType}.png"


  ChildElementProto.draw = ( isCreate )->
    m = @model

    if isCreate

      # Call parent's createNode to do basic creation
      node = @createNode({
        image   : "ide/icon/instance-canvas.png"
        imageX  : 15
        imageY  : 9
        imageW  : 61
        imageH  : 62
        label   : m.get("name")
        labelBg : true
        sg      : true
      })

      # Insert Volume / Eip / Port
      node.append(
        # Ami Icon
        Canvon.image( MC.IMG_URL + @iconUrl(), 30, 15, 39, 27 ).attr({'class':"ami-image"}),

        # Volume Image
        Canvon.image( "", 21, 44, 29, 24 ).attr({
          'id'    : "#{@id}_volume_status"
          'class' : 'volume-image'
        }),
        # Volume Label
        Canvon.text( 35, 56, "" ).attr({'class':'node-label volume-number'}),
        # Volume Hotspot
        Canvon.rectangle(21, 44, 29, 24).attr({
          'data-target-id' : @id
          'class'          : 'instance-volume'
          'fill'           : 'none'
        }),

        # Eip
        Canvon.image( "", 53, 47, 12, 14).attr({'class':'eip-status tooltip'}),

        # Child number
        Canvon.group().append(
          Canvon.rectangle(36, 1, 20, 16).attr({'class':'server-number-bg','rx':4,'ry':4}),
          Canvon.text(46, 13, "0").attr({'class':'node-label server-number'})
        ).attr({
          'id'      : "#{@id}_instance-number-group"
          'class'   : 'instance-number-group'
          "display" : "none"
        }),


        # left port(blue)
        Canvon.path(this.constant.PATH_PORT_DIAMOND).attr({
          'class'          : 'port port-blue port-instance-sg port-instance-sg-left'
          'data-name'      : 'instance-sg' #for identify port
          'data-alias'     : 'instance-sg-left'
          'data-position'  : 'left' #port position: for calc point of junction
          'data-type'      : 'sg'   #color of line
          'data-direction' : 'in'   #direction
        }),

        # right port(blue)
        Canvon.path(this.constant.PATH_PORT_DIAMOND).attr({
          'class'          : 'port port-blue port-instance-sg port-instance-sg-right'
          'data-name'      : 'instance-sg'
          'data-alias'     : 'instance-sg-right'
          'data-position'  : 'right'
          'data-type'      : 'sg'
          'data-direction' : 'out'
        })
      )

      if not @model.design().typeIsClassic()
        # Show RTB/ENI Port in VPC Mode
        node.append(
          Canvon.path(this.constant.PATH_PORT_RIGHT).attr({
            'class'      : 'port port-green port-instance-attach'
            'data-name'     : 'instance-attach'
            'data-position' : 'right'
            'data-type'     : 'attachment'
            'data-direction': 'out'
          })

          Canvon.path(this.constant.PATH_PORT_BOTTOM).attr({
            'class'      : 'port port-blue port-instance-rtb'
            'data-name'     : 'instance-rtb'
            'data-position' : 'top'
            'data-type'     : 'sg'
            'data-direction': 'in'
          })
        )

      if not @model.design().modeIsStack() and m.get("appId")
        # instance-state
        node.append(
          Canvon.circle(68, 15, 5,{}).attr({
            'id'    : "#{@id}_instance-state"
            'class' : 'instance-state instance-state-unknown'
          })
        )

      # Move the node to right place
      @getLayer("node_layer").append node
      @initNode node, m.x(), m.y()

    else
      node = @$element()
      # update label
      CanvasManager.update node.children(".node-label-name"), m.get("name")

      # Update Instance State in app
      @updateAppState()

    # Update Ami Image
    CanvasManager.update node.children(".ami-image"), @iconUrl(), "href"


    # Update Server number
    numberGroup = node.children(".instance-number-group")
    if m.get("count") > 1
      CanvasManager.toggle node.children(".instance-state"), false
      CanvasManager.toggle node.children(".port-instance-rtb"), false
      CanvasManager.toggle numberGroup, true
      CanvasManager.update numberGroup.children("text"), m.get("count")
    else
      CanvasManager.toggle node.children(".instance-state"), true
      CanvasManager.toggle node.children(".port-instance-rtb"), true
      CanvasManager.toggle numberGroup, false


    # Update Volume
    volumeCount = if m.get("volumeList") then m.get("volumeList").length else 0
    if volumeCount > 0
      volumeImage = 'ide/icon/instance-volume-attached-normal.png'
    else
      volumeImage = 'ide/icon/instance-volume-not-attached.png'
    CanvasManager.update node.children(".volume-image"), volumeImage, "href"
    CanvasManager.update node.children(".volume-number"), volumeCount

    # Update EIP
    CanvasManager.updateEip node.children(".eip-status"), m

    null

  ChildElementProto.select = ( subId )->
    m      = @model
    type   = m.type
    design = m.design()

    if not subId
      if design.modeIsApp()
        if m.get("count") > 1
          type = "component_server_group"

      else if design.modeIsAppEdit() and m.get("appId")
        type = "component_server_group"

    @doSelect( type, subId or @model.id, @model.id )
    true


  ChildElementProto.updateAppState = ()->
    m = @model
    if m.design().modeIsStack() or not m.get("appId")
      return

    # Check icon
    if $("##{@id}_instance-state").length is 0
      return

    # Init icon to unknown state
    el = @element()
    CanvasManager.removeClass el, "deleted"

    # Get instance state
    instance_data = MC.data.resource_list[ m.design().region() ][ m.get("appId") ]
    if instance_data
      instanceState = instance_data.instanceState.name
      CanvasManager.addClass el, "deleted" if instanceState is "terminated"
    else
      #instance data not found, or maybe instance already terminated
      instanceState = "unknown"
      CanvasManager.addClass el, "deleted"

    #update icon state and tooltip
    stateClass = "instance-state tooltip instance-state-#{instanceState} instance-state-#{m.design().mode()}"
    stateEl = $("##{@id}_instance-state").attr({ "class" : stateClass })
    CanvasManager.update stateEl, instanceState, "data-tooltip"
    null

  ChildElementProto.volume = ( volume_id )->
    m = @model
    design = m.design()

    if volume_id
      v = design.component( volume_id )
      return {
        deleted    : if not v.hasAppResource() then "deleted" else ""
        name       : v.get("name")
        snapshotId : v.get("snapshotId")
        size       : v.get("volumeSize")
        id         : v.id
      }

    vl = []
    for v in @model.get("volumeList") or vl
      vl.push {
        deleted    : if not v.hasAppResource() then "deleted" else ""
        name       : v.get("name")
        snapshotId : v.get("snapshotId")
        size       : v.get("volumeSize")
        id         : v.id
      }

    vl

  ChildElementProto.listVolume = ( appId )->
    vl = []
    design = @model.design()

    resource_list = MC.data.resource_list[ design.region() ]
    if not resource_list then return vl

    data = resource_list[ appId ]

    if data and data.blockDeviceMapping and data.blockDeviceMapping.item
      for v in data.blockDeviceMapping.item
        if data.rootDeviceName is v.deviceName
          continue
        volume = resource_list[ v.ebs.volumeId ]
        if volume
          #volume exist
          vl.push {
            name       : v.deviceName
            snapshotId : volume.snapshotId || ""
            size       : volume.size
            id         : volume.volumeId
          }
        else
          if @type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
            #in asg,volume data maybe delay
            vl.push {
              name       : v.deviceName
              snapshotId : v.ebs.snapshotId || ""
              size       : ""
              id         : v.ebs.volumeId
            }
          else
            #volume not exist
            vl.push {
              name       : v.deviceName
              snapshotId : v.ebs.snapshotId || ""
              size       : ""
              id         : v.ebs.volumeId
              deleted    : "deleted"
            }


    vl

  ChildElementProto.list = ()->
    list = CanvasElement.prototype.list.call( this )
    list.background = @iconUrl()
    list.volume     = (@model.get("volumeList") || []).length
    list

  ChildElementProto.addVolume = ( attribute )->

    ###
      # # # Quick Hack # # #
      Do not allow adding volume to existing LC in appUpdate
    ###
    if Design.instance().modeIsAppEdit() and @model.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration and @model.get("appId")
      notification "error", lang.ide.NOTIFY_MSG_WARN_OPERATE_NOT_SUPPORT_YET
      return false

    attribute = $.extend {}, attribute
    attribute.owner = @model
    VolumeModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume )
    v = new VolumeModel( attribute )
    if v.id
      return {
        id         : v.id
        deleted    : not v.hasAppResource()
        name       : v.get("name")
        snapshotId : v.get("snapshotId")
        size       : v.get("volumeSize")
      }
    else
      return false

  ChildElementProto.removeVolume = ( volumeId )->
    @model.design().component( volumeId ).remove()
    null

  ChildElementProto.moveVolume = ( volumeId )->
    design = @model.design()
    volume = design.component( volumeId )
    result = volume.isReparentable( @model )

    if _.isString( result )
      notification "error", result
      return
    else if result is false
      return false

    result = volume.attachTo( @model )
    if !result
      return false
    else
      return @volume( volumeId )
    null

  CeInstance
