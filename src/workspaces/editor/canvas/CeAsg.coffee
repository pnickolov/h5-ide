
define [ "./CanvasElement", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CanvasElement, constant, CanvasManager, lang )->

  CanvasElement.extend {
    ### env:dev ###
    ClassName : "CeExpandedAsg"
    ### env:dev:end ###
    type : "ExpandedAsg"

    create : ()->
      m = @model
      svg = @canvas.svg

      svgEl = svg.group().add([
        svg.use("expanded_asg")
        svg.plain("").move(4,14).classes('group-label')
      ]).attr({ "data-id" : @cid }).classes( 'dragable ExpandedAsg')

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

    # Creates a svg element
    create : ()->
      m = @model
      svg = @canvas.svg

      svgEl = svg.group().add([
        svg.use("expanded_asg")
        svg.plain("").move(4,14).classes('group-label')
        # dragger
        svg.image(MC.IMG_URL + 'ide/icon/asg-resource-dragger.png', 22, 21).x(109).classes("asg-resource-dragger tooltip").attr({
          'data-tooltip' : 'Expand the group by drag-and-drop in other availability zone.'
        })
        svg.use("prompt_text").classes("prompt_text")

      ]).attr({ "data-id" : @cid }).classes( 'dragable AWS-AutoScaling-Group' )

      @canvas.appendAsg svgEl
      @initNode svgEl, m.x(), m.y()

      svgEl

    render : ()->
      CanvasManager.update @$el.children("text"), @model.get("name")
  }
