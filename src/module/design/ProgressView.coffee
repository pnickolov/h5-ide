
# This view is used to show the running status of an ops

define ["./ProgressTpl", "backbone"], ( ProgressTpl )->

  DesignProcessingView = Backbone.View.extend {

    initialize : ( model )->
      @model = model

      @listenTo model, "change:state",    @updateState
      @listenTo model, "change:progress", @updateProgress

      # Every time we open a new editor, we re-create the editor dom holder.
      $("#tab-content-design").remove()
      @setElement $("<div id='tab-content-design'></div>").appendTo("#main")
      @$el.html ProgressTpl( @model.toJSON() )

      return

    updateState : ()->

    updateProgress : ()->

  }
