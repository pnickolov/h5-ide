
define [
  "./CanvasElement"
  "constant"
  "./CanvasManager"
  "./CpVolume"
  "./CpInstance"
  "i18n!/nls/lang.js"
  "CloudResources"
  "event"
], ( CanvasElement, constant, CanvasManager, VolumePopup, InstancePopup, lang, CloudResources, ide_event )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeDbInstance"
    ### env:dev:end ###
    type : constant.RESTYPE.DBINSTANCE

    parentType  : [ constant.RESTYPE.DBSBG, constant.RESTYPE.VPC ]
    defaultSize : [ 9, 9 ]

    portPosMap : {
      "db-sg-left"  : [ 10, 20, CanvasElement.constant.PORT_LEFT_ANGLE ]
      "db-sg-right" : [ 80, 20, CanvasElement.constant.PORT_RIGHT_ANGLE ]
    }
    portDirMap : {
      "db-sg" : "horizontal"
    }

    typeIcon   : ()-> "ide/icon/dbinstance-#{@model.category()}.png"
    engineIcon : ()-> "ide/engine/" + (@model.get("engine")||"").split("-")[0] + ".png"

    events :
      "mousedown .dbreplicate" : "replicate"

    listenModelEvents : ()->
      return

    replicate : ( evt )->
      if not @canvas.design.modeIsApp()
        @canvas.dragItem( evt, { onDrop : @onDropReplicate } )
      false

    onDropReplicate : ( evt, dataTransfer )->
      DbInstance = Design.modelClassForType( constant.RESTYPE.DBINSTANCE )
      new DbInstance({
        x        : dataTransfer.x
        y        : dataTransfer.y
        parent   : dataTransfer.parent.model
        sourceId : dataTransfer.item.model.id
      }, {
        createByUser: true
        cloneSource : dataTransfer.item.model
      })
      return

    # Creates a svg element
    create : ()->

      m = @model

      svg = @canvas.svg

      # Call parent's createNode to do basic creation
      svgEl = @createNode({
        image   : "ide/icon/dbinstance-canvas.png"
        imageX  : 15
        imageY  : 11
        imageW  : 61
        imageH  : 62
        label   : true
        labelBg : true
        sg      : true
      }).add([
        svg.image( MC.IMG_URL + @typeIcon(),   32, 15 ).move(30, 20).classes("type-image")
        svg.image( MC.IMG_URL + @engineIcon(), 32, 15 ).move(30, 40).classes('engine-image')

        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'db-sg'
          'data-alias'   : 'db-sg-left'
          'data-tooltip' : lang.ide.PORT_TIP_D
        })
        svg.use("port_diamond").attr({
          'class'        : 'port port-blue tooltip'
          'data-name'    : 'db-sg'
          'data-alias'   : 'db-sg-right'
          'data-tooltip' : lang.ide.PORT_TIP_D
        })
      ])

      if @model.get('engine') is constant.DBENGINE.MYSQL and @model.category() isnt 'replica'
        svgEl.add(
          svg.image( MC.IMG_URL + "ide/icon/dbinstance-resource-dragger.png", 22, 21 ).move( 34, 58 ).attr({
            "class"        : "dbreplicate tooltip"
            'data-tooltip' : 'Expand the group by drag-and-drop in other subnetgroup.'
          })
        )

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()
      svgEl

    # Update the svg element
    render : ()->
      m = @model

      # Update label
      CanvasManager.update @$el.children(".node-label"), m.get("name")

      # Update Type and Engine Image
      CanvasManager.update @$el.children(".type-image"), @typeIcon(), "href"
      CanvasManager.update @$el.children(".engine-image"), @engineIcon(), "href"

      # Update Image
      if m.get('engine') is constant.DBENGINE.MYSQL and m.category() isnt 'replica'
        # If mysql DB instance has disabled "Automatic Backup", the hide the create read replica button.
        CanvasManager.toggle @$el.children(".dbreplicate"), m.autobackup() isnt 0

      return

  }, {
    isDirectParentType : ( t )-> return t isnt constant.RESTYPE.VPC

    createResource : ( type, attr, option )->
      if not attr.parent then return

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

          attr.x += 2
          attr.y += 2

          return CanvasElement.createResource( constant.RESTYPE.DBINSTANCE, attr, option )

      return
  }

