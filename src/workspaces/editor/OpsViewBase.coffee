
define [
  "./template/TplCanvas"
  "./template/TplOpsEditor"
  "./subviews/PropertyPanel"
  "./subviews/Toolbar"
  "UI.modalplus"

  "backbone"
  "UI.selectbox"
  "MC.canvas"
], ( CanvasTpl, OpsEditorTpl, PropertyPanel, Toolbar, Modal )->

  # LEGACY code
  # Should remove this in the future.
  $(document).on('keydown', MC.canvas.event.keyEvent)
  $('#header, #navigation, #tab-bar').on('click', MC.canvas.volume.close)
  $(document.body).on('mousedown', '#instance_volume_list a', MC.canvas.volume.mousedown)


  ### OpsEditorView base class ###
  Backbone.View.extend {

    constructor : ( options )->
      _.extend this, options

      @propertyPanel = new PropertyPanel()
      @propertyPanel.workspace = @workspace

      @toolbar = new Toolbar()
      @toolbar.workspace = @workspace

      @initialize()
      return

    render : ()->
      console.assert( not @$el or @$el.attr("id") isnt "OpsEditor", "There should be no #OpsEditor when an editor view is rendered." )

      # 1. Generate basic dom structure.
      if @$el then @$el.remove()
      @setElement $( @createTpl() ).appendTo("#main").show()[0]

      # 2. Bind Events for MC.canvas.js
      @bindUserEvent()

      # 3 Update subviews
      @toolbar.render()
      @propertyPanel.render()

      @renderSubviews()

      # 4. Hack, ask the canvas to init the canvas.
      # Should decouple the canvas from design.
      @workspace.design.canvas.init()
      return

    clearDom : ()->
      # Remove the DOM to free memories. But we don't call setElement(), because
      # setElement() will transfer events to the new element.
      @$el.remove()
      @$el = null

      @propertyPanel.clearDom()
      @toolbar.clearDom()

      @clearSubviewsDom()
      return

    remove : ()->
      # Hack, the toolbar/propertyPanel's $el might be null here.
      @toolbar.$el = @toolbar.$el || $()
      @propertyPanel.$el = @propertyPanel.$el || $()

      @toolbar.remove()
      @propertyPanel.remove()

      @removeSubviews()

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

    ###
      Override these methods in subclasses.
    ###
    createTpl        : ()-> CanvasTpl({})
    bindUserEvent    : ()-> return
    # Called when the OpsEditor awakes up.
    renderSubviews   : ()-> return
    # Called when the OpsEditor is put to sleep
    clearSubviewsDom : ()-> return
    # Called when the OpsEditor is closed.
    removeSubviews   : ()-> return
  }
