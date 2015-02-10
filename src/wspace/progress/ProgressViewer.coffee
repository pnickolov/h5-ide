
# This view is used to show the running status of an ops

define [
  "OpsModel"
  "Workspace"
  "./PVTpl"
], ( OpsModel, Workspace, ProgressTpl )->

  # View
  OpsProgressView = Backbone.View.extend {

    events :
      "click .btn-close-process" : "close"

    initialize : ( attr )->
      # OpsModel doesn't trigger "change:state" when a opsModel is set to "destroyed"
      @listenTo @model, "destroy",         @updateState
      @listenTo @model, "change:state",    @updateState
      @listenTo @model, "change:progress", @updateProgress

      data = {
        progress : @model.get("progress")
      }

      if not @model.testState( OpsModel.State.Initializing )
        data.title = @model.getStateDesc() + " your app..."

      @setElement $(ProgressTpl( data )).appendTo( attr.workspace.scene.spaceParentElement() )

      @__progress = 0
      return

    switchToDone : ()->
      @$el.find(".success").show()
      self = @
      setTimeout ()->
        self.$el.find(".processing-wrap").addClass("fadeout")
        self.$el.find(".success").addClass("fadein")
        return
      , 10
      setTimeout ()->
        self.trigger "done"
      , 2000
      return

    updateState : ()->
      switch @model.get("state")
        when OpsModel.State.Running, OpsModel.State.Stopped
          if @__awake
            @switchToDone()
          else
            @done = true

        when OpsModel.State.Destroyed
          # If the app runs successfully and get destroyed, we just close the tab
          if @done
            @close()
            return

          @$el.children().hide()
          @$el.find(".fail").show()
          @$el.find(".detail").html @model.get("opsActionError").replace(/\n/g, "<br/>")
        else
          console.error "The model has changed to a state that OpsProgress doesn't recongnize", @model

      return

    updateProgress : ()->
      pp = @model.get("progress")

      @$el.toggleClass("has-progess", true)

      if @__progress > pp
        @$el.toggleClass("rolling-back", true)
      @__progress = pp

      pro = "#{pp}%"

      @$el.find(".process-info").text( pro )
      @$el.find(".bar").css { width : pro }
      return

    close : ()-> @trigger "close"

    awake : ()->
      @$el.show()
      @__awake = true
      if @done
        @done = false
        @switchToDone()
      return

    sleep : ()->
      @$el.hide()
      @__awake = false
      return

  }

  # Controller
  Workspace.extend {

    type : "ProgressViewer"

    isWorkingOn : ( data )-> @opsModel is data.opsModel
    tabClass    : ()-> "icon-app-pending"
    title       : ()-> @opsModel().get("name") + " - app"
    url         : ()-> @opsModel().relativeUrl()

    constructor : ( attr )->
      if not attr.opsModel
        throw new Error("Cannot find opsmodel while openning workspace.")
        return

      if attr.opsModel.testState( OpsModel.State.Saving ) or attr.opsModel.testState( OpsModel.State.Terminating )
        console.warn "Avoiding opening a saving/terminating OpsModel."
        return

      Workspace.apply @, arguments
      return

    initialize : ()->
      @view = new OpsProgressView({
        model     : @opsModel()
        workspace : @
      })

      @listenTo @opsModel(), "change:id", ()-> @updateUrl(); return

      self = @
      @view.on "close", ()-> self.remove()
      @view.on "done", ()->
        self.remove()
        App.loadUrl( self.opsModel().url() )
        return

      return

    opsModel : ()-> @get("opsModel")

    awake : ()-> @view.awake()
    sleep : ()-> @view.sleep()

  }, {
    canHandle : ( data )->
      if not data.opsModel then return false
      return data.opsModel.isApp() and data.opsModel.isProcessing()
  }
