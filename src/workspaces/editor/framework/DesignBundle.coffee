define [ 'Design',
         "CanvasManager",

         './connection/EniAttachment'
         './connection/VPNConnection'
         './resource/InstanceModel'
         './resource/EniModel'
         './resource/VolumeModel'
         './resource/AclModel'
         './resource/AsgModel'
         './resource/AzModel'
         './resource/AzModel'
         './resource/CgwModel'
         './resource/ElbModel'
         './resource/LcModel'
         './resource/KeypairModel'
         './resource/SslCertModel'
         './resource/RtbModel'
         './resource/SgModel'
         './resource/SubnetModel'
         './resource/VpcModel'
         './resource/IgwModel'
         './resource/VgwModel'
         './resource/SnsModel'
         './resource/StorageModel'
         './resource/ScalingPolicyModel'
         './resource/DBSbgModel'
         './resource/DBInstanceModel'

         "./util/deserializeVisitor/JsonFixer"
         "./util/deserializeVisitor/EipMerge"
         "./util/deserializeVisitor/FixOldStack"
         "./util/deserializeVisitor/AsgExpandor"
         "./util/deserializeVisitor/ElbSgNamePatch"
         "./util/serializeVisitor/EniIpAssigner"
         "./util/serializeVisitor/AppToStack"

         "./canvasview/CeLine"
         './canvasview/CeAz'
         './canvasview/CeSubnet'
         './canvasview/CeVpc'
         "./canvasview/CeCgw"
         "./canvasview/CeIgw"
         "./canvasview/CeVgw"
         "./canvasview/CeRtb"
         "./canvasview/CeElb"
         "./canvasview/CeAsg"
         "./canvasview/CeExpandedAsg"
         "./canvasview/CeInstance"
         "./canvasview/CeVolume"
         "./canvasview/CeEni"
         "./canvasview/CeLc"
         './canvasview/CeDBSBG'
         './canvasview/CeDBInstance'

], ( Design )->

  ### env:dev ###
  require ["./workspaces/editor/framework/util/DesignDebugger"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["./workspaces/editor/framework/util/DesignDebugger"], ()->
  ### env:debug:end ###

  window.Design = Design
  Design
