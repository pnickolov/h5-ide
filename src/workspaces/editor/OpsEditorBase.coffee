
###
  OpsViewer is a readonly viewer to show the app ( Basically it shows the visualize vpc )
###

define [ "Workspace", "./OpsEditorModel", "./OpsEditorView", "OpsModel" ], ( Workspace, OpsEditorModel, OpsEditorView, OpsModel )->

  class OpsViewer extends Workspace

    isFixed     : ()-> false
    isWorkingOn : ( attribute )-> @opsModel.cid is attribute
    title : ()->
      if @opsModel.isImported()
        @opsModel.get("importVpcId") + " - visualization"
      else if @opsModel.isApp()
        @opsModel.get("name") + " - app"
      else
        @opsModel.get("name") + " - stack"

    tabClass : ()->
      if @opsModel.isImported()
        "icon-visualization-tabbar"
      else if @opsModel.isApp()
        if @opsModel.testState( OpsModel.State.Running )
          "icon-app-running"
        else
          "icon-app-stopped"
      else
        "icon-stack-tabbar"

    constructor : ( attribute )->
      # Set opsModel
      @opsModel = App.model.stackList().get( attribute )
      if not @opsModel
        @opsModel = App.model.appList().get( attribute )

      if not @opsModel
        @remove()
        throw new Error("Cannot find opsmodel while openning workspace.")

      return Workspace.apply @, arguments

    initialize : ()->
      @__jsonLoaded = false
      @__awsResourceLoaded = true # TODO :

      @model = new OpsEditorModel()

      @view = new OpsEditorView()
      @view.opsModel  = @opsModel
      @view.model     = @model
      @view.workspace = @

      @listenTo @opsModel, "jsonDataLoaded", @jsonLoaded

      @opsModel.getJsonData()
      return

    # Override parent's method to do cleaning.
    cleanup : ()->
      @stopListening()
      @view.remove()
      return

    awake : ()->
      @view.render()
      @view.$el.show()
      return

    sleep : ()-> @view.$el.remove()

    jsonLoaded : ()->
      @__jsonLoaded = true
      @view.setDataLoaded( @__jsonLoaded && @__awsResourceLoaded )
      if @isAwake() then @view.render()

    awsResourceLoaded : ()->
      @__awsResourceLoaded = true
      @view.setDataLoaded( @__jsonLoaded && @__awsResourceLoaded )
      if @isAwake() then @view.render()

  OpsViewer
