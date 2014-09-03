
define [
  "OpsEditor" # Dependency

  "./oseditor/OsEditorStack"

  # Extra Includes
  "./model/OsModelElb"
  "./model/OsModelFloatIp"
  "./model/OsModelHealthMonitor"
  "./model/OsModelListener"
  "./model/OsModelNetwork"
  "./model/OsModelPool"
  "./model/OsModelPort"
  "./model/OsModelPt"
  "./model/OsModelServer"
  "./model/OsModelSg"
  "./model/OsModelSubnet"
  "./model/OsModelVolume"

], ( OpsEditor, StackEditor )->

  # OpsEditor defination
  OsEditor = ( opsModel )->
    if opsModel.isStack()
      return new StackEditor opsModel

  OpsEditor.registerEditors OsEditor, ( model )-> model.type is "OpenstackOps"

  OsEditor
