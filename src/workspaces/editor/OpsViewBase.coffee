
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
], ( CanvasTpl, OpsEditorTpl, PropertyPanel, Toolbar, ResourcePanel, Statusbar, CanvasView, Modal )->

  # LEGACY code
  # Should remove this in the future.
  # $('#header, #navigation, #tab-bar').on('click', MC.canvas.volume.close)
  # $(document.body).on('mousedown', '#instance_volume_list a', MC.canvas.volume.mousedown)


  ### Monitor keypress ###
  $(document).on 'keydown', ( evt )->



  ### OpsEditorView base class ###
  Backbone.View.extend {

    events :
      "SAVE" : "saveStack"

    constructor : ( options )->
      _.extend this, options

      console.assert( not @$el or @$el.attr("id") isnt "OpsEditor", "There should be no #OpsEditor when an editor view is rendered." )
      @setElement $( CanvasTpl({}) ).appendTo("#main").show()[0]
      @$el.attr("data-ws", @workspace.id)

      opt = {
        workspace : @workspace
        parent    : @
      }

      @toolbar       = new Toolbar(opt)
      @propertyPanel = new PropertyPanel(opt)
      @resourcePanel = new ResourcePanel(opt)
      @statusbar     = new Statusbar(opt)
      @canvas        = new CanvasView(opt)

      # 2 Update subviews
      @statusbar.render()
      @renderSubviews()

      @initialize()
      return

    initialize : ()->
      @canvas.switchMode( "stack" )

    saveStack : ()-> @toolbar.$el.find(".icon-save").trigger "click"

    backup : ()->
      $center = @$el.find(".OEPanelCenter")

      ###
      Revoke all the IDs of every dom.
      ###
      @propertyPanel.backup()

      @$el.attr("id", "")
      return

    recover : ()->
      @resourcePanel.recalcAccordion()
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

    getSvgElement : ()->
      @$el.children(".OEMiddleWrap").children(".OEPanelCenter").children(".canvas-view").children("svg")

    saveOps : ()-> App.saveOps( @workspace.opsModel )

    ###
      Override these methods in subclasses.
    ###
    # Called when the OpsEditor initialize
    renderSubviews  : ()-> return
  }
