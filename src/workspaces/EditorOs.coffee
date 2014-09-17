
define [
  "OpsEditor" # Dependency

  "./oseditor/OsEditorStack"
  "./oseditor/OsEditorApp"

  # Extra Includes
  "./oseditor/model/OsModelFloatIp"
  "./oseditor/model/OsModelHealthMonitor"
  "./oseditor/model/OsModelListener"
  "./oseditor/model/OsModelNetwork"
  "./oseditor/model/OsModelPool"
  "./oseditor/model/OsModelPort"
  "./oseditor/model/OsModelRt"
  "./oseditor/model/OsModelServer"
  "./oseditor/model/OsModelSg"
  "./oseditor/model/OsModelSgRule"
  "./oseditor/model/OsModelSubnet"
  "./oseditor/model/OsModelVolume"
  "./oseditor/model/OsModelExtNetwork"

  "./oseditor/model/connection/OsFloatIpUsage"
  "./oseditor/model/connection/OsListenerAsso"
  "./oseditor/model/connection/OsPoolMembership"
  "./oseditor/model/connection/OsPortUsage"
  "./oseditor/model/connection/OsRouterAsso"
  "./oseditor/model/connection/OsSgAsso"
  "./oseditor/model/connection/OsVolumeUsage"

  "./oseditor/model/seVisitors/AppToStack"

  "./oseditor/canvas/CeNetwork"
  "./oseditor/canvas/CeSubnet"
  "./oseditor/canvas/CeRt"
  "./oseditor/canvas/CePool"
  "./oseditor/canvas/CeListener"
  "./oseditor/canvas/CeExtNetwork"
  "./oseditor/canvas/CeServer"
  "./oseditor/canvas/CePort"
  "./oseditor/canvas/CeOsLine"

], ( OpsEditor, StackEditor, AppEditor )->

  # OpsEditor defination
  OsEditor = ( opsModel )->
    if opsModel.isStack()
      return new StackEditor( opsModel )
    else
      return new AppEditor( opsModel )

  OpsEditor.registerEditors OsEditor, ( model )-> model.type is "OpenstackOps"

  OsEditor
