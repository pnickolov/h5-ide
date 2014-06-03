
###
  OpsEditorBase is the base class of a concrete OpsEditor
###

define [ "Workspace" ], ( Workspace )->

  class OpsEditorBase extends Workspace

    isFixed     : ()-> false
    isWorkingOn : ( attribute )-> @opsModel.cid is attribute
    title       : ()-> @name or @opsModel.get("name")

    tabClass    : ()-> "icon-stack-tabbar" # TODO

    constructor : ( attribute )->
      # Set opsModel
      @opsModel = App.model.stackList().get( attribute )
      if not @opsModel
        @opsModel = App.model.appList().get( attribute )

      if not @opsModel
        @remove()
        throw new Error("Cannot find opsmodel while openning workspace.")

      return Workspace.apply @, arguments

    awake : ()->
      @view.render()
      @view.$el.show()
      return

    sleep : ()-> @view.$el.remove()

  OpsEditorBase
