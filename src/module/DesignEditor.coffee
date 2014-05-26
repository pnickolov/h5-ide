
define ["Workspace"], ( Workspace )->

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
        return

  DesignEditor
