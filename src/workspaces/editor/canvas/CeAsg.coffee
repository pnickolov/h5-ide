
define [ "./CanvasElement", "constant", "./CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeExpandedAsg"
    ### env:dev:end ###
    type : "ExpandedAsg"

    defaultSize : [13, 13]

    isGroup : ()-> true

    create : ()->
      m = @model
      svg = @canvas.svg

      svgEl = svg.group().add([
        svg.use("asg_frame").classes("asg-frame")
        svg.plain("").move(4,14).classes('group-label')
      ]).attr({ "data-id" : @cid }).classes( 'canvasel ExpandedAsg')

      @canvas.appendAsg svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    getLc : ()-> @model.getLc()

    render : ()->
      CanvasManager.update @$el.children("text"), @model.get("originalAsg").get("name")
  }

  CanvasElement.extend {
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
      @canvas.dragItem( evt, { onDrop : @onDropExpand } )
      false

    onDropExpand : ( evt, dataTransfer )->
      item = dataTransfer.item

      design = item.model.design()
      comp   = item.model
      target = dataTransfer.parent.model

      ExpandedAsgModel = Design.modelClassForType("ExpandedAsg")
      res = new ExpandedAsgModel({
        x           : dataTransfer.x
        y           : dataTransfer.y
        parent      : dataTransfer.parent.model
        originalAsg : item.model
      })
      if res and res.id then return

      notification 'error', sprintf(lang.ide.CVS_MSG_ERR_DROP_ASG, comp.get("name"), target.parent().get("name"))
      return

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      svgEl = svg.group().add([
        svg.use("asg_frame").classes("asg-frame")
        svg.plain("").move(4,14).classes('group-label')
        # dragger
        svg.use("asg_dragger").classes("asg-dragger tooltip").attr("data-tooltip", 'Expand the group by drag-and-drop in other availability zone.')
        svg.use("prompt_text").classes("prompt-text")

      ]).attr({ "data-id" : @cid }).classes( 'canvasel AWS-AutoScaling-Group' )

      @canvas.appendAsg svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    getLc : ()-> @model.getLc()

    render : ()->
      CanvasManager.update @$el.children("text"), @model.get("name")
  }, {
    createResource : ( type, attr, option )->
      attr.x += 1
      attr.y += 1
      CanvasElement.createResource( type, attr, option )
  }
