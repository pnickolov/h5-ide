
define [ "./OpsViewBase" ], ( OpsViewBase )->

  OpsViewBase.extend {

    events :
      "SAVE" : "saveStack"

    initialize : ()->
      @canvas.switchMode( "stack" )

    # bindUserEvent : ()->
    #   # Events
    #   @$el.find(".OEPanelCenter")
    #     .on('mousedown',             '.port',             MC.canvas.event.drawConnection.mousedown)
    #     .on('mousedown',             '.dragable',         MC.canvas.event.dragable.mousedown)
    #     .on('mousedown',             '.group-resizer',    MC.canvas.event.groupResize.mousedown)
    #     .on('mouseenter mouseleave', '.node',             MC.canvas.event.nodeHover)
    #     .on('click',                 '.line',             MC.canvas.event.selectLine)
    #     .on('mousedown',             '#svg_canvas',       MC.canvas.event.clickBlank)
    #     .on('mousedown',             '#node-action-wrap', MC.canvas.nodeAction.popup)
    #     .on('mousedown',   MC.canvas.event.ctrlMove.mousedown)
    #     .on('mousedown',   MC.canvas.event.clearSelected)
    #     .on('selectstart', false)

    #   $("#canvas_body").addClass("canvas_state_stack")
    #   return

    saveStack : ()-> @toolbar.$el.find(".icon-save").trigger "click"
  }
