
define [
  "OpsEditor" # Dependency

  "./oseditor/OsEditorStack"

  # Extra Includes
  "./oseditor/model/OsModelElb"
  "./oseditor/model/OsModelFloatIp"
  "./oseditor/model/OsModelHealthMonitor"
  "./oseditor/model/OsModelListener"
  "./oseditor/model/OsModelNetwork"
  "./oseditor/model/OsModelPool"
  "./oseditor/model/OsModelPort"
  "./oseditor/model/OsModelRt"
  "./oseditor/model/OsModelServer"
  "./oseditor/model/OsModelSg"
  "./oseditor/model/OsModelSubnet"
  "./oseditor/model/OsModelVolume"

], ( OpsEditor, StackEditor )->

  # OpsEditor defination
  OsEditor = ( opsModel )->
    if opsModel.isStack()
      return new StackEditor opsModel

  OpsEditor.registerEditors OsEditor, ( model )-> model.type is "OpenstackOps"

  OsEditor
