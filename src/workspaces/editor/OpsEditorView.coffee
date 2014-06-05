
define [ "./TplOpsEditor", "./TplCanvas", "OpsModel", "backbone", "UI.selectbox", "MC.canvas" ], ( OpsEditorTpl, CanvasTpl, OpsModel )->

  Backbone.View.extend {

    initialize : ( options )->
      @opsModel  = options.opsModel
      @workspace = options.workspace
      return

    render : ()->
      # 1. Generate basic dom structure.
      tpl = CanvasTpl({
        noLeftPane   : true
        noBottomPane : true
      })

      console.assert( not @$el or @$el.attr("id") isnt "OpsEditor", "There should be no #OpsEditor when an editor view is rendered." )

      if @$el then @$el.remove()
      @setElement $(tpl).appendTo("#main").show()[0]

      # 1.5 Update subviews
      @renderToolbar()

      # 2. Bind Events for MC.canvas.js
      @bindEventForViewer()
      return

    # Canvas Events
    bindEventForViewer : ()->
      $("#canvas_body")
        .addClass("canvas_state_appview")
        .on('mousedown', '.instance-volume, .instanceList-item-volume, .asgList-item-volume', MC.canvas.volume.show)
        .on('mousedown', '.dragable', MC.canvas.event.dragable.mousedown)
        .on('mousedown', '.group-resizer', MC.canvas.event.groupResize.mousedown)
        .on('mouseenter mouseleave', '.node', MC.canvas.event.nodeHover)
        .on('click', '.line', MC.canvas.event.selectLine)
        .on('mousedown', '.AWS-AutoScaling-LaunchConfiguration .instance-number-group', MC.canvas.asgList.show)
        .on('mousedown', MC.canvas.event.clearSelected)
        .on('mousedown', '#svg_canvas', MC.canvas.event.clickBlank)
        .on('mousedown', MC.canvas.event.ctrlMove.mousedown)
        .on('selectstart', false)
      return


    # Toolbar
    renderToolbar : ()->
      if @opsModel.isImported()
        btns = ["BtnActionPng", "BtnZoom", "BtnLinestyle"]
      else if @opsModel.isStack()
        btns = ["BtnRunStack", "BtnStackOps", "BtnZoom", "BtnExport", "BtnLinestyle"]
      else
        if @__editMode
          btns = ["BtnApply", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]
        else
          btns = ["BtnEditApp", "BtnAppOps", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]

      tpl = ""
      for btn in btns
        tpl += OpsEditorTpl.toolbar[ btn ]()

      @$el.children("#OEMiddleWrap").children("#OEPanelTop").html( tpl )

      @updateTbBtns()
      return

    updateTbBtns : ()->
      $toolbar = @$el.children("#OEMiddleWrap").children("#OEPanelTop")

      # LineStyle Btn
      $toolbar.children(".toolbar-line-style").children(".dropdown").children().eq(parseInt(localStorage.getItem("canvas/lineStyle"),10) || 2).click()

      # App Run & Stop
      if not @opsModel.isApp() then return
      $stopBtn = $toolbar.children(".icon-stop")
      if @opsModel.get("stoppable") or @opsModel.testState( OpsModel.State.Stopped )
        $stopBtn.hide()
      else
        $stopBtn.show()

      $toolbar.children(".icon-play").toggle( @opsModel.testState( OpsModel.State.Running ) )
      return

    setTbLineStyle : ( ls )->
      localStorage.setItem("canvas/lineStyle", ls)
      # if Design.__instance.shouldDraw()
      #   # Update SgLine
      #   _.each Design.modelClassForType("SgRuleLine").allObjects(), ( cn )->
      #     cn.draw()
  }
