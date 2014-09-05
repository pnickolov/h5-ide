
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
  "./oseditor/model/OsModelExtNetwork"

  "./oseditor/model/connection/OsPortUsage"
  "./oseditor/model/connection/OsSgAsso"
  "./oseditor/model/connection/OsRouterAsso"
  "./oseditor/model/connection/OsMonitorUsage"
  "./oseditor/model/connection/OsListenerAsso"

  "./oseditor/model/deserializeVisitor/ExternalNetwork"

  "./oseditor/canvas/CeNetwork"
  "./oseditor/canvas/CeSubnet"
  "./oseditor/canvas/CeRt"
  "./oseditor/canvas/CePool"
  "./oseditor/canvas/CeListener"
  "./oseditor/canvas/CeExtNetwork"
  "./oseditor/canvas/CeServer"
  "./oseditor/canvas/CePort"

], ( OpsEditor, StackEditor )->

  # OpsEditor defination
  OsEditor = ( opsModel )->
    if opsModel.isStack()
      return new StackEditor opsModel

  OpsEditor.registerEditors OsEditor, ( model )-> model.type is "OpenstackOps"

  OsEditor
