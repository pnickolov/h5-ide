
define [
  "OpsModel"
  "./template/TplCanvas"
  "./subviews/PropertyPanel"
  "./subviews/Toolbar"

  "backbone"
  "UI.selectbox"
  "MC.canvas"
], ( OpsModel, CanvasTpl, PropertyPanel, Toolbar )->

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
      return

    clearDom : ()->
      # Remove the DOM to free memories. But we don't call setElement(), because
      # setElement() will transfer events to the new element.
      @$el.remove()
      @$el = null

      @propertyPanel.clearDom()
      @toolbar.clearDom()

      @clearSubviewDom()
      return

    ###
      Override these methods in subclasses.
    ###
    createTpl        : ()-> CanvasTpl({})
    bindUserEvent    : ()-> return
    renderSubviews   : ()-> return
    clearSubviewsDom : ()-> return
  }
