
define [ "./DashboardTpl", "./ImportDialog", "backbone", "./OldDashboardView", "./OldDashboardModel" ], ( Template, ImportDialog, Backbone, OldDashboardView, OldDashboardModel )->

  Backbone.View.extend {

    events :
      "click .dashboard-header .create-stack"   : "createStack"
      "click .dashboard-header .import-stack"   : "importStack"
      "click .dashboard-header .icon-visualize" : "importApp"

    initialize : ()->
      @setElement $( Template({
        providers : @model.supportedProviders()
      }) ).appendTo( @model.scene.spaceParentElement() )
      #Todo : Will Remove Old Dashboard Later.
      oldView = new OldDashboardView({model: @model})
      console.log oldView
      return

    render : ()->
      # Update the dashboard in this method.

    createStack : ( evt )->
      $tgt = $( evt.currentTarget )
      provider = $tgt.closest("ul").attr("data-provider")
      region   = $tgt.attr("data-region")

      opsModel = @model.scene.project.createStack( region, provider )

      @model.scene.loadSpace( opsModel )
      return

    importStack : ( evt )->
      new ImportDialog({
        type    : $(evt.currentTarget).attr("data-type")
        project : @model.scene.project
      })
      false

    importApp : ()->

  }
