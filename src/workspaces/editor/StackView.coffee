
define [
  "./OpsViewBase"
  "./template/TplLeftPanel"
  "./template/TplCanvas"
  "OpsModel"
  "backbone"
  "UI.selectbox"
  "MC.canvas"
], ( OpsViewBase, LeftPanelTpl, CanvasTpl, OpsModel )->

  OpsViewBase.extend {

    createTpl : ()-> CanvasTpl({})

    bindUserEvent : ()->
      # Events
      $("#OEPanelCenter")
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

      $("#canvas_body").addClass("canvas_state_stack")

      $("#OEPanelLeft").on('mousedown', '.resource-item', MC.canvas.event.siderbarDrag.mousedown)
      return

    updateTbBtns : ( $toolbar )->
      OpsViewBase.prototype.updateTbBtns.call( this , $toolbar )
      return

    renderSubviews : ()->
      # Resource Panel
      $("#OEPanelLeft").html LeftPanelTpl.panel({})

      OpsViewBase.prototype.renderSubviews.call( this )
      return

  }
