
define [ "./OpsEditorView", "./TplOpsEditor", "./TplCanvas", "OpsModel", "backbone", "UI.selectbox", "MC.canvas" ], ( OpsEditorView, OpsEditorTpl, CanvasTpl, OpsModel )->

  OpsEditorView.extend {

    createTpl : ()-> CanvasTpl({})

    bindUserEvent : ()->
      # Events
      $("#canvas_body")
        .addClass("canvas_state_stack")
        .on('mousedown',             '.port',             MC.canvas.event.drawConnection.mousedown)
        .on('mousedown',             '.dragable',         MC.canvas.event.dragable.mousedown)
        .on('mousedown',             '.group-resizer',    MC.canvas.event.groupResize.mousedown)
        .on('mouseenter mouseleave', '.node',             MC.canvas.event.nodeHover)
        .on('click',                 '.line',             MC.canvas.event.selectLine)
        .on('mousedown',             '#svg_canvas',       MC.canvas.event.clickBlank)
        .on('mousedown',             '#node-action-wrap', MC.canvas.nodeAction.popup)
        .on('mousedown',   MC.canvas.event.ctrlMove.mousedown)
        .on('mousedown',   MC.canvas.event.clearSelected)
        .on('selectstart', false)
      return

    updateTbBtns : ( $toolbar )->
      OpsEditorView.prototype.updateTbBtns.call( this , $toolbar )
      return

    renderSubviews : ()->
  }
