
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js", "./CanvasView" ], ( CanvasElement, constant, CanvasManager, lang, CanvasView )->

  CeAsg = CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeAsg"
    ### env:dev:end ###
    type : constant.RESTYPE.ASG

    parentType  : [ constant.RESTYPE.SUBNET ]
    defaultSize : [15, 15]

    events :
      "mousedown .asg-dragger" : "dragExpand"

    isGroup : ()-> true

    size : ()-> { width : 13, height : 13 }

    dragExpand : ( evt )->
      if not @canvas.design.modeIsApp()
        @canvas.dragItem( evt, { onDrop : @onDropExpand } )
      false

    onDropExpand : ( evt, dataTransfer )->
      item = dataTransfer.item

      originalAsg = item.model
      if originalAsg.type is "ExpandedAsg"
        originalAsg = originalAsg.get("originalAsg")

      target = dataTransfer.parent.model

      ExpandedAsgModel = Design.modelClassForType("ExpandedAsg")
      res = new ExpandedAsgModel({
        x           : dataTransfer.x
        y           : dataTransfer.y
        parent      : target
        originalAsg : originalAsg
      })
      if res and res.id then return

      notification 'error', sprintf(lang.ide.CVS_MSG_ERR_DROP_ASG, originalAsg.get("name"), target.parent().get("name"))
      return

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      svgEl = svg.group().add([
        svg.rect( 129, 129 ).move(1,1).radius(5).classes("asg-group")
        svg.use("asg_frame", true).classes("asg-frame")
        svg.use("asg_prompt", true).classes("asg-prompt")
        # dragger
        svg.use("asg_dragger").classes("asg-dragger tooltip").attr("data-tooltip", 'Expand the group by drag-and-drop in other availability zone.')
        svg.plain("").move(4,14).classes('group-label')

      ]).attr({ "data-id" : @cid }).classes( 'canvasel ' + @type.split(".").join("-") )

      @canvas.appendAsg svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    getLc : ()-> @model.getLc()

    render : ()->
      CanvasManager.update @$el.children("text"), @model.get("name")

    updateConnections : ()->
      lc = @model.getLc()
      if not lc then return
      cn.update() for cn in @canvas.getItem( lc.id ).connections()
      return

    destroy : ( selectedDomElement )->
      substitute = @model.get("expandedList")

      if substitute and substitute[0]
        substitute = substitute[0]
        # We delete one of the expanded asg instead.
        substitute.parent().addChild( @model )
        x = substitute.get("x")
        y = substitute.get("y")
        substitute.remove()

        @moveBy( x - @model.get("x"), y - @model.get("y") )
        @model.set { x : x, y : y }
        return

      CanvasElement.prototype.destroy.apply this, arguments

  }, {
    createResource : ( type, attr, option )->
      if attr.lcId
        lcId = attr.lcId
        delete attr.lcId

      attr.x += 1
      attr.y += 1
      asgModel = CanvasElement.createResource( type, attr, option )

      asgModel.setLc( lcId )
      asgModel
  }


  CeAsg.extend {
    ### env:dev ###
    ClassName : "CeExpandedAsg"
    ### env:dev:end ###
    type : "ExpandedAsg"

    render : ()->
      CanvasManager.update @$el.children("text"), @model.get("originalAsg").get("name")
  }

  CeAsg
