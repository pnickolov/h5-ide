#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', "Design", 'constant', 'i18n!/nls/lang.js' ], ( PropertyModel, Design, constant, lang ) ->

  ConnectionModel = PropertyModel.extend {

    init : ( uid ) ->

      cn = Design.instance().component( uid )
      if not cn then return false

      if cn.type is "EniAttachment"
        attr =
          name : lang.PROP.ENI_ATTACHMENT_NAME
          eniAsso : {
            instance : cn.getTarget( constant.RESTYPE.INSTANCE  ).get("name")
            eni      : cn.getTarget( constant.RESTYPE.ENI ).get("name")
          }

      else if cn.type is "ElbSubnetAsso"
        attr =
          name : lang.PROP.ELB_SUBNET_ASSO_NAME
          subnetAsso : {
            elb : cn.getTarget( constant.RESTYPE.ELB ).get("name")
            subnet : cn.getTarget( constant.RESTYPE.SUBNET  ).get("name")
          }

      @set attr
  }

  new ConnectionModel()
