
define [
  "CoreEditorView"
  "OpsModel"
  "wspace/coreeditor/TplOpsEditor"
  "UI.modalplus"
  "i18n!/nls/lang.js"
  "ApiRequest"
  "AppAction"
  "constant"
], ( StackView, OpsModel, OpsEditorTpl, Modal, lang, ApiRequest, AppAction, constant )->

  StackView.extend {

    initialize : ()->
      StackView.prototype.initialize.apply this, arguments

      @updateResourcePanel()

      @toggleProcessing()
      @updateProgress()

      @listenTo @workspace.design, "change:mode", @switchMode
      return

    updateResourcePanel: ->
      if @workspace.opsModel.isMesos() and Design.modelClassForType( constant.RESTYPE.MESOSMASTER ).getMarathon() and Design.instance().get('state') isnt "Stopped"
        @renderMesosPanel()
      else
        @removeLeftPanel()

    renderMesosPanel: ->

      @resourcePanel.switchPanel?()
      # Show marathon app list
      @$( '.sidebar-nav-resource' ).hide()
      @$( '.sidebar-nav-container').show()
      #if @workspace.opsModel.id
        #@resourcePanel.loadMarathon @workspace.opsModel.getMarathonStackId()


    switchMode : ( mode )->
      @toolbar.updateTbBtns()
      @statusbar.update() if @statusbar.update

      if mode is "appedit"
        @$el.find(".OEPanelLeft").removeClass("force-hidden")
        @resourcePanel.render()
      else
        @updateResourcePanel()

      @propertyPanel.openPanel()
      return

    removeLeftPanel: ->
      @$el.find(".OEPanelLeft").addClass("force-hidden").empty()

    confirmImport : ()->
      self = @

      modal = new Modal({
          title: lang.TOOLBAR.APP_IMPORTED
          template: OpsEditorTpl.modal.confirmImport({name: @workspace.opsModel.get("name")})
          confirm: {text: "Done"}
          disableClose: true
          hideClose: true
          onCancel: ()-> self.workspace.remove(); return
      })

      # Bind App Usage
      $selectbox = modal.find("#app-usage-selectbox.selectbox")
      $selectbox.on "OPTION_CHANGE", (evt, _, result)->
        $selectbox.parent().find("input.custom-app-usage").toggleClass("show", result.value is "custom")

      modal.on "confirm", ()->
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

        usage = $("#app-usage-selectbox").find(".dropdown .item.selected").data('value') || "testing"
        if usage is "custom"
          usage = $.trim($selectbox.parent().find("input.custom-app-usage").val()) || "custom"
        json.usage = usage
        json.resource_diff = $("#MonitorImportApp").is(":checked")

        self.workspace.opsModel.importApp(json).then ()->
          design = self.workspace.design

          design.set "name", json.name
          design.set "resource_diff", json.resource_diff
          design.set "usage", json.usage

          self.updateResourcePanel()

          # "Refresh property"
          $("#OEPanelRight").trigger "REFRESH"

          modal.close()
        , ( err )->

          if err.error is ApiRequest.Errors.AppAlreadyImported
            notification "error", "The vpc `#{self.workspace.opsModel.getMsrId()}` has alreay been imported by other user."
            modal.close()
            self.workspace.remove()
          else
            notification "error", msg
            modal.tpl.find(".modal-confirm").removeAttr("disabled")
          return

      return

    toggleProcessing : ()->
      if not @$el then return

      @statusbar.update() if @statusbar.update
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
          if @workspace.__dryRunUpdate
            text += " in Dry Run mode"
        when OpsModel.State.Removing
          text = lang.IDE.REMOVING_YOUR_APP
        else
          console.warn "Unknown opsmodel state when showing loading in AppEditor,", opsModel
          text = lang.IDE.PROCESSING_YOUR_REQUEST

      @__progress = 0

      @$el.append OpsEditorTpl.appProcessing(text)
      return

    updateProgress : ()->
      if not @workspace.opsModel.isProcessing() then return
      $p = @$el.find(".ops-process")
      if not $p.length then return

      pp = @workspace.opsModel.get("progress")

      $p.toggleClass("has-progess", !!pp)

      if @__progress > pp
        $p.toggleClass("rolling-back", true)
      @__progress = pp

      pro = "#{pp}%"

      $p.find(".process-info").text( pro )
      $p.find(".bar").css { width : pro }

      @updateDetail()
      return

    updateDetail : ()->
      $processEl = @$el.find(".ops-process")
      if not $processEl.length then return

      notification = App.model.notifications().get( @workspace.opsModel.id )
      if not notification
        self = @
        App.model.notifications().once "add", ()-> self.updateDetail()
        return

      rawRequest = notification.raw()

      $detail = $processEl.children(".process-detail")
      if $detail.length is 0
        $detail = $( OpsEditorTpl.detailFrame(rawRequest.step || []) ).appendTo $processEl

      $children = $detail.children("ul").children()


      if rawRequest.state is "Rollback"
        classMap =
          done    : "pdr-3 done icon-success"
          running : "pdr-3 rolling icon-pending"
          pending : "pdr-3 rolledback icon-warning"
      else
        classMap =
          done     : "pdr-3 done icon-success"
          running  : "pdr-3 running icon-pending"
          pending  : "pdr-3 pending"


      for step, idx in rawRequest.step
        if step.length < 5 then continue

        text  = step[2] + " " + step[4]
        if step[3]
          text += " (#{step[3]})"
        $children.eq(idx).children(".pdr-2").text( text )
        $children.eq(idx).children(".pdr-3").attr("class", classMap[step[1]])

      return

    showUpdateStatus : ( error, loading )->
      @$el.find(".ops-process").remove()

      self = @
      $(OpsEditorTpl.appUpdateStatus({ error : error, loading : loading, dry_run : @workspace.__dryRunUpdate }))
        .appendTo(@$el)
        .find("#processDoneBtn")
        .click ()-> self.$el.find(".ops-process").remove()
      return

    showDryRunDone : ()->
      @$el.find(".ops-process").remove()

      self = @
      $(OpsEditorTpl.dryRunDone())
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

    showAEConflictConfirm : ()->
      if @__showingAECC then return
      @__showingAECC = true

      self = @
      modal = new Modal({
        title        : "App is operated by another user"
        template     : OpsEditorTpl.modal.AECC()
        confirm      : { text : "Save Current App to Stack" }
        cancel       : { text : "Close Tab", color : "red" }
        disableClose : true
        hideClose    : true
        onCancel     : ()-> self.workspace.remove(); return
        onConfirm    : ()->
          json = self.workspace.design.serializeAsStack()
          json.name += "-" + MC.dateFormat(new Date(),"MMddyyyy")
          App.loadUrl( self.workspace.scene.project.createStackByJson( json ).url() )
          self.workspace.remove()
          modal.close()
          return
      })

    showMarathonNotReady: ()->
      if @workspace.__marathonIsReady
        return false
      @resourcePanel.renderMarathonNotReady()

  }
