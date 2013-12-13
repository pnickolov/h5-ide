define [ 'Design',
         './ResourceModel',
         './ComplexResModel',
         './GroupModel',
         './ConnectionModel',
         './connection/EniAttachment',
         './connection/VPNConnection',
         './resource/InstanceModel',
         './resource/EniModel',
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

  null


