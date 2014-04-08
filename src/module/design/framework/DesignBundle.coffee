define [ 'Design',
         "CanvasManager",

         './connection/EniAttachment',
         './connection/VPNConnection',
         './resource/InstanceModel',
         './resource/EniModel',
         './resource/VolumeModel',
         './resource/AclModel',
         './resource/AsgModel',
         './resource/AzModel',
         './resource/AzModel',
         './resource/CgwModel',
         './resource/ElbModel',
         './resource/LcModel',
         './resource/KeypairModel',
         './resource/SslCertModel',
         './resource/RtbModel',
         './resource/SgModel',
         './resource/SubnetModel',
         './resource/VpcModel',
         './resource/IgwModel',
         './resource/VgwModel',
         './resource/SnsSubscription',
         './resource/StorageModel',
         './resource/ScalingPolicyModel',

         "./util/deserializeVisitor/JsonFixer",
         "./util/deserializeVisitor/EipMerge",
         "./util/deserializeVisitor/FixOldStack",
         "./util/deserializeVisitor/AsgExpandor",
         "./util/deserializeVisitor/ElbSgNamePatch",
         "./util/serializeVisitor/EniIpAssigner",

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

], ( Design )->

  ### env:dev ###
  require ["./module/design/framework/util/DesignDebugger"], ()->
  ### env:dev:end ###

  window.Design = Design
  Design
