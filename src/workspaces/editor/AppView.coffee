
define [
  "./StackView"
  "OpsModel"
  "./template/TplOpsEditor"
  "UI.modalplus"
  "i18n!/nls/lang.js"
], ( StackView, OpsModel, OpsEditorTpl, Modal, lang )->

  StackView.extend {

    initialize : ()->
      @canvas.switchMode( "app" )

    # bindUserEvent : ()->
    #   # Events
    #   if @workspace.isAppEditMode()
    #     @$el.find(".OEPanelCenter")
    #       .removeClass('canvas_state_app').addClass("canvas_state_appedit")
    #       .off(".CANVAS_EVENT")
    #       .on('mousedown.CANVAS_EVENT', '.instance-volume, .instanceList-item-volume, .asgList-item-volume', MC.canvas.volume.show)
    #       .on('mousedown.CANVAS_EVENT', '.port', MC.canvas.event.appDrawConnection)
    #       .on('mousedown.CANVAS_EVENT', '.dragable', MC.canvas.event.dragable.mousedown)
    #       .on('mousedown.CANVAS_EVENT', '.group-resizer', MC.canvas.event.groupResize.mousedown)
    #       .on('click.CANVAS_EVENT', '.line', MC.canvas.event.selectLine)
    #       .on('mousedown.CANVAS_EVENT', MC.canvas.event.clearSelected)
    #       .on('mousedown.CANVAS_EVENT', '#svg_canvas', MC.canvas.event.clickBlank)
    #       .on('mouseenter.CANVAS_EVENT mouseleave.CANVAS_EVENT', '.node', MC.canvas.event.nodeHover)
    #       .on('selectstart.CANVAS_EVENT', false)
    #       .on('mousedown.CANVAS_EVENT', MC.canvas.event.ctrlMove.mousedown)
    #       .on('mousedown.CANVAS_EVENT', '#node-action-wrap', MC.canvas.nodeAction.popup)
    #   else
    #     @$el.find(".OEPanelCenter")
    #       .removeClass('canvas_state_appedit').addClass("canvas_state_app")
    #       .off(".CANVAS_EVENT")
    #       .on('mousedown.CANVAS_EVENT', '.instance-volume, .instanceList-item-volume, .asgList-item-volume', MC.canvas.volume.show)
    #       .on('click.CANVAS_EVENT', '.line', MC.canvas.event.selectLine)
    #       .on('mousedown.CANVAS_EVENT', MC.canvas.event.clearSelected)
    #       .on('mousedown.CANVAS_EVENT', '#svg_canvas', MC.canvas.event.clickBlank)
    #       .on('selectstart.CANVAS_EVENT', false)
    #       .on('mousedown.CANVAS_EVENT', '.dragable', MC.canvas.event.selectNode)
    #       .on('mousedown.CANVAS_EVENT', '.AWS-AutoScaling-LaunchConfiguration .instance-number-group', MC.canvas.asgList.show)
    #       .on('mousedown.CANVAS_EVENT', '.AWS-EC2-Instance .instance-number-group', MC.canvas.instanceList.show)
    #       .on('mousedown.CANVAS_EVENT', '.AWS-VPC-NetworkInterface .eni-number-group', MC.canvas.eniList.show)
    #       .on('mousedown.CANVAS_EVENT', MC.canvas.event.ctrlMove.mousedown)
    #       .on('mousedown.CANVAS_EVENT', '#node-action-wrap', MC.canvas.nodeAction.popup)
    #       .on('mouseenter.CANVAS_EVENT mouseleave.CANVAS_EVENT', '.node', MC.canvas.event.nodeHover)
    #   return

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
          json = self.workspace.design.serialize()
          json.name = $ipt.val()
          self.workspace.opsModel.saveApp(json).then ()->
            self.workspace.design.set "name", json.name
            modal.close()
          , ( err )->
            notification "error", err.msg
            modal.tpl.find(".modal-confirm").removeAttr("disabled")
            return
      })
      return

    renderSubviews : ()->
      if @workspace.isAppEditMode()
        @resourcePanel.render()

      @$el.find(".OEPanelLeft").toggleClass "force-hidden", !@workspace.isAppEditMode()

      @statusbar.render()

      @toggleProcessing()
      @updateProgress()
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

    switchMode : ( isAppEditMode )->
      # HACK, Close the volume bubble here!!!!!
      # Should be removed.
      MC.canvas.volume.close()

      @toolbar.updateTbBtns()
      @statusbar.update()

      @$el.find(".OEPanelLeft").toggleClass "force-hidden", !isAppEditMode
      if isAppEditMode
        @resourcePanel.render()
      else
        @$el.find(".OEPanelLeft").empty()
      @propertyPanel.openPanel()

      @canvas.switchMode( if isAppEditMode then "appedit" else "app" )
      return

    emptyCanvas : ()->
      $("#vpc_layer, #az_layer, #subnet_layer, #asg_layer, #line_layer, #node_layer").empty()
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
