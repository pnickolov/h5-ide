
define [
  "./OsEditorStack"
  "./OsViewStack"
  "./model/DesignOs"
  "CloudResources"
  "constant"
], ( StackEditor, StackView, DesignOs, CloudResources, constant )->

  class AppEditor extends StackEditor

    title : ()-> (@design || @opsModel).get("name") + " - app"

    isModified : ()-> @design and @design.modeIsAppEdit() and @design.isModified()

  AppEditor
