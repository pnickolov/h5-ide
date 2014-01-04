
define [ "constant", "../ConnectionModel", "i18n!nls/lang.js" ], ( constant, ConnectionModel, lang )->

  C = ConnectionModel.extend {

    type : "EniAttachment"

    initialize : ()->

      # If Eni is attached to Ami, then hide sg line
      ami = @getTarget constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      eni = @getTarget constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

      for e in ami.connectionTargets( "EniAttachment" )
        if e is eni
          @setDestroyAfterInit()
          return

      @on "destroy", @tryReconnect
      null

    tryReconnect : ()->
      # When remove attachment, see if we need to connect sgline between eni and ami
      ami = @getTarget constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      eni = @getTarget constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      if ami and eni
        SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
        SgModel.tryDrawLine( ami, eni )

      null

    defaults :
      lineType : "attachment"

    portDefs :
      port1 :
        name : "instance-attach"
        type : constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

      port2 :
        name : "eni-attach"
        type : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

  }, {
    isConnectable : ( p1Comp, p2Comp )->
      p1p = p1Comp.parent()
      p2p = p2Comp.parent()
      if p1p.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_Subnet
        p1p = p1p.parent()
        p2p = p2p.parent()

      # Instance and Eni should be in the same az
      if p1p isnt p2p then return false

      # If instance has automaticAssignPublicIp. Then ask the user to comfirm
      if p1Comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
        instance = p1Comp
        eni      = p2Comp
      else
        instance = p2Comp
        eni      = p1Comp


      maxEniCount = instance.getMaxEniCount()
      # Instance have an embed eni
      if instance.connections( "EniAttachment" ).length + 1 >= maxEniCount
        return sprintf lang.ide.CVS_WARN_EXCEED_ENI_LIMIT, instance.get("name"), instance.get("instanceType"), maxEniCount


      if instance.getEmbedEni().get("assoPublicIp") is true
        return {
          confirm : MC.template.modalAttachingEni({
            host : instance.get("name")
            eni  : eni.get("name")
          })
          action  : "Attach and Remove Public IP"
        }

      true
  }

  C
