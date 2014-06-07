
define [
  "./OpsViewBase"
  "./subviews/ResourcePanel"
  "./subviews/Statusbar"
  "OpsModel"
], ( OpsViewBase, ResourcePanel, Statusbar, OpsModel )->

  OpsViewBase.extend {

    initialize : ()->
      @resourcePanel = new ResourcePanel({workspace:@workspace})
      @statusbar = new Statusbar({workspace:@workspace})
      return

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

    renderSubviews : ()->
      @resourcePanel.render()
      @statusbar.render()
      return

    clearSubviewsDom : ()->
      @resourcePanel.clearDom()
      return

    removeSubviews : ()->
      @resourcePanel.remove()
      return
  }
