#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', "Design", 'constant' ], ( PropertyModel, Design, constant ) ->

  ConnectionModel = PropertyModel.extend {

    init : ( uid ) ->

      cn = Design.instance().component( uid )
      if not cn then return false

      if cn.type is "EniAttachment"
        attr =
          name : "Instance-ENI Attachment"
          eniAsso : {
            instance : cn.getTarget( constant.RESTYPE.INSTANCE  ).get("name")
            eni      : cn.getTarget( constant.RESTYPE.ENI ).get("name")
          }

      else if cn.type is "ElbSubnetAsso"
        attr =
          name : "Load Balancer-Subnet Association"
          subnetAsso : {
            elb : cn.getTarget( constant.RESTYPE.ELB ).get("name")
            subnet : cn.getTarget( constant.RESTYPE.SUBNET  ).get("name")
          }

      @set attr
  }

  new ConnectionModel()
