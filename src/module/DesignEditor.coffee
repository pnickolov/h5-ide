
define [ "Workspace", "./design/ProgressView" ], ( Workspace, ProgressView )->

  class DesignEditor extends Workspace

    isFixed  : ()-> false
    tabClass : ()-> "icon-stack-tabbar"
    title    : ()-> @name or @opsModel.get("name")

    initialize : ( attribute )->
      @opsModel = App.model.stackList().get( attribute )
      if not @opsModel
        @opsModel = App.model.appList().get( attribute )

      if not @opsModel
        @remove()
        throw new Error("Cannot find opsmodel while openning workspace.")

      @createProperView()
      return

    createProperView : ()->
      @opsModel.attributes.state = 3
      @opsModel.attributes.progress = 20

      if @opsModel.isProcessing()
        @view = new ProgressView( @opsModel )

      return

  DesignEditor
