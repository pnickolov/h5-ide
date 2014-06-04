
###
  OpsViewer is a readonly viewer to show the app ( Basically it shows the visualize vpc )
###

define [ "./OpsEditorBase", "./OpsEditorModel", "./OpsEditorView", "OpsModel", "Design" ], ( OpsEditorBase, OpsEditorModel, OpsEditorView, OpsModel, Design )->

  class OpsViewer extends OpsEditorBase

    title    : ()-> @opsModel.get("importVpcId") + " - visualization"
    tabClass : ()-> "icon-visualization-tabbar"

    initialize : ()->
      @model = new OpsEditorModel()

      @view = new OpsEditorView()
      @view.opsModel  = @opsModel
      @view.model     = @model
      @view.workspace = @

      @listenTo @opsModel, "jsonDataLoaded", @jsonLoaded

      @opsModel.fetchJsonData()
      return

    # Override parent's method to do cleaning.
    cleanup : ()->
      @stopListening()
      @view.remove()
      return

    awake : ()->
      if @__postponeInitEditor
        # The data is ready but we didn't create design yet.
        @__postponeInitEditor = false
        @initEditor()
        return

      @view.render()
      # Restore the svg
      return

    sleep : ()->
      # Bacup the svg.

      @view.$el.remove()
      @view.$el = null
      return

    isDataReady : ()-> @__isJsonLoaded
    jsonLoaded  : ()->
      @__isJsonLoaded = true
      if @isAwake()
        @initEditor()
      else
        @__postponeInitEditor = true
        return

    initEditor : ()->
      # When we get the json data, we create a Design Object to render to the canvs
      @view.render()
      @design = new Design( @opsModel.getJsonData(), {autoFinish : false})
      MC.canvas.analysis()
      @design.finishDeserialization()
      return

  OpsViewer
