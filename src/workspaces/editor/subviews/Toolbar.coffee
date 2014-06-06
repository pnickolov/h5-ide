
define [ "../template/TplOpsEditor", "backbone" ], ( OpsEditorTpl )->

  Backbone.View.extend {

    # events :
    #   "click" : ""

    render : ()->
      opsModel = @workspace.opsModel

      # Toolbar
      if opsModel.isImported()
        btns = ["BtnActionPng", "BtnZoom", "BtnLinestyle"]
      else if opsModel.isStack()
        btns = ["BtnRunStack", "BtnStackOps", "BtnZoom", "BtnExport", "BtnLinestyle"]
      else
        if @__editMode
          btns = ["BtnApply", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]
        else
          btns = ["BtnEditApp", "BtnAppOps", "BtnZoom", "BtnPng", "BtnLinestyle", "BtnReloadRes"]

      tpl = ""
      for btn in btns
        tpl += OpsEditorTpl.toolbar[ btn ]()

      @setElement $("#OEPanelTop").html( tpl )

      @updateTbBtns()
      return

    clearDom : ()->
      @$el = null
      return

    updateTbBtns : ()->
      opsModel = @workspace.opsModel

      # LineStyle Btn
      @$el.children(".toolbar-line-style").children(".dropdown").children().eq(parseInt(localStorage.getItem("canvas/lineStyle"),10) || 2).click()

      # App Run & Stop
      if opsModel.isApp()
        $stopBtn = @$el.children(".icon-stop")
        if opsModel.get("stoppable") or not opsModel.testState( OpsModel.State.Running )
          $stopBtn.hide()
        else
          $stopBtn.show()

        @$el.children(".icon-play").toggle( not opsModel.testState( OpsModel.State.Stopped ) )
      return

    setTbLineStyle : ( ls )->
      localStorage.setItem("canvas/lineStyle", ls)
      $canvas.updateLineStyle( ls )
      return
  }
