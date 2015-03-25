
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

      @setElement $(ProgressTpl.frame( data )).appendTo( attr.workspace.scene.spaceParentElement() )
      return

    switchToDone : ()->
      @$el.find(".success").show()
      @$el.find(".process-detail").hide()
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

        when OpsModel.State.RollingBack
          @$el.toggleClass("rolling-back", true)

        when OpsModel.State.Destroyed
          # If the app runs successfully and get destroyed, we just close the tab
          if @done
            @close()
            return

          @$el.children().hide()
          @$el.find(".fail").show()
          @$el.find(".process-detail").show()
          @$el.find(".detail").html @model.get("opsActionError").replace(/\n/g, "<br/>")
        else
          console.error "The model has changed to a state that OpsProgress doesn't recongnize", @model

      return

    updateProgress : ()->
      @$el.toggleClass("has-progess", true)
      pro = "#{@model.get("progress")}%"

      @$el.find(".process-info").text( pro )
      @$el.find(".bar").css { width : pro }

      @updateDetail()
      return

    updateDetail : ()->
      notification = App.model.notifications().get( @model.id )
      if not notification
        self = @
        App.model.notifications().once "add", ()-> self.updateDetail()
        return

      rawRequest = notification.raw()

      $detail = @$el.children(".process-detail")
      if $detail.length is 0
        $detail = $( ProgressTpl.detailFrame(rawRequest.step || []) ).appendTo @$el

      $children = $detail.children("ul").children()

      if rawRequest.state is "Rollback"
        classMap =
          done    : "pdr-3 done icon-success"
          running : "pdr-3 rolling icon-pending"
          pending : "pdr-3 rolledback icon-warning"
      else
        classMap =
          done     : "pdr-3 done icon-success"
          running  : "pdr-3 running icon-pending"
          pending  : "pdr-3 pending"


      for step, idx in rawRequest.step
        if step.length < 5 then continue

        text  = step[2] + " " + step[4]
        if step[3]
          text += " (#{step[3]})"
        $children.eq(idx).children(".pdr-2").text( text )
        $children.eq(idx).children(".pdr-3").attr("class", classMap[step[1]])

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

    isWorkingOn : ( data )-> @opsModel() is data.opsModel
    tabClass    : ()-> "icon-app-pending"
    title       : ()-> @opsModel().get("name") + " - app"
    url         : ()-> @opsModel().relativeUrl()

    constructor : ( attr )->
      if not attr.opsModel
        throw new Error("Cannot find opsmodel while openning workspace.")

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
      if data.opsModel.testState( OpsModel.State.Saving ) or data.opsModel.testState( OpsModel.State.Terminating ) or data.opsModel.testState( OpsModel.State.Removing )
        console.warn "Avoide opening a saving/terminating/removing OpsModel."
        return false

      return data.opsModel.isApp() and data.opsModel.isProcessing()
  }
