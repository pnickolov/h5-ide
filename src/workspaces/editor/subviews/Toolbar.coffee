
define [
  "OpsModel"
  "../template/TplOpsEditor"
  "component/exporter/Thumbnail"
  "ApiRequest"
  "i18n!nls/lang.js"
  "UI.notification"
  "backbone"
], ( OpsModel, OpsEditorTpl, Thumbnail, ApiRequest, lang )->

  Backbone.View.extend {

    events :
      "click .icon-save"                   : "saveStack"
      "click .icon-delete"                 : "deleteStack"
      "click .icon-duplicate"              : "duplicateStack"
      "click .icon-new-stack"              : "createStack"
      "click .icon-zoom-in"                : "zoomIn"
      "click .icon-zoom-out"               : "zoomOut"
      "click .icon-export-png"             : "exportPng"
      "click .icon-export-json"            : "exportJson"
      "click .icon-toolbar-cloudformation" : "exportCF"
      "OPTION_CHANGE .toolbar-line-style"  : "setTbLineStyle"

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

      if @__saving
        @$el.children(".icon-save").attr("disabled", "disabled")
      else
        @$el.children(".icon-save").removeAttr("disabled")
      return

    setTbLineStyle : ( ls )->
      localStorage.setItem("canvas/lineStyle", ls)
      $canvas.updateLineStyle( ls )

    saveStack : ( evt )->
      $( evt.currentTarget ).attr("disabled", "disabled")

      self = @
      @__saving = true

      newJson = @workspace.design.serialize()

      Thumbnail.generate( $("#svg_canvas") ).catch( ()->
        return null
      ).then ( thumbnail )->
        self.workspace.opsModel.save( newJson, thumbnail ).then ()->
          self.__saving = false
          $( evt.currentTarget ).removeAttr("disabled")
          notification "info", sprintf(lang.ide.TOOL_MSG_ERR_SAVE_SUCCESS, newJson.name)
        , ( err )->
          self.__saving = false
          $( evt.currentTarget ).removeAttr("disabled")
          notification "error", sprintf(lang.ide.TOOL_MSG_ERR_SAVE_FAILED, newJson.name)
        return

    deleteStack    : ()-> App.deleteStack( @workspace.opsModel.cid, @workspace.design.get("name") )
    createStack    : ()-> App.createOps( @workspace.opsModel.get("region") )
    duplicateStack : ()->
      newOps = App.model.createStackByJson( @workspace.design.serialize() )
      App.openOps newOps
      return

    zoomIn : ()->
    zoomOut : ()->
    exportPng : ()->
    exportJson : ()->
    exportCF : ()->
  }
