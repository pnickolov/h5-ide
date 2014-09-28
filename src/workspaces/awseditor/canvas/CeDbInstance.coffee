
define [
  "CanvasElement"
  "constant"
  "CanvasManager"
  "./CpVolume"
  "./CpInstance"
  "i18n!/nls/lang.js"
  "CloudResources"
  "DbSubnetGPopup"
], ( CanvasElement, constant, CanvasManager, VolumePopup, InstancePopup, lang, CloudResources, DbSubnetGPopup )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeDbInstance"
    ### env:dev:end ###
    type : constant.RESTYPE.DBINSTANCE

    parentType  : [ constant.RESTYPE.DBSBG, constant.RESTYPE.VPC ]
    defaultSize : [ 9, 9 ]

    portPosMap : {
      "db-sg-left"  : [ 10, 35, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "db-sg-right" : [ 79, 35, CanvasElement.constant.PORT_RIGHT_ANGLE ]
      "replica"     : [ 45, 45, CanvasElement.constant.PORT_DOWN_ANGLE ]
    }
    portDirMap : {
      "db-sg" : "horizontal"
    }

    portPosition : ( portName, isAtomic )->
      p = @portPosMap[ portName ]
      if portName is "replica"
        p = p.slice(0)
        if @model.master()
          p[1] = 45
          p[2] = CanvasElement.constant.PORT_2D_V_ANGLE
        else
          p[1] = 61
          p[2] = CanvasElement.constant.PORT_DOWN_ANGLE
      p

    typeIcon   : ()-> "ide/icon/icn-#{@model.category()}.png"
    engineIcon : ()-> "ide/icon/rds-" + (@model.get("engine")||"").split("-")[0] + ".png"

    events :
      "mousedown .dbreplicate" : "replicate"
      "mousedown .dbrestore"   : "restore"

    listenModelEvents : ()->
      @listenTo @model, "change:backupRetentionPeriod", @render
      @listenTo @model, "change:connections", @updateReplicaTip
      @listenTo @canvas, "change:externalData", @updateState
      return

    updateState: ->
      m = @model
      stateIcon  = @$el.children(".res-state")

      if stateIcon
        appData = CloudResources( m.type, m.design().region() ).get( m.get("appId") )
        state    = appData?.get("DBInstanceStatus") || "unknown"
        stateIcon.data("tooltip", state).attr("data-tooltip", state).attr("class", "res-state tooltip #{state}")

    updateReplicaTip : ( cnn )->
      if cnn.type is "DbReplication"
        @render()
      return

    replicate : ( evt )->

      if not @canvas.design.modeIsApp() and @model.slaves().length < 5

        # for level 2 replica
        appData = CloudResources( @model.type, @model.design().region() ).get( @model.get("appId") )
        if appData
          backup = (appData.get('BackupRetentionPeriod') not in [0, '0'])
        if @model.autobackup() and @model.get('appId') and not backup
          return false

        @canvas.dragItem( evt, { onDrop : @onDropReplicate } )

      false

    restore : ( evt )->
      if not @canvas.design.modeIsApp()
        @canvas.dragItem( evt, { onDrop : @onDropRestore } )
      false

    onDropReplicate : ( evt, dataTransfer )->

      targetSubnetGroup = dataTransfer.parent.model
      if targetSubnetGroup isnt dataTransfer.item.model.parent()
        notification "error", lang.NOTIFY.READ_REPLICA_MUST_BE_DROPPED_IN_THE_SAME_SBG
        return

      # If the model supports clone() interface, then clone the target.
      name = dataTransfer.item.model.get("name")
      nameMatch = name.match /(.+-replica)(\d*)$/
      if nameMatch
        name = nameMatch[1] + ((parseInt(nameMatch[2],10) || 0) + 1)
      else
        name += "-replica"

      DbInstance = Design.modelClassForType( constant.RESTYPE.DBINSTANCE )
      replica = new DbInstance({
        x        : dataTransfer.x
        y        : dataTransfer.y
        name     : name
        parent   : targetSubnetGroup
        sourceId : dataTransfer.item.model.id
      }, {
        master : dataTransfer.item.model
      })

      if replica.id
        dataTransfer.item.canvas.selectItem( replica.id )

      return

    onDropRestore : ( evt, dataTransfer )->

      targetSubnetGroup = dataTransfer.parent.model

      # If the model supports clone() interface, then clone the target.
      name = dataTransfer.item.model.get("name")

      DbInstance = Design.modelClassForType( constant.RESTYPE.DBINSTANCE )
      newDbIns = new DbInstance({
        x        : dataTransfer.x
        y        : dataTransfer.y
        name     : "from-" + name
        parent   : targetSubnetGroup
      }, {
        master : dataTransfer.item.model
        isRestore: true
      })

      if newDbIns.id
        dataTransfer.item.canvas.selectItem( newDbIns.id )

      return


    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/cvs-rds.png"
        imageX  : 14
        imageY  : 8
        imageW  : 62
        imageH  : 66
        label   : true
        labelBg : true
        sg      : true
      }).add([
        svg.image( MC.IMG_URL + @engineIcon(), 46, 33 ).move(22, 18).classes('engine-image')

        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'db-sg'
          'data-alias'   : 'db-sg-left'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'db-sg'
          'data-alias'   : 'db-sg-right'
          'data-tooltip' : lang.IDE.PORT_TIP_D
        })
      ])

      if @model.get('engine') is constant.DB_ENGINE.MYSQL
        svgEl.add( svg.use("port_diamond").attr({'data-name' : 'replica'}), 0 )
        if @model.master()
          svgEl.add( svg.plain("REPLICA").move(45,60).classes("replica-text") )
          svgEl.add( svg.use("replica_dragger").attr({"class" : "dbreplicate tooltip"}) )
        else
          svgEl.add( svg.plain("MASTER").move(45,60).classes("master-text") )
          svgEl.add( svg.use("replica_dragger").attr({"class" : "dbreplicate tooltip"}) )

      # Create State Icon
      if not m.design().modeIsStack() and m.get("appId")
        svgEl.add( svg.circle(8).move(63, 15).classes('res-state unknown') )

      svgEl.add( svg.use("restore_dragger").attr({"class" : "dbrestore tooltip"}) )

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    # Update the svg element
    render : ()->
      m = @model

      # Update label
      CanvasManager.setLabel @, @$el.children(".node-label")

      # Update Type and Engine Image
      CanvasManager.update @$el.children(".type-image"), @typeIcon(), "href"
      CanvasManager.update @$el.children(".engine-image"), @engineIcon(), "href"

      CanvasManager.toggle @$el.children(".master-text"), m.design().modeIsApp() and m.slaves().length

      # Update replica Image
      if m.get('engine') is constant.DB_ENGINE.MYSQL

        # If mysql DB instance has disabled "Automatic Backup", then hide the create read replica button.
        $r = @$el.children(".dbreplicate")

        appData = CloudResources( m.type, m.design().region() ).get( m.get("appId") )
        if appData
          backup = (appData.get('BackupRetentionPeriod') not in [0, '0'])

        if m.slaves().length < 5

          CanvasManager.removeClass $r, "disabled"

          if m.autobackup()

            tip = "Drag to create a read replica."

            if m.category() is 'replica' and m.master() and m.master().master()

              CanvasManager.toggle $r, false

            else

              CanvasManager.toggle $r, true

              if m.get('appId') and not backup

                tip = "Please wait Automatic Backup to be enabled to create read replica."
                CanvasManager.addClass $r, "disabled"

          else

            tip = "Drag to create a read replica."
            CanvasManager.toggle $r, false

        else

          tip = "Cannot create more read replica."
          CanvasManager.toggle $r, true
          CanvasManager.addClass $r, "disabled"

        CanvasManager.update $r, tip, "tooltip"

        if m.getSourceDBForRestore()
          CanvasManager.toggle $r, false

      # Update restore Image

      # $r = @$el.children(".dbrestore")
      # enableRestore = m.autobackup() isnt 0 and !!m.get("appId")
      # CanvasManager.toggle $r, enableRestore
      # if enableRestore
      #   CanvasManager.update $r, 'Drag to restore to point in time', "tooltip"

      $r = @$el.children(".dbrestore")
      CanvasManager.toggle $r, !!m.get("appId")
      CanvasManager.update $r, 'Drag to restore to point in time', "tooltip"

      appData = CloudResources( m.type, m.design().region() ).get( m.get("appId") )
      if appData
        penddingObj = appData.get('PendingModifiedValues')
        if (appData.get('BackupRetentionPeriod') in [0, '0']) or (penddingObj and penddingObj.BackupRetentionPeriod in [0, '0'])
          CanvasManager.toggle $r, false

      @updateState()

      return

  }, {
    isDirectParentType : ( t )-> return t isnt constant.RESTYPE.VPC

    createResource : ( type, attr, option )->
      if not attr.parent then return

      if option and option.cloneSource?.master()
        # If we are cloning a replica, we should check if we can
        # If the model supports clone() interface, then clone the target.
        if option.cloneSource.master().slaves().length > 5
          notification "error", lang.NOTIFY.CANNOT_CREATE_MORE_READ_REPLICA
          return
        else
          option.master = option.cloneSource.master()
          delete option.cloneSource

      switch attr.parent.type
        when constant.RESTYPE.DBSBG
          return CanvasElement.createResource( type, attr, option )

        when constant.RESTYPE.VPC
          # Auto add subnet for instance
          attr.parent = CanvasElement.createResource( constant.RESTYPE.DBSBG, {
            x      : attr.x + 1
            y      : attr.y + 1
            width  : 11
            height : 11
            parent : attr.parent
          } , option )

          if not attr.parent.id
            notification "error", lang.NOTIFY.CANNOT_CREATE_SBG_DUE_TO_INSUFFICIENT_SUBNETS
            return

          attr.x += 2
          attr.y += 2

          new DbSubnetGPopup({model:attr.parent})

          return CanvasElement.createResource( constant.RESTYPE.DBINSTANCE, attr, option )

      return
  }

