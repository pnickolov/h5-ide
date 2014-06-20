
# This view is used to show the running status of an ops

define [
  "OpsModel"
  "Workspace"
  "./template/TplProgress"
  "backbone"
], ( OpsModel, Workspace, OpsProgressTpl )->


  # View
  OpsProgressView = Backbone.View.extend {

    events :
      "click .btn-close-process" : "close"

    initialize : ()->
      # OpsModel doesn't trigger "change:state" when a opsModel is set to "destroyed"
      @listenTo @model, "destroy",         @updateState
      @listenTo @model, "change:state",    @updateState
      @listenTo @model, "change:progress", @updateProgress

      data = {
        progress : @model.get("progress")
      }

      if not @model.testState( OpsModel.State.Initializing )
        data.title = @model.getStateDesc() + " your app..."

      @setElement $(OpsProgressTpl( data )).appendTo("#main")

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
          @$el.children().hide()
          @$el.find(".fail").show()
          @$el.find(".detail").text @model.get("opsActionError")
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
  class OpsProgress extends Workspace

    isWorkingOn : ( attribute )-> @opsModel is attribute
    tabClass    : ()-> "icon-app-pending"
    title       : ()-> @opsModel.get("name") + " - app"
    constructor : ( opsModel )->
      if not opsModel
        @remove()
        throw new Error("Cannot find opsmodel while openning workspace.")

      @opsModel = opsModel
      return Workspace.apply @, arguments

    initialize : ()->
      @view = new OpsProgressView({model:@opsModel})
      @view.workspace = @

      self = @
      @view.on "close", ()-> self.remove()
      @view.on "done", ()->
        index = self.index()
        self.remove()
        ws = App.openOps( self.opsModel )
        ws.setIndex index
        return

      return

    awake : ()-> @view.awake()
    sleep : ()-> @view.sleep()

  OpsProgress
