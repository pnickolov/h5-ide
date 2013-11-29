define [ './Design',
         './ResourceModel',
         './ComplexResModel',
         './GroupModel',
         './ConnectionModel',
         './subclasses/AclModel',
         './subclasses/AsgModel',
         './subclasses/AzModel',
         './subclasses/CgwModel',
         './subclasses/ElbModel',
         './subclasses/EniModel',
         './subclasses/InstanceModel',
         './subclasses/LcModel',
         './subclasses/RtbModel',
         './subclasses/SgModel',
         './subclasses/SubnetModel',
         './subclasses/VpcModel',
], ( Design, ResourceModel, ComplexResModel, GroupModel, ConnectionModel )->

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


