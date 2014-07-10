
define [ "i18n!/nls/lang.js", "./CanvasElement", "constant", "CanvasManager", "Design", "CloudResources" ], ( lang, CanvasElement, constant, CanvasManager, Design, CloudResources )->

  CeDBInstance = ()-> CanvasElement.apply( this, arguments )
  CanvasElement.extend( CeDBInstance, constant.RESTYPE.DBINSTANCE )
  ChildElementProto = CeDBInstance.prototype

  ###
  # Child Element's interface.
  ###
  ChildElementProto.portPosMap = {
    "dbinstance-sg-left"  : [ 15, 40, CanvasElement.constant.PORT_LEFT_ANGLE ]
    "dbinstance-sg-right" : [ 75, 40, CanvasElement.constant.PORT_RIGHT_ANGLE ]
  }
  ChildElementProto.portDirMap = {
    "dbinstance-sg" : "horizontal"
  }

  ChildElementProto.iconUrl = ( attr ) ->
    if attr is "type"
      switch @model.category()
        when "snapshot" then "ide/icon/dbinstance-snap.png"
        when "replica"  then "ide/icon/dbinstance-read.png"
        when "instance" then "ide/icon/dbinstance-source.png"
        else
          console.warn "[iconUrl]unknown category of RDS DBInstance"
          "ide/icon/dbinstance-source.png"

    else if attr is "engine"
      engine = @model.get("engine")
      if engine
        "ide/engine/" + engine.split("-")[0] + ".png"
      else
        console.warn "[iconUrl]unknown engine of RDS DBInstance"
        "ide/engine/unknown.png"

  ChildElementProto.rdsCreateReadReplica = ( parentId, x, y )->
    design = @model.design()

    # Exapnd
    comp   = @model
    target = design.component(parentId)

    if target
      DBInstanceModel = Design.modelClassForType( constant.RESTYPE.DBINSTANCE )
      attr =
        x : x
        y : y
        parent : target
        sourceId : comp.id
      option =
        createByUser: true
        cloneSource : comp

      res = new DBInstanceModel(attr, option)

    if res and res.id
      $canvas(res.id).select();
      return true

    #targetName = if target.type is "AWS.EC2.AvailabilityZone" then target.get("name") else target.parent().get("name")
    #notification 'error', sprintf lang.ide.CVS_MSG_ERR_DROP_ASG, comp.get("name"), targetName

    return false

  ChildElementProto.draw = ( isCreate ) ->
    m = @model

    if isCreate

      # Call parent's createNode to do basic creation
      node = @createNode({
        image   : "ide/icon/dbinstance-canvas.png"
        imageX  : 15
        imageY  : 9
        imageW  : 61
        imageH  : 62
        label   : m.get("name")
        labelBg : true
        sg      : true
      })

      # Insert Type / Engine / Port
      node.append(
        # Type Icon
        Canvon.image( MC.IMG_URL + @iconUrl("type"), 30, 20, 32, 15 ).attr({'class':"type-image"}),
        # Engine Icon
        Canvon.image( MC.IMG_URL + @iconUrl("engine"), 30, 40, 32, 15 ).attr({'class':"engine-image"}),

        # left port(blue)
        Canvon.path(this.constant.PATH_PORT_DIAMOND).attr({
          'class'          : 'port port-blue port-dbinstance-sg port-dbinstance-sg-left tooltip'
          'data-name'      : 'dbinstance-sg' #for identify port
          'data-alias'     : 'dbinstance-sg-left'
          'data-position'  : 'left' #port position: for calc point of junction
          'data-type'      : 'sg'   #color of line
          'data-direction' : 'in'   #direction
          'data-tooltip'   : lang.ide.PORT_TIP_D
        }),

        # right port(blue)
        Canvon.path(this.constant.PATH_PORT_DIAMOND).attr({
          'class'          : 'port port-blue port-dbinstance-sg port-dbinstance-sg-right tooltip'
          'data-name'      : 'dbinstance-sg'
          'data-alias'     : 'dbinstance-sg-right'
          'data-position'  : 'right'
          'data-type'      : 'sg'
          'data-direction' : 'out'
          'data-tooltip'   : lang.ide.PORT_TIP_D
        })

      )

      if @model.get('engine') is constant.DBENGINE.MYSQL and @model.category() isnt 'replica'
        #only mysql support ReadReplica
        node.append(
          # dragger
          Canvon.image(MC.IMG_URL + 'ide/icon/dbinstance-resource-dragger.png', 34, 58, 22, 21).attr({
            'id'           : 'dbinstance-dragger-' + m.id
            'class'        : 'dbinstance-resource-dragger tooltip'
            'data-tooltip' : 'Expand the group by drag-and-drop in other subnetgroup.'
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

      if @model.get('engine') is constant.DBENGINE.MYSQL and @model.category() isnt 'replica'
        # If mysql DB instance has disabled "Automatic Backup", the hide the create read replica button.
        if @model.autobackup() is 0
          Canvon( '#dbinstance-dragger-' + m.id ).addClass('hide')
        else
          Canvon( '#dbinstance-dragger-' + m.id ).removeClass('hide')

    if not @model.design().modeIsStack() and m.get("appId")
      # Update Instance State in app
      @updateAppState()

    # Update Type and Engine Image
    CanvasManager.update node.children(".type-image"), @iconUrl("type"), "href"
    CanvasManager.update node.children(".engine-image"), @iconUrl("engine"), "href"


    null




  CeDBInstance
