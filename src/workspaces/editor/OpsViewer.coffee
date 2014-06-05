
###
  OpsViewer is a readonly viewer to show the app ( Basically it shows the visualize vpc )
###

define [ "Workspace", "./OpsEditorView", "./TplOpsEditor", "OpsModel", "Design" ], ( Workspace, OpsEditorView, OpsEditorTpl, OpsModel, Design )->

  # A view that used to show loading state of editor
  LoadingView = Backbone.View.extend {
    initialize : ( options )-> @setElement $(OpsEditorTpl.loading()).appendTo("#main").show()[0]
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
  class OpsViewer extends Workspace

    title       : ()-> @opsModel.get("importVpcId") + " - visualization"
    tabClass    : ()-> "icon-visualization-tabbar"
    isWorkingOn : ( attribute )-> @opsModel is attribute

    constructor : ( opsModel )->
      if not opsModel
        @remove()
        throw new Error("Cannot find opsmodel while openning workspace.")

      @opsModel = opsModel
      @listenTo @opsModel, "jsonDataLoaded", @jsonLoaded

      # Load Datas
      self = @
      @opsModel.fetchJsonData().fail ()->
        notifcation "Fail to load data, please retry."
        self.remove()

      return Workspace.apply @, arguments

    ###
      Override these methods to implement subclasses.
    ###
    fetchAdditionalData : ()->
      d = Q.defer()
      d.resolve()
      d.promise

    createView : ()->
      new OpsEditorView({
        opsModel  : @opsModel
        workspace : @
      })


    createDesign : ()->
      design = new Design( @opsModel.getJsonData(), {autoFinish : false})
      MC.canvas.analysis()
      design.finishDeserialization()
      design

    ###
      Internal methods.
    ###
    isReady : ()-> @__isJsonLoaded && @__hasAdditionalData
    jsonLoaded : ()->
      self = @
      @__isJsonLoaded = true

      @fetchAdditionalData().then ()->
        self.__hasAdditionalData = true
        self.switchToReady()
      , ()->
        notifcation "Fail to load aws data, please retry."
        self.remove()

      return

    switchToReady : ()->
      if @view
        @view.remove()
        @view = null

      if @isAwake
        @initEditor()
      else
        @__postponeInit = true
      return

    awake : ()->
      if not @isReady()
        # If we are in Loading state, ensure we have a LoadingView
        if not @view then @view = new LoadingView()
        return

      # Whenever we awake in Ready state, LoadingView should have been removed or never exists.
      # So we don't have to worried about the LoadingView.

      # The Editor is not inited. Do it now.
      if @__postponeInit
        @initEditor()
      else
        @showEditor()
      return

    # Override parent's method to do cleaning when the tab is removed.
    cleanup : ()->
      @__backupSvg = null
      @stopListening()
      if @view
        # OpsEditorView might have an null $el with it.
        # But Backbone.View.remove() assumes the $el is not null
        if not @view.$el then @view.$el = $()

        @view.remove()
      return

    initEditor : ()->
      @view = @createView()
      @showEditor()

      @design = @createDesign()
      return

    showEditor : ()->
      console.assert( @view, "There's no view for the editor when it's being shown." )

      # If there's a #OpsEditor DOM, need to check if it's ours. If it's not, ask another editor to hide it.
      $theDOM  = $("#OpsEditor")
      editorId = $theDOM.attr("data-workspace")

      console.assert( not $theDOM.length or editorId, "There's #OpsEditor, but it doens't have [data-workspace]" )

      if editorId and editorId isnt @id
        App.workspaces.get( editorId ).hideEditor()

      if editorId isnt @id
        @view.render()
        $("#OpsEditor").attr("data-workspace", @id)

        # Restore svg
        if @__backupSvg
          $("#OEPanelCenter").html( @__backupSvg )
          @__backupSvg = null

      else
        # The #OpsEditor DOM is ours, we just need to show it.
        console.log( "#OpsEditor is current workspace's, just show()-ing it." )
        @view.$el.show()

      return

    # This method is intends to be called by other editors, when other editor is activate.
    hideEditor : ()->
      console.assert( $("#OpsEditor").attr("data-workspace") is @id && $("#OpsEditor")[0] is @view.$el[0], "The #OpsEditor DOM is not this editor's", $("#OpsEditor"), @ )

      @__backupSvg = $("#OEPanelCenter").html()
      # Remove the DOM to free memories. But we don't call setElement(), because
      # setElement() will transfer events to the new element.
      @view.$el.remove()
      @view.$el = null
      return

  OpsViewer
