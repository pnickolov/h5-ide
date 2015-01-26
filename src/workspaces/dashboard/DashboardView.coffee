
define [ "./DashboardTpl", "backbone" ], ( Template )->

  Backbone.View.extend {

    initialize : ()->
      @setElement $( Template({
        providers : @model.supportedProviders()
      }) ).appendTo( @model.scene.spaceParentElement() )
      return

    render : ()->

  }
