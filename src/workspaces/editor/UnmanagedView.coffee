
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

    createTpl : ()->
      CanvasTpl({
        noLeftPane   : true
        noBottomPane : true
      })

    bindUserEvent : ()->
      $("#OEPanelCenter")
        .on('mousedown', '.instance-volume, .instanceList-item-volume, .asgList-item-volume', MC.canvas.volume.show)
        .on('mousedown', '.AWS-AutoScaling-LaunchConfiguration .instance-number-group', MC.canvas.asgList.show)
        .on('mousedown',             '.dragable',      MC.canvas.event.dragable.mousedown)
        .on('mousedown',             '.group-resizer', MC.canvas.event.groupResize.mousedown)
        .on('mouseenter mouseleave', '.node',          MC.canvas.event.nodeHover)
        .on('click',                 '.line',          MC.canvas.event.selectLine)
        .on('mousedown', '#svg_canvas', MC.canvas.event.clickBlank)
        .on('mousedown', MC.canvas.event.clearSelected)
        .on('mousedown', MC.canvas.event.ctrlMove.mousedown)
        .on('selectstart', false)

      $("#canvas_body").addClass("canvas_state_appview")
      return

    renderSubviews : ()-> return
  }
