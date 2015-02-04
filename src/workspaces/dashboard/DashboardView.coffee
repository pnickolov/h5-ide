
define [ "./DashboardTpl", "./ImportDialog", "backbone" ], ( Template, ImportDialog )->

  Backbone.View.extend {

    events :
      "click .dashboard-header .create-stack"   : "createStack"
      "click .dashboard-header .import-stack"   : "importStack"
      "click .dashboard-header .icon-visualize" : "importApp"
      "click .dashboard-sidebar nav buttton"    : "switchLog"

    initialize : ()->
      @setElement $( Template({
        providers : @model.supportedProviders()
      }) ).appendTo( @model.scene.spaceParentElement() )

      @render()
      return

    render : ()->
      # Update the dashboard in this method.
      @$el.toggleClass "observer", @model.isReadOnly()
      return

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

    switchLog: () ->

        null

  }
