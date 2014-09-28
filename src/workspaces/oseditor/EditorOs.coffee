
define [
  "OpsEditor" # Dependency

  "./OsEditorStack"
  "./OsEditorApp"

  # Extra Includes
  "./model/OsModelFloatIp"
  "./model/OsModelHealthMonitor"
  "./model/OsModelListener"
  "./model/OsModelNetwork"
  "./model/OsModelPool"
  "./model/OsModelPort"
  "./model/OsModelRt"
  "./model/OsModelKeypair"
  "./model/OsModelServer"
  "./model/OsModelSg"
  "./model/OsModelSgRule"
  "./model/OsModelSubnet"
  "./model/OsModelVolume"
  "./model/OsModelExtNetwork"

  "./model/connection/OsFloatIpUsage"
  "./model/connection/OsListenerAsso"
  "./model/connection/OsPoolMembership"
  "./model/connection/OsPortUsage"
  "./model/connection/OsRouterAsso"
  "./model/connection/OsSgAsso"
  "./model/connection/OsVolumeUsage"

  "./model/seVisitors/AppToStack"

  "./canvas/CeNetwork"
  "./canvas/CeSubnet"
  "./canvas/CeRt"
  "./canvas/CePool"
  "./canvas/CeListener"
  "./canvas/CeExtNetwork"
  "./canvas/CeServer"
  "./canvas/CePort"
  "./canvas/CeOsLine"

], ( OpsEditor, StackEditor, AppEditor )->

  # OpsEditor defination
  OsEditor = ( opsModel )->
    if opsModel.isStack()
      return new StackEditor( opsModel )
    else
      return new AppEditor( opsModel )

  OpsEditor.registerEditors OsEditor, ( model )-> model.type is "OpenstackOps"

  OsEditor
