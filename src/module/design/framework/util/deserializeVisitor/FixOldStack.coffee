
define [ "Design", "constant" ], ( Design, constant )->

  # FixOldStack is used to insert DefaultKP and DefaultSG if they're missing

  Design.registerDeserializeVisitor ( data, layout_data )->

    # Only fix json in stack mode
    if not Design.instance().modeIsStack() then return

    for uid, comp of data
      if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair
        if comp.name is "DefaultKP"
          foundKP = true
          if foundSG then break
      else if comp.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
        if comp.name is "DefaultSG"
          foundSG = true
          if foundKP then break

    if not foundKP
      uid = MC.guid()
      data[ uid ] = {
        uid  : uid
        type : constant.AWS_RESOURCE_TYPE.AWS_EC2_KeyPair
        name : "DefaultKP"
        resource : { KeyName : "DefaultKP" }
      }

    if not foundSG
      uid = MC.guid()
      data[ uid ] = {
        uid  : uid
        type : constant.AWS_RESOURCE_TYPE.AWS_EC2_SecurityGroup
        name : "DefaultSG"
        resource : {
          IpPermissions: [{
            IpProtocol : "tcp",
            IpRanges   : "0.0.0.0/0",
            FromPort   : "22",
            ToPort     : "22",
            Groups     : [{"GroupId":"","UserId":"","GroupName":""}]
          }],
          IpPermissionsEgress : [],
          Default             : "true",
          GroupName           : "DefaultSG",
          GroupDescription    : 'Default Security Group'
        }
      }

  null

