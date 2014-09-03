
###
  OpsEditor is a workspace for working on an OpsModel
  This class is implemented as a class cluster. Actually implementation is seperated in
  other concrete class :

  ProgressViewer  : For starting app.
###

define [
  "OpsEditor" # Dependency

  "ProgressViewer"
  "./awseditor/AwsEditorStack"
  "./awseditor/AwsEditorApp"

  # Extra Includes
  './awseditor/model/connection/EniAttachment'
  './awseditor/model/connection/VPNConnection'
  './awseditor/model/connection/DbReplication'
  './awseditor/model/InstanceModel'
  './awseditor/model/EniModel'
  './awseditor/model/VolumeModel'
  './awseditor/model/AclModel'
  './awseditor/model/AsgModel'
  './awseditor/model/AzModel'
  './awseditor/model/AzModel'
  './awseditor/model/CgwModel'
  './awseditor/model/ElbModel'
  './awseditor/model/LcModel'
  './awseditor/model/KeypairModel'
  './awseditor/model/SslCertModel'
  './awseditor/model/RtbModel'
  './awseditor/model/SgModel'
  './awseditor/model/SubnetModel'
  './awseditor/model/VpcModel'
  './awseditor/model/IgwModel'
  './awseditor/model/VgwModel'
  './awseditor/model/SnsModel'
  './awseditor/model/StorageModel'
  './awseditor/model/ScalingPolicyModel'
  './awseditor/model/DBSbgModel'
  './awseditor/model/DBInstanceModel'
  './awseditor/model/DBOgModel'

  "./awseditor/model/deserializeVisitor/JsonFixer"
  "./awseditor/model/deserializeVisitor/EipMerge"
  "./awseditor/model/deserializeVisitor/FixOldStack"
  "./awseditor/model/deserializeVisitor/AsgExpandor"
  "./awseditor/model/deserializeVisitor/ElbSgNamePatch"
  "./awseditor/model/serializeVisitor/EniIpAssigner"
  "./awseditor/model/serializeVisitor/AppToStack"

  "./awseditor/canvas/CanvasViewAws"
  "./awseditor/canvas/CanvasViewAwsLayout"

  "./awseditor/canvas/CeVpc"
  "./awseditor/canvas/CeAz"
  "./awseditor/canvas/CeSubnet"
  "./awseditor/canvas/CeRtb"
  "./awseditor/canvas/CeIgw"
  "./awseditor/canvas/CeVgw"
  "./awseditor/canvas/CeCgw"
  "./awseditor/canvas/CeElb"
  "./awseditor/canvas/CeEni"
  "./awseditor/canvas/CeInstance"
  "./awseditor/canvas/CeAsg"
  "./awseditor/canvas/CeLc"
  "./awseditor/canvas/CeSgAsso"
  "./awseditor/canvas/CeLine"
  "./awseditor/canvas/CeSgLine"
  "./awseditor/canvas/CeDbInstance"
  "./awseditor/canvas/CeDbSubnetGroup"

], ( OpsEditor, ProgressViewer, StackEditor, AppEditor )->

  # OpsEditor defination
  AwsEditor = ( opsModel )->
    if not opsModel
      throw new Error("Cannot find opsmodel while openning workspace.")

    if opsModel.isProcessing()
      return new ProgressViewer opsModel

    if opsModel.isStack()
      return new StackEditor opsModel
    else
      return new AppEditor opsModel

  OpsEditor.registerEditors AwsEditor, ( model )-> model.type is "AwsOps"

  AwsEditor
