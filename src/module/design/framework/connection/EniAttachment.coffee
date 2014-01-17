
define [ "constant", "../ConnectionModel", "i18n!nls/lang.js" ], ( constant, ConnectionModel, lang )->

  C = ConnectionModel.extend {

    type : "EniAttachment"

    defaults :
      lineType : "attachment"
      index : 1

    initialize : ( attributes )->

      # If Eni is attached to Ami, then hide sg line
      ami = @getTarget constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      eni = @getTarget constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

      for sgline in eni.connections( "SgRuleLine" )
        if sgline.getTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance ) is ami
          sgline.remove()
          break

      @on "destroy", @tryReconnect

      # Calc the new index of this EniAttachment.
      if attributes and attributes.index
        # The EniAttachment has a specified index ( This happens when the Eni is deserializing )
        @ensureAttachmentOrder()
      else
        # Newly created EniAttachment has the last index.
        @attributes.index = ami.connectionTargets( "EniAttachment" ).length + 1
      null

    ensureAttachmentOrder : ()->
      ami = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance )
      attachments = ami.connections( "EniAttachment" )

      for attach in attachments
        # If we found duplicated index, we just reassign all attachement index.
        if attach isnt this and attach.attributes.index is this.attributes.index
          for attach, idx in attachments
            attach.attributes.index = idx + 1
            attach.getOtherTarget( ami ).updateName()
          return

      newArray = attachments.sort (a, b)-> a.attributes.index - b.attributes.index
      if attachments.indexOf( this ) isnt newArray.indexOf( this )
        # The index of this line has changed. Modified ami's connection array.
        # So that ami.connections("EniAttachment") will always return an sorted EniAttachments.
        amiConnections = []
        for cnn in ami.get("__connections")
          if cnn.type isnt "EniAttachment"
            amiConnections.push cnn

        ami.attributes.__connections = amiConnections.concat newArray

      null

    tryReconnect : ()->
      # When remove attachment, see if we need to connect sgline between eni and ami
      ami = @getTarget constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
      eni = @getTarget constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
      if ami and eni
        SgModel = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup )
        SgModel.tryDrawLine( ami, eni )

      null

    remove : ()->
      # When this EniAttachment is removed, we need to update all the Eni's name.
      attachments = @getTarget( constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance ).connections("EniAttachment")

      startIdx = attachments.indexOf( this )+1
      while startIdx < attachments.length
        attach = attachments[ startIdx ]
        attach.attributes.index -= 1
        attach.getTarget( constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface ).updateName()
        ++startIdx

      null

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


      # Eni can only be attached to an instance.
      if eni.connections("EniAttachment").length > 0 then return false


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
