
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

      @setElement $("<div class='ops-process'></div>").appendTo("#main")
      @$el.html OpsProgressTpl( @model.toJSON() )
      return

    updateState : ()->
      switch @model.get("state")
        when OpsModel.State.running
          @$el.children().hide()
          @$el.find("success").show()
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

  }

  # Controller
  class OpsProgress extends OpsEditorBase

    initialize : ()->
      @view = new OpsProgressView({model:@opsModel})

      self = @
      @view.on "close", ()-> self.remove()

      return

  OpsProgress
