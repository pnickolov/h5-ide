
define [ 'Design',

         './connection/EniAttachment'
         './connection/VPNConnection'
         './connection/DbReplication'
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
         './resource/DBOgModel'

         "./util/deserializeVisitor/JsonFixer"
         "./util/deserializeVisitor/EipMerge"
         "./util/deserializeVisitor/FixOldStack"
         "./util/deserializeVisitor/AsgExpandor"
         "./util/deserializeVisitor/ElbSgNamePatch"
         "./util/serializeVisitor/EniIpAssigner"
         "./util/serializeVisitor/AppToStack"

], ( Design )->

  ### env:dev ###
  require ["./workspaces/editor/framework/util/DesignDebugger"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["./workspaces/editor/framework/util/DesignDebugger"], ()->
  ### env:debug:end ###

  window.Design = Design
  Design
