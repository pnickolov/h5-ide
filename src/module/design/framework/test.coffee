define [ 'Design',
         './ResourceModel',
         './ComplexResModel',
         './GroupModel',
         './ConnectionModel',
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
         "./util/serializeVisitor/EniIpVisitor"

], ( Design, ResourceModel, ComplexResModel, GroupModel, ConnectionModel, EniAttachment, VPNConnection, InstanceModel, EniModel )->



  window.Design          = Design
  window.ResourceModel   = ResourceModel
  window.ComplexResModel = ComplexResModel
  window.GroupModel      = GroupModel

  # window.testDesign = new Design( {}, {}, { type : Design.TYPE.Vpc, mode : Design.MODE.Stack } )
  # window.testRM     = new ResourceModel()
  # window.testCRM    = new ComplexResModel()
  # window.testGM     = new GroupModel()
  # window.testCN     = new ConnectionModel( "123", "port-1", "123", "port-2" )

  # Design.instance().getAZ("east-1")
  # Design.instance().getAZ("east-1")
  # Design.instance().getAZ("east-2")
  # Design.instance().getAZ("east-3")
  # Design.instance().getAZ("east-4")

  # console.log AzModel.allObjects()

  # new Design( {}, { component : { group : {}, node : {} } }, {} )

  # instance = new InstanceModel()
  # eni      = new EniModel()
  # attach   = new EniAttachment( eni, instance )

  window.InstanceModel = InstanceModel
  window.EniModel      = EniModel
  window.EniAttachment = EniAttachment

  # new Design({},{ component : { group : {}, node : {} } },{type:"ec2-vpc",mode:"appview"})

  # Model = Design.modelClassForType("SgIpTarget")
  # new Model("0.0.0.0")
  # new Model("0.0.0.0")
  # new Model("0.0.0.0")

  # a = new ComplexResModel()
  # b = new ComplexResModel()
  # c = new ComplexResModel()
  # d = new ComplexResModel()
  # a.listenTo b, "charge", ()-> null
  # a.listenTo b, "charge2", ()-> null
  # a.listenTo c, "destroy", ()-> null
  # a.listenTo d, "charge", ()-> null
  # b.remove()
  # c.remove()
  # a.remove()

  null


