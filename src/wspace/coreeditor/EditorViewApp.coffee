
define [
  "CoreEditorView"
  "OpsModel"
  "wspace/coreeditor/TplOpsEditor"
  "UI.modalplus"
  "i18n!/nls/lang.js"
  "AppAction"
], ( StackView, OpsModel, OpsEditorTpl, Modal, lang, AppAction )->

  StackView.extend {

    initialize : ()->
      StackView.prototype.initialize.apply this, arguments

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
        title        : lang.TOOLBAR.APP_IMPORTED
        template     : OpsEditorTpl.modal.confirmImport({ name : @workspace.opsModel.get("name") })
        confirm      : { text : "Done" }
        disableClose : true
        hideClose    : true
        onCancel     : ()-> self.workspace.remove(); return
        onConfirm    : ()->
          $ipt = modal.tpl.find("#ImportSaveAppName")
          $ipt.parsley 'custom', ( val ) ->
            if not MC.validate 'awsName',  val
              return lang.PARSLEY.SHOULD_BE_A_VALID_STACK_NAME

            apps = self.workspace.scene.project.apps().where({name:val})
            if apps.length is 1 and apps[0] is self.workspace.opsModel or apps.length is 0
              return

            sprintf lang.PARSLEY.TYPE_NAME_CONFLICT, 'App', val

          if not $ipt.parsley 'validate'
            return

          modal.tpl.find(".modal-confirm").attr("disabled", "disabled")
          json       = self.workspace.design.serialize()
          json.name  = $ipt.val()
          json.usage = $("#app-usage-selectbox").find(".item.selected").attr('data-value') || "testing"
          json.resource_diff = $("#MonitorImportApp").is(":checked")

          self.workspace.opsModel.importApp(json).then ()->
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

      @statusbar.update()
      @$el.children(".ops-process").remove()

      opsModel = @workspace.opsModel
      if not opsModel.isProcessing() then return

      switch opsModel.get("state")
        when OpsModel.State.Starting
          text = lang.IDE.STARTING_YOUR_APP
        when OpsModel.State.Stopping
          text = lang.IDE.STOPPING_YOUR_APP
        when OpsModel.State.Terminating
          text = lang.IDE.TERMINATING_YOUR_APP
        when OpsModel.State.Updating
          text = lang.IDE.APPLYING_CHANGES_TO_YOUR_APP
        else
          console.warn "Unknown opsmodel state when showing loading in AppEditor,", opsModel
          text = lang.IDE.PROCESSING_YOUR_REQUEST

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

    showUnpayUI : ()->
      @statusbar.remove()
      @propertyPanel.remove()
      @toolbar.remove()

      @canvas.updateSize()

      new AppAction( workspace: @workspace ).showPayment( $("<div class='ops-apppm-wrapper'></div>", @workspace.opsModel).appendTo(@$el)[0] )
      notification "error", "Your account is limited now."
      return

    listenToPayment: ()->
      self = @
      @workspace.listenTo @workspace.scene.project, "change:billingState", ->
        if not $(".ops-apppm-wrapper").size()
          if self.workspace.scene.project.shouldPay()
            self.showUnpayUI()
        else
          unless self.workspace.scene.project.shouldPay()
            self.reopenApp()

    reopenApp: ()->
      appUrl = @workspace.opsModel.url()
      @workspace.remove()
      _.defer ->
        App.loadUrl(appUrl)
        notification "info", "User payment status change detected, reloading app resource."

  }
