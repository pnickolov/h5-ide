
define [ "constant", "ConnectionModel", "i18n!/nls/lang.js" ], ( constant, ConnectionModel, lang )->

  C = ConnectionModel.extend {

    type : "MarathonDep"

    directional : true

    portDefs : [
      {
        port1 :
          name : "app-dep-out"
          type : constant.RESTYPE.MRTHAPP
        port2 :
          name : "group-dep-in"
          type : constant.RESTYPE.MRTHGROUP
      }
      {
        port1 :
          name : "app-dep-out"
          type : constant.RESTYPE.MRTHAPP
        port2 :
          name : "app-dep-in"
          type : constant.RESTYPE.MRTHAPP
      }
      {
        port1 :
          name : "group-dep-out"
          type : constant.RESTYPE.MRTHGROUP
        port2 :
          name : "group-dep-in"
          type : constant.RESTYPE.MRTHGROUP
      }
      {
        port1 :
          name : "group-dep-out"
          type : constant.RESTYPE.MRTHGROUP
        port2 :
          name : "app-dep-in"
          type : constant.RESTYPE.MRTHAPP
      }
    ]


  }, {
    isConnectable : ( p1Comp, p2Comp )->
      # p1p = p1Comp.parent()
      # p2p = p2Comp.parent()

      # if not p1p or not p2p then return false

      # if p1p.type is constant.RESTYPE.SUBNET
      #   p1p = p1p.parent()
      #   p2p = p2p.parent()

      # # Instance and Eni should be in the same az
      # if p1p isnt p2p then return false

      # # If instance has automaticAssignPublicIp. Then ask the user to comfirm
      # if p1Comp.type is constant.RESTYPE.INSTANCE
      #   instance = p1Comp
      #   eni      = p2Comp
      # else
      #   instance = p2Comp
      #   eni      = p1Comp


      # # Eni can only be attached to an instance.
      # if eni.connections("EniAttachment").length > 0 then return false


      # maxEniCount = instance.getMaxEniCount()
      # # Instance have an embed eni
      # if instance.connections( "EniAttachment" ).length + 1 >= maxEniCount
      #   return sprintf lang.CANVAS.CVS_WARN_EXCEED_ENI_LIMIT, instance.get("name"), instance.get("instanceType"), maxEniCount


      # if instance.getEmbedEni().get("assoPublicIp") is true
      #   return {
      #     confirm  : true
      #     title    : lang.CANVAS.ATTACH_NETWORK_INTERFACE_TO_INTERFACE
      #     action   : lang.CANVAS.ATTACH_AND_REMOVE_PUBLIC_IP
      #     template : MC.template.modalAttachingEni({
      #       host : instance.get("name")
      #       eni  : eni.get("name")
      #     })
      #   }

      true
  }

  C
