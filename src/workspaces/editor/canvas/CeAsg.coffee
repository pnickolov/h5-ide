
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeExpandedAsg"
    ### env:dev:end ###
    type : "ExpandedAsg"

    defaultSize : [13, 13]

    create : ()->
      m = @model
      svg = @canvas.svg

      svgEl = svg.group().add([
        svg.use("asg_frame").classes("asg-frame")
        svg.plain("").move(4,14).classes('group-label')
      ]).attr({ "data-id" : @cid }).classes( 'canvasel group ExpandedAsg')

      @canvas.appendNode svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    render : ()->
      CanvasManager.update @$el.children("text"), @model.get("originalAsg").get("name")
  }

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeAsg"
    ### env:dev:end ###
    type : constant.RESTYPE.ASG

    parentType  : [ constant.RESTYPE.SUBNET ]
    defaultSize : [13, 13]

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

      ]).attr({ "data-id" : @cid }).classes( 'canvasel group AWS-AutoScaling-Group' )

      @canvas.appendAsg svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    render : ()->
      CanvasManager.update @$el.children("text"), @model.get("name")
  }, {
    createResource : ( type, attr, option )->
      attr.x += 1
      attr.y += 1
      CanvasElement.createResource( type, attr, option )
  }
