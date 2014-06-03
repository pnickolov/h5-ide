
# This view is used to show the running status of an ops

define ["OpsModel", "./OpsEditorBase", "./OpsProgressTpl", "backbone"], ( OpsModel, OpsEditorBase, OpsProgressTpl )->


  # View
  OpsProgressView = Backbone.View.extend {

    events :
      "click .btn-close-process" : "close"

    initialize : ()->
      # OpsModel doesn't trigger "change:state" when a opsModel is set to "destroyed"
      @listenTo @model, "destroy",         @updateState
      @listenTo @model, "change:state",    @updateState
      @listenTo @model, "change:progress", @updateProgress

      @setElement $(OpsProgressTpl( @model.toJSON() )).appendTo("#main")
      return

    switchToDone : ()->
      @$el.find(".success").show()
      self = @
      setTimeout ()->
        self.$el.find(".processing").addClass("fadeout")
        self.$el.find(".success").addClass("fadein")
        return
      , 10
      setTimeout ()->
        self.trigger "done"
      , 2000
      return

    updateState : ()->
      switch @model.get("state")
        when OpsModel.State.Running
          if @isAwake
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
      p = @model.get("progress") + "%"
      @$el.find(".process-info").text p
      @$el.find(".bar").css({width:p})
      return

    close : ()-> @trigger "close"

    awake : ()->
      @$el.show()
      @isAwake = true
      if @done
        @done = false
        @switchToDone()
      return

    sleep : ()->
      @$el.hide()
      @isAwake = false
      return

  }

  # Controller
  class OpsProgress extends OpsEditorBase

    initialize : ()->
      @view = new OpsProgressView({model:@opsModel})

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
