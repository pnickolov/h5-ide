
###
  OpsEditorBase is a base class for all the OpsEditor
###

define [
  "Workspace"
  "./OpsViewBase"
  "./template/TplOpsEditor"
  "ThumbnailUtil"
  "OpsModel"
  "Design"
  "ApiRequest"
  "UI.modalplus"
], ( Workspace, OpsEditorView, OpsEditorTpl, Thumbnail, OpsModel, Design, ApiRequest, Modal )->

  # A view that used to show loading state of editor
  LoadingView = Backbone.View.extend {
    isLoadingView : true
    initialize : ( options )-> @setElement $(OpsEditorTpl.loading()).appendTo("#main").show()[0]
    setText : ( text )-> @$el.find(".processing").text( text )
    showVpcNotExist : ( name, onConfirm )->
      self = @
      modal = new Modal {
        title    : "Confirm to remove the app #{name}?"
        template : OpsEditorTpl.modal.confirmRemoveApp()
        confirm  : { text : "Confirm", color : "red" }
        disableClose : true
        onConfirm    : ()->
          onConfirm()
          modal.close()
      }
  }

  ###
    An OpsEditor has two state : Loading / Ready.
    When the OpsEditor is created, it enters Loading state. Once all the necessary data is fetched,
    It enters Ready state.

    Every OpsEditor's View should enforce these rules:
      1. Its element must be #OpsEditor
      2. Its have a render() method which will create and set its element to #OpsEditor.
      3. It needs to re-bind every events in render()
  ###
  class OpsEditorBase extends Workspace

    ###
      Override these methods to implement subclasses.
    ###
    title    : ()-> @opsModel.get("name")
    tabClass : ()-> "icon-stack-tabbar"

    # Returns a promise that will be fulfilled when all the data is ready.
    # This will be called after the OpsModel's json is fetched.
    fetchAdditionalData : ()->
      d = Q.defer()
      d.resolve()
      d.promise

    # Returns a new View
    createView : ()-> new OpsEditorView({workspace:this})
    # Returns a new Design object.
    initDesign : ()-> @design.finishDeserialization()
    # Return true if the data is ready.
    isReady : ()-> !!@__hasAdditionalData

    onOpsModelStateChanged : ()->
      switch @opsModel.get("state")
        when OpsModel.State.Destroyed
          @remove()
          return

    ###
      Internal methods.
    ###
    isWorkingOn : ( attribute )-> @opsModel is attribute
    constructor : ( opsModel )->
      if not opsModel
        @remove()
        throw new Error("Cannot find opsmodel while openning workspace.")

      @opsModel = opsModel
      # OpsModel's State
      # OpsModel doesn't trigger "change:state" when a opsModel is set to "destroyed"
      @listenTo @opsModel, "destroy",      @onOpsModelStateChanged
      @listenTo @opsModel, "change:state", @onOpsModelStateChanged
      @listenTo @opsModel, "change:id",    ()-> if @design then @design.set("id", @opsModel.get("id"))

      # Load Datas
      self = @
      @opsModel.fetchJsonData().then ()->
        self.jsonLoaded()
      , ( err )->
        if err.error is ApiRequest.Errors.MissingDataInServer
          # When we got this error, the opsmodel will destroy itself, resulting removal of the editor.
          return

        notification "error", "Failed to load data, please retry."
        self.remove()

      return Workspace.apply @, arguments

    jsonLoaded : ()->
      if @isRemoved() then return

      self = @
      @fetchAdditionalData().then ()->

        if self.isRemoved() then return

        self.__hasAdditionalData = true
        self.switchToReady()
      , ()->
        notification "error", "Failed to load aws data, please retry."
        self.remove()

      return

    switchToReady : ()->
      if @view and @view.isLoadingView
        @view.remove()
        @view = null

      if @isAwake() and not @__inited
        @__initEditor()

      return

    awake : ()->
      if not @isReady()
        # If we are in Loading state, ensure we have a LoadingView
        if not @view
          @view = new LoadingView()
        else
          @view.$el.show()
        return

      # Whenever we awake in Ready state, LoadingView should have been removed or never exists.
      # So we don't have to worried about the LoadingView.

      # The Editor is not inited. Do it now.
      if not @__inited
        @__initEditor()
      else
        @design.use()
        @showEditor()
      return

    # Override parent's method to do cleaning when the tab is removed.
    cleanup : ()->
      @stopListening()
      @view.remove()
      return

    isInited : ()-> !!@__inited
    __initEditor : ()->
      @__inited = true
      @design = new Design( @opsModel )

      @listenTo @design, "change:name", @updateTab

      @view = @createView()
      @view.opsModel  = @opsModel
      @view.workspace = @
      @hideOtherEditor()
      @view.render()

      @initDesign()

      @initEditor()

      # If the OpsModel doesn't have thumbnail, generate one for it.
      if @opsModel.isPresisted() and not @opsModel.getThumbnail()
        @saveThumbnail()
      return

    initEditor : ()->

    saveThumbnail : ()->
      Thumbnail.generate( $("#svg_canvas") ).then ( thumbnail )=> @opsModel.saveThumbnail( thumbnail )

    showEditor : ()->
      if @hideOtherEditor()
        @view.$el.show()
        @view.recover()
      else
        # The #OpsEditor DOM is ours, we just need to show it.
        console.log( "#OpsEditor is current workspace's, just show()-ing it." )
        @view.$el.show()
      return

    hideOtherEditor : ()->
      # If there's a #OpsEditor DOM, need to check if it's ours. If it's not, ask another editor to hide it.
      $theDOM  = $("#OpsEditor")
      editorId = $theDOM.attr("data-workspace")

      console.assert( not $theDOM.length or editorId, "There's #OpsEditor, but it doens't have [data-workspace]" )

      if editorId and editorId isnt @id
        App.workspaces.get( editorId ).view.backup()
        return true

      editorId isnt @id

    isRemovable : ()->
      if not @__inited or not @isModified()
        return true

      @view.showCloseConfirm()
      false

  OpsEditorBase
