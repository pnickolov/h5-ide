
define [
  "OpsEditor" # Dependency

  "./oseditor/OsEditorStack"

], ( OpsEditor, StackEditor )->

  # OpsEditor defination
  OsEditor = ( opsModel )->
    if opsModel.isStack()
      return new StackEditor opsModel

  OpsEditor.registerEditors OsEditor, ( model )-> model.type is "OpenstackOps"

  OsEditor
