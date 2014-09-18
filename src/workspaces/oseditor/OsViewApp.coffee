
define [
  "./OsViewStack"
  "OpsModel"
  "./template/TplOsEditor"
  "UI.modalplus"
  "i18n!/nls/lang.js"
], ( OsViewStack, OpsModel, OsEditorTpl, Modal, lang )->

  OsViewStack.extend {

    initialize : ()->
      OsViewStack.prototype.initialize.apply this, arguments

      @$el.find(".OEPanelLeft").addClass( "force-hidden" ).empty()

      @toggleProcessing()
      @updateProgress()

      @listenTo @workspace.design, "change:mode", @switchMode
      return

    switchMode : ( mode )->
      @toolbar.updateTbBtns()
      @statusbar.update()

      @propertyPanel.openPanel()
      return

    toggleProcessing : ()->
      if not @$el then return

      @toolbar.updateTbBtns()
      @statusbar.update()
      @$el.children(".ops-process").remove()

      opsModel = @workspace.opsModel
      if not opsModel.isProcessing() then return

      switch opsModel.get("state")
        when OpsModel.State.Starting
          text = "Starting your app..."
        when OpsModel.State.Stopping
          text = "Stopping your app..."
        when OpsModel.State.Terminating
          text = "Terminating your app.."
        when OpsModel.State.Updating
          text = "Applying changes to your app..."
        else
          console.warn "Unknown opsmodel state when showing loading in AppEditor,", opsModel
          text = "Processing your request..."

      @__progress = 0

      @$el.append OsEditorTpl.appProcessing(text)
      return

    updateProgress : ()->
      pp = @workspace.opsModel.get("progress")

      $p = @$el.find(".ops-process")
      $p.toggleClass("has-progess", !!pp)

      if @__progress > pp
        $p.toggleClass("rolling-back", true)
      @__progress = pp

      pro = "#{pp}%"

      $p.find(".process-info").text( pro )
      $p.find(".bar").css { width : pro }
      return

    showUpdateStatus : ( error, loading )->
      @$el.find(".ops-process").remove()

      self = @
      $(OsEditorTpl.appUpdateStatus({ error : error, loading : loading }))
        .appendTo(@$el)
        .find("#processDoneBtn")
        .click ()-> self.$el.find(".ops-process").remove()
      return
  }
