
###
  OpsEditor is a workspace for working on an OpsModel
  This class is implemented as a class cluster. Actually implementation is seperated in
  other concrete class :

  ProgressViewer  : For starting app.
###

define [
  "OpsEditor" # Dependency

  "./AwsEditorStack"
  "./AwsEditorApp"

  # Extra Includes
  './model/connection/EniAttachment'
  './model/connection/VPNConnection'
  './model/connection/DbReplication'
  './model/InstanceModel'
  './model/EniModel'
  './model/VolumeModel'
  './model/AclModel'
  './model/AsgModel'
  './model/AzModel'
  './model/AzModel'
  './model/CgwModel'
  './model/ElbModel'
  './model/LcModel'
  './model/KeypairModel'
  './model/SslCertModel'
  './model/RtbModel'
  './model/SgModel'
  './model/SubnetModel'
  './model/VpcModel'
  './model/IgwModel'
  './model/VgwModel'
  './model/SnsModel'
  './model/StorageModel'
  './model/ScalingPolicyModel'
  './model/DBSbgModel'
  './model/DBInstanceModel'
  './model/DBOgModel'

  "./model/deserializeVisitor/JsonFixer"
  "./model/deserializeVisitor/EipMerge"
  "./model/deserializeVisitor/FixOldStack"
  "./model/deserializeVisitor/AsgExpandor"
  "./model/deserializeVisitor/ElbSgNamePatch"
  "./model/serializeVisitor/EniIpAssigner"
  "./model/serializeVisitor/AppToStack"

  "./canvas/CanvasViewAws"
  "./canvas/CanvasViewAwsLayout"

  "./canvas/CeVpc"
  "./canvas/CeAz"
  "./canvas/CeSubnet"
  "./canvas/CeRtb"
  "./canvas/CeIgw"
  "./canvas/CeVgw"
  "./canvas/CeCgw"
  "./canvas/CeElb"
  "./canvas/CeEni"
  "./canvas/CeInstance"
  "./canvas/CeAsg"
  "./canvas/CeLc"
  "./canvas/CeSgAsso"
  "./canvas/CeLine"
  "./canvas/CeSgLine"
  "./canvas/CeDbInstance"
  "./canvas/CeDbSubnetGroup"

], ( OpsEditor, StackEditor, AppEditor )->

  # OpsEditor defination
  AwsEditor = ( opsModel )->
    if opsModel.isStack()
      return new StackEditor opsModel
    else
      return new AppEditor opsModel

  OpsEditor.registerEditors AwsEditor, ( model )-> model.type is "AwsOps"

  AwsEditor
