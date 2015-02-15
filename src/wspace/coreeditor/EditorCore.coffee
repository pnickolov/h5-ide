
###
  OpsEditorBase is a base class for all the OpsEditor
###

define [
  "Workspace"
  "CoreEditorView"
  "wspace/coreeditor/TplOpsEditor"
  "ThumbnailUtil"
  "OpsModel"
  "Design"
  "ApiRequest"
  "UI.modalplus"
  "i18n!/nls/lang.js"

  "wspace/coreeditor/EditorDeps"
], ( Workspace, CoreEditorView, OpsEditorTpl, Thumbnail, OpsModel, Design, ApiRequest, Modal, lang )->

  # A view that used to show loading state of editor
  LoadingView = Backbone.View.extend {
    isLoadingView : true
    initialize : ( attr )-> @setElement $(OpsEditorTpl.loading()).appendTo( attr.workspace.scene.spaceParentElement() ).show()[0]
    setText : ( text )-> @$el.find(".processing").text( text )
    showVpcNotExist : ( name, onConfirm )->
      self = @
      modal = new Modal {
        title    : sprintf lang.IDE.TITLE_CONFIRM_TO_REMOVE_APP, name
        template : OpsEditorTpl.modal.confirmRemoveApp()
        confirm  : { text : lang.IDE.POP_CONFIRM_TO_REMOVE, color : "red" }
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
      2. It has a render() method which will create and set its element to #OpsEditor.
      3. It needs to re-bind every events in render()
  ###
  Workspace.extend {

    type : "CoreEditorStack"

    ###
      Override these methods to implement subclasses.
    ###
    title       : ()-> @opsModel.get("name")
    tabClass    : ()-> "icon-stack-tabbar"
    url         : ()-> @opsModel.relativeUrl()
    isWorkingOn : ( data )-> @opsModel is data.opsModel

    viewClass   : CoreEditorView
    designClass : Design

    # Returns a promise that will be fulfilled when all the data is ready.
    # This will be called after the OpsModel's json is fetched.
    fetchData : ()->
      d = Q.defer()
      d.resolve()
      d.promise

    # Return true if the data is ready.
    isReady : ()-> !!@__hasAdditionalData

    getSelectedComponent : ()->
      if not @view.canvas
        return null
      @view.canvas.getSelectedComp()

    onOpsModelStateChanged : ()->
      if @opsModel.testState( OpsModel.State.Destroyed )
        if not @opsModel.isLastActionTriggerByUser()
          notification "info", "The stack has been removed by other team."

        @remove()
      return

    ###
      Internal methods.
    ###
    onModelIdChange : ()->
      @updateUrl()
      if @design then @design.set("id", @opsModel.get("id"))
      return

    constructor : ( attr )->
      if not attr.opsModel
        @remove()
        throw new Error("Cannot find opsmodel while openning workspace.")

      @opsModel = attr.opsModel
      # OpsModel's State
      # OpsModel doesn't trigger "change:state" when a opsModel is set to "destroyed"
      @listenTo @opsModel, "destroy",      @onOpsModelStateChanged
      @listenTo @opsModel, "change:state", @onOpsModelStateChanged
      @listenTo @opsModel, "change:name",  @updateTab
      @listenTo @opsModel, "change:id",    @onModelIdChange

      delete attr.opsModel

      # Load Datas
      s = @
      @opsModel.fetchJsonData().then (()-> s.jsonLoaded()), ((err)-> s.jsonLoadFailed(err))

      Workspace.apply @, arguments

    jsonLoadFailed : ( err )->
      if @isRemoved() then return
      if err.error is ApiRequest.Errors.MissingDataInServer
        # When we got this error, the opsmodel will destroy itself, resulting removal of the editor.
        return

      notification "error", lang.NOTIFY.FAILED_TO_LOAD_DATA
      @remove()

    jsonLoaded : ()->
      if @isRemoved() then return

      self = @
      @fetchData().then (()-> self.dataLoaded()), (()-> self.dataLoadFailed())
      return

    dataLoadFailed : ()->
      if @isRemoved() then return

      notification "error", lang.NOTIFY.FAILED_TO_LOAD_AWS_DATA
      @remove()

    dataLoaded : ()->
      if @isRemoved() then return

      @__hasAdditionalData = true

      if @view and @view.isLoadingView
        @view.remove()
        @view = null

      if @isAwake() and not @__inited
        try
          @__initEditor()
        catch e
          console.error e
          notification "error", "Failed to open the stack/app, please contact our support team."
          @remove()
      return

    awake : ()->
      if not @isReady()
        # If we are in Loading state, ensure we have a LoadingView
        if not @view
          @view = new LoadingView({workspace:@})
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

      # If the OpsModel doesn't exist in server, we would destroy it when the editor is closed.
      if not @opsModel.isPersisted() and not @opsModel.testState( OpsModel.State.Saving )
        @opsModel.remove()
      return

    isInited : ()-> !!@__inited
    __initEditor : ()->
      @__inited = true
      @design = new @designClass( @opsModel )

      @listenTo @design, "change:name", @updateTab

      @view = new @viewClass({ workspace : @ })
      @view.__initialize()

      @initEditor()

      # If the OpsModel doesn't have thumbnail, generate one for it.
      if not @opsModel.getThumbnail()
        @saveThumbnail()

      # Save result of the Design serialization. By doing this, the opsModel will
      # always have a correct json when the editor is opened.
      @opsModel.__setJsonData @design.serialize()
      return

    initEditor : ()->
      if @opsModel.get("autoLayout")
        @view.canvas.autoLayout()
      return

    saveThumbnail : ()->
      if @opsModel.isPersisted()
        Thumbnail.generate( @view.getSvgElement() ).then ( thumbnail )=> @opsModel.saveThumbnail( thumbnail )

    isRemovable : ()->
      if not @__inited or not @isModified() or not @opsModel.isPersisted()
        return true

      @view.showCloseConfirm()
      false

    ###
    # OpsModel related action
    ###
    saveStack : ()->
      newJson = @design.serialize()
      self    = @
      Thumbnail.generate( @view.getSvgElement() ).then ( thumbnail )->
        self.opsModel.save( newJson, thumbnail ).fail ( e )->
          if e.error is ApiRequest.Errors.StackRepeatedStack
            e.msg = lang.NOTIFY.ERR_SAVE_FAILED_NAME
          else if e.error is ApiRequest.Errors.StackConflict
            e.msg = lang.NOTIFY.ERR_SAVE_FAILED_CONFLICT
          else
            e.msg = sprintf(lang.NOTIFY.ERR_SAVE_FAILED, newJson.name)
          throw e
  }, {
    canHandle : ()-> false
  }
