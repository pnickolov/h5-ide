
define [
  "./AwsViewStack"
  "OpsModel"
  "./template/TplOpsEditor"
  "UI.modalplus"
  "i18n!/nls/lang.js"
], ( AwsViewStack, OpsModel, OpsEditorTpl, Modal, lang )->

  AwsViewStack.extend {

    initialize : ()->
      AwsViewStack.prototype.initialize.apply this, arguments

      @$el.find(".OEPanelLeft").addClass( "force-hidden" ).empty()

      @toggleProcessing()
      @updateProgress()

      @listenTo @workspace.design, "change:mode", @switchMode
      return

    switchMode : ( mode )->
      @toolbar.updateTbBtns()
      @statusbar.update()

      if mode is "appedit"
        @$el.find(".OEPanelLeft").removeClass("force-hidden")
        @resourcePanel.render()
      else
        @$el.find(".OEPanelLeft").addClass("force-hidden").empty()

      @propertyPanel.openPanel()
      return

    confirmImport : ()->
      self = @

      modal = new Modal({
        title        : "App Imported"
        template     : OpsEditorTpl.modal.confirmImport({ name : @workspace.opsModel.get("name") })
        confirm      : { text : "Done" }
        disableClose : true
        hideClose    : true
        onCancel     : ()-> self.workspace.remove(); return
        onConfirm    : ()->
          $ipt = modal.tpl.find("#ImportSaveAppName")
          $ipt.parsley 'custom', ( val ) ->
            if not MC.validate 'awsName',  val
              return lang.ide.PARSLEY_SHOULD_BE_A_VALID_STACK_NAME

            apps = App.model.appList().where({name:val})
            if apps.length is 1 and apps[0] is self.workspace.opsModel or apps.length is 0
              return

            sprintf lang.ide.PARSLEY_TYPE_NAME_CONFLICT, 'App', val

          if not $ipt.parsley 'validate'
            return

          modal.tpl.find(".modal-confirm").attr("disabled", "disabled")
          json       = self.workspace.design.serialize()
          json.name  = $ipt.val()
          json.usage = $("#app-usage-selectbox").find(".item.selected").attr('data-value') || "testing"
          json.resource_diff = $("#MonitorImportApp").is(":checked")

          self.workspace.opsModel.saveApp(json).then ()->
            design = self.workspace.design

            design.set "name", json.name
            design.set "resource_diff", json.resource_diff
            design.set "usage", json.usage

            # "Refresh property"
            $("#OEPanelRight").trigger "REFRESH"

            modal.close()
          , ( err )->
            notification "error", err.msg
            modal.tpl.find(".modal-confirm").removeAttr("disabled")
            return
      })
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

      @$el.append OpsEditorTpl.appProcessing(text)
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
      $(OpsEditorTpl.appUpdateStatus({ error : error, loading : loading }))
        .appendTo(@$el)
        .find("#processDoneBtn")
        .click ()-> self.$el.find(".ops-process").remove()
      return
  }
