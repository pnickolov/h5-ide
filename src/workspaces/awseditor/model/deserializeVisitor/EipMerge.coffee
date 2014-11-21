
define [ "../DesignAws"], ( Design )->

  # EipMerge is an util function to merge Eip.resource into Eni.resource.PrivateIpAddressSet.EipResource

  Design.registerDeserializeVisitor ( data, layout_data )->

    for uid, comp of data
      if comp.type is "AWS.EC2.EIP"
        if comp.resource.NetworkInterfaceId
          refArray = comp.resource.PrivateIpAddress.split(".")
          eni_comp = data[ MC.extractID( refArray[0] ) ]
          if not eni_comp then continue
          ipObj = eni_comp.resource.PrivateIpAddressSet[ refArray[3] * 1 ]
          if not ipObj then continue
          ipObj.EipResource = comp
        else
          instance_comp = data[ MC.extractID( comp.resource.InstanceId ) ]
          if instance_comp
            instance_comp.resource.EipResource = comp

    null

  null
