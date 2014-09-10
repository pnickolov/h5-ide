
define [
  "workspaces/coreeditor/TplOpsEditor"
  "UI.modalplus"
  "event"

  "backbone"
  "UI.selectbox"
], ( OpsEditorTpl, Modal, ide_event )->

  ### Monitor keypress ###
  $(window).on 'keydown', ( evt )->
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

      @setElement $( OpsEditorTpl.frame() ).appendTo("#main").attr("data-ws", @workspace.id).show()[0]

      opt =
        workspace : @workspace
        parent    : @

      @toolbar       = new (options.TopPanel    || Backbone.View)(opt)
      @propertyPanel = new (options.RightPanel  || Backbone.View)(opt)
      @resourcePanel = new (options.LeftPanel   || Backbone.View)(opt)
      @statusbar     = new (options.BottomPanel || Backbone.View)(opt)
      @canvas        = new options.CanvasView(opt)

      @listenTo @canvas, "itemSelected", @onItemSelected

      @initialize()
      return

    showProperty   : ()->
    onItemSelected : ( type, id )->

    toggleLeftPanel  : ()->
      @resourcePanel.toggleLeftPanel()
      @canvas.updateSize()
      false

    toggleRightPanel : ()->
      @propertyPanel.toggleRightPanel()
      @canvas.updateSize()
      false

    saveStack : ()-> @toolbar.$el.find(".icon-save").trigger "click"

    moveSelectedItem : (evt, which)->
      switch which
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
      ###
      Revoke all the IDs of every dom.
      ###
      if @propertyPanel and @propertyPanel.backbone
        @propertyPanel.backup()

      @$el.attr("id", "")
      return

    recover : ()->
      @$el.show().attr("id", "OpsEditor")
      @resourcePanel.recalcAccordion()

      @propertyPanel.recover()
      return

    remove : ()->
      @toolbar.remove()
      @propertyPanel.remove()
      @resourcePanel.remove()
      @statusbar.remove()
      @canvas.remove()

      Backbone.View.prototype.remove.call this

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

    showStateEditor : ()->
      com = @workspace.getSelectedComponent()
      if com
        ide_event.trigger ide_event.SHOW_STATE_EDITOR, com.id
      return

    getSvgElement : ()->
      children = @$el.children(".OEMiddleWrap").children(".OEPanelCenter").children()
      while children.length
        child = children.filter("svg")
        if child.length then return child
        children = children.children()

      return null
  }
