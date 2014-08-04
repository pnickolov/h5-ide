
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
        confirm  : { text : "Confirm to Remove", color : "red" }
        disableClose : true
        onConfirm    : ()->
          onConfirm()
          modal.close()
      }
      return
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
    title       : ()-> @opsModel.get("name")
    tabClass    : ()-> "icon-stack-tabbar"
    url         : ()-> @opsModel.url()
    isWorkingOn : ( att )-> @opsModel is att

    viewClass : OpsEditorView

    # Returns a promise that will be fulfilled when all the data is ready.
    # This will be called after the OpsModel's json is fetched.
    fetchAdditionalData : ()->
      d = Q.defer()
      d.resolve()
      d.promise

    # Return true if the data is ready.
    isReady : ()-> !!@__hasAdditionalData

    getSelectedComponent : ()->
      if not @view.canvas
        return null
      @view.canvas.getSelectedComp()

    onOpsModelStateChanged : ()-> if @opsModel.get("state") is OpsModel.State.Destroyed then @remove()

    ###
      Internal methods.
    ###
    onModelIdChange : ()->
      @updateUrl()
      if @design then @design.set("id", @opsModel.get("id"))
      return

    constructor : ( opsModel )->
      if not opsModel
        @remove()
        throw new Error("Cannot find opsmodel while openning workspace.")

      @opsModel = opsModel
      # OpsModel's State
      # OpsModel doesn't trigger "change:state" when a opsModel is set to "destroyed"
      @listenTo @opsModel, "destroy",      @onOpsModelStateChanged
      @listenTo @opsModel, "change:state", @onOpsModelStateChanged
      @listenTo @opsModel, "change:name",  @updateTab
      @listenTo @opsModel, "change:id",    @onModelIdChange

      # Load Datas
      s = @
      @opsModel.fetchJsonData().then (()-> s.jsonLoaded()), ((err)-> s.jsonLoadFailed())

      Workspace.apply @, arguments

    jsonLoadFailed : ( err )->
      if @isRemoved() then return
      if err.error is ApiRequest.Errors.MissingDataInServer
        # When we got this error, the opsmodel will destroy itself, resulting removal of the editor.
        return

      notification "error", "Failed to load data, please retry."
      @remove()

    jsonLoaded : ()->
      if @isRemoved() then return

      self = @
      @fetchAdditionalData().then (()-> self.additionalDataLoaded()), (()-> self.additionalDataLoadFailed())
      return

    additionalDataLoadFailed : ()->
      if @isRemoved() then return

      notification "error", "Failed to load aws data, please retry."
      @remove()

    additionalDataLoaded : ()->
      if @isRemoved() then return

      @__hasAdditionalData = true

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
        @view.recover()
      return

    sleep : ()->
      if @view and @view.backup then @view.backup()
      Workspace.prototype.sleep.call this

    # Override parent's method to do cleaning when the tab is removed.
    cleanup : ()->
      @stopListening()
      if @view
        @view.remove()

      if @design
        @design.unuse()
        @design = null
      return

    isInited : ()-> !!@__inited
    __initEditor : ()->
      @__inited = true
      @design = new Design( @opsModel )

      @listenTo @design, "change:name", @updateTab

      @view = new @viewClass({ workspace : @ })

      @initEditor()

      # If the OpsModel doesn't have thumbnail, generate one for it.
      if not @opsModel.getThumbnail()
        @saveThumbnail()

      # Save result of the Design serialization. By doing this, the opsModel will
      # always have a correct json when the editor is opened.
      @opsModel.__setJsonData @design.serialize()
      return

    initEditor : ()->

    saveThumbnail : ()->
      if @opsModel.isPersisted()
        Thumbnail.generate( @view.getSvgElement() ).then ( thumbnail )=> @opsModel.saveThumbnail( thumbnail )

    isRemovable : ()->
      if not @__inited or not @isModified()
        return true

      @view.showCloseConfirm()
      false

  OpsEditorBase
