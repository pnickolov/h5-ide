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
            instance : cn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance  ).get("name")
            eni      : cn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface ).get("name")
          }

      else if cn.type is "ElbSubnetAsso"
        attr =
          name : "Load Balancer-Subnet Association"
          subnetAsso : {
            elb : cn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_ELB ).get("name")
            subnet : cn.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet  ).get("name")
          }

      @set attr
  }

  new ConnectionModel()
