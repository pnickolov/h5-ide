
define [
  "./template/TplCanvas"
  "./template/TplOpsEditor"
  "./subviews/PropertyPanel"
  "./subviews/Toolbar"
  "./subviews/ResourcePanel"
  "./subviews/Statusbar"
  "./canvas/CanvasBundle"
  "UI.modalplus"

  "backbone"
  "UI.selectbox"
  "MC.canvas"
], ( CanvasTpl, OpsEditorTpl, PropertyPanel, Toolbar, ResourcePanel, Statusbar, CanvasView, Modal )->

  # LEGACY code
  # Should remove this in the future.
  $(document).on('keydown', MC.canvas.event.keyEvent)
  $('#header, #navigation, #tab-bar').on('click', MC.canvas.volume.close)
  $(document.body).on('mousedown', '#instance_volume_list a', MC.canvas.volume.mousedown)


  ### OpsEditorView base class ###
  Backbone.View.extend {

    constructor : ( options )->
      _.extend this, options

      console.assert( not @$el or @$el.attr("id") isnt "OpsEditor", "There should be no #OpsEditor when an editor view is rendered." )
      @setElement $( @createTpl() ).appendTo("#main").show()[0]
      @$el.attr("data-workspace", @workspace.id)

      opt = {
        workspace : @workspace
        parent    : @
      }

      @toolbar       = new Toolbar(opt)
      @propertyPanel = new PropertyPanel(opt)
      @resourcePanel = new ResourcePanel(opt)
      @statusbar     = new Statusbar(opt)
      @canvas        = new CanvasView(opt)

      # 2. Bind Events for MC.canvas.js
      @bindUserEvent()

      # 3 Update subviews
      @statusbar.render()

      @renderSubviews()

      @initialize()
      return

    backup : ()->
      $center = @$el.find(".OEPanelCenter")
      @__backupSvg = $center.html()
      $center.empty()

      ###
      Revoke all the IDs of every dom.
      ###
      @propertyPanel.backup()

      @backupSubviews()
      @$el.attr("id", "")
      return

    recover : ()->
      @$el.find(".OEPanelCenter").html @__backupSvg
      @__backupSvg = null

      @resourcePanel.recalcAccordion()
      @recoverSubviews()
      @$el.attr("id", "OpsEditor")

      @propertyPanel.recover()
      return

    remove : ()->
      @toolbar.remove()
      @propertyPanel.remove()
      @resourcePanel.remove()
      @statusbar.remove()
      @canvas.remove()

      Backbone.View.prototype.remove.call this
      return

    showCloseConfirm : ()->
      name = @workspace.design.get('name')
      self = @
      modal = new Modal {
        title    : "Confirm to close #{name}"
        width    : "420"
        template : OpsEditorTpl.modal.onClose(name)
        confirm  : {text:"Close Tab", color:"red"}
        onConfirm  : ()->
          modal.close()
          self.workspace.remove()
          return
      }
      return

    saveOps : ()-> App.saveOps( @workspace.opsModel )

    ###
      Override these methods in subclasses.
    ###
    createTpl        : ()-> CanvasTpl({})
    bindUserEvent    : ()-> return
    # Called when the OpsEditor initialize
    renderSubviews  : ()-> return
    # Called when the OpsEditor wakes up.
    recoverSubviews : ()-> return
    # Called when the OpsEditor sleeps
    backupSubviews  : ()-> return
  }
