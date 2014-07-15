
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
    if $(evt.target).is("input, textarea") or evt.target.contentEditable is "true"
      evt.stopPropagation()
      return

    $tgt = $("#OpsEditor")
    if not $tgt.length then return

    switch evt.keyCode
      when 8 , 46
        ### BackSpace & Delete ###
        if evt.which is 8
          evt.preventDefault()
        if not evt.ctrlKey and not evt.metaKey
          type = "DelSelectItem"

      # when 9
      #   ### Tab ###
      #   if evt.originalEvent.shiftKey
      #     type = "SelectPrevItem"
      #   else
      #     type = "SelectNextItem"

      when 37, 38, 39, 40
        ### Arrows ###
        type = "MoveSelectItem"

      when 83
        ### S ###
        if evt.ctrlKey || evt.metaKey
          type = "Save"
        else
          type = "ShowStateEditor"

      when 80
        ### P ###
        type = "ShowProperty"

      when 187
        ### + ###
        type = "ZoomIn"

      when 189
        ### - ###
        type = "ZoomOut"

      when 13
        ### Enter ###
        type = "ShowStateEditor"


    if type
      $tgt.triggerHandler type, evt.which
      return false

    return

  ### OpsEditorView base class ###
  Backbone.View.extend {

    events :
      "Save"            : "saveStack"
      "DelSelectItem"   : "delSelectedItem"
      "SelectPrevItem"  : "selectPrevItem"
      "SelectNextItem"  : "selectNextItem"
      "MoveSelectItem"  : "moveSelectedItem"
      "ZoomIn"          : "zoomIn"
      "ZoomOut"         : "zoomOut"
      "ShowProperty"    : "showProperty"
      "ShowStateEditor" : "showStateEditor"

      "click .HideOEPanelLeft"  : "toggleLeftPanel"
      "click .HideOEPanelRight" : "toggleRightPanel"

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

    toggleLeftPanel  : ()->
      @resourcePanel.toggleLeftPanel()
      @canvas.updateSize()
      false

    toggleRightPanel : ()->
      @propertyPanel.toggleRightPanel()
      @canvas.updateSize()
      false

    initialize : ()->
      @canvas.switchMode( "stack" )

    saveStack : ()-> @toolbar.$el.find(".icon-save").trigger "click"

    moveSelectedItem : (evt, which)->
      switch keycode
        when 37 then x = -1
        when 38 then y = -1
        when 39 then x = 1
        when 40 then y = 1
      @canvas.moveSelectedItem( x || 0, y || 0 )
      false

    delSelectedItem : ()-> @canvas.delSelectedItem(); false
    selectPrevItem  : ()-> @canvas.selectPrevItem(); false
    selectNextItem  : ()-> @canvas.selectNextItem(); false
    zoomIn          : ()-> @canvas.zoomIn();  @toolbar.updateZoomButtons(); false
    zoomOut         : ()-> @canvas.zoomOut(); @toolbar.updateZoomButtons(); false

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

    ###
      Override these methods in subclasses.
    ###
    # Called when the OpsEditor initialize
    renderSubviews  : ()-> return
  }
