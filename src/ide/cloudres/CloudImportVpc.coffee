
define ["CloudResources", "ide/cloudres/CrCollection", "constant", "ApiRequest", "DiffTree"], ( CloudResources, CrCollection, constant, ApiRequest, DiffTree )->

  # Helpers
  CREATE_REF = ( compOrUid, attr ) ->
    return '' if not compOrUid
    if attr
      return "@{#{compOrUid.uid or compOrUid}.#{attr}}"
    else
      return "@{#{compOrUid.uid or compOrUid}.r.p}"

  UID        = MC.guid
  AWS_ID     = ( dict, type )->
    key = constant.AWS_RESOURCE_KEY[ type ]
    dict[ key ] or dict.resource and dict.resource[ key ]
  TAG_NAME   = ( res ) ->
    name = null
    if res.tagSet
      name = res.tagSet.name or res.tagSet.Name or res.tagSet["aws:cloudformation:logical-id"]
    name

  # Class used to collect components / layouts
  class ConverterData
    CrPartials : ( type )-> CloudResources( constant.RESTYPE[type], @region )

    getResourceByType: ( type ) -> CloudResources( constant.RESTYPE[type], @region ).filter ( model ) =>  model.RES_TAG is @vpcId

    constructor : ( region, vpcId, originalJson )->
      # @theVpc  = null
      @region    = region
      @vpcId     = vpcId
      @azs       = {}
      @subnets   = {} # res id   => comp
      @instances = {} # res id   => comp
      @enis      = {} # res id   => comp
      @gateways  = {} # res id   => comp
      @volumes   = {} # res id   => comp
      @sgs       = {} # res id   => comp
      @iams      = {} # res arn  => comp
      @elbs      = {} # res name => comp
      @lcs       = {} # res name => comp
      @asgs      = {} # res name => comp
      @topics    = {} # res arn  => comp
      @sps       = {} # res id  => comp
      @sbgs      = {} # res id(name) => comp
      @dbinstances = {} # res id(name) => comp
      @ogs       = {} # res id(name) => comp
      @ins_in_asg= [] # instances in asg
      @component = {}
      @layout    = {}
      @originalJson = jQuery.extend(true, {component: [], layout: []}, originalJson) #extend original app json
      @originAppJSON = originalJson #origin app json

      @DEFAULT_KP = null

      @COMPARISONOPERATOR =
        "GreaterThanOrEqualToThreshold" : ">="
        "GreaterThanThreshold"          : ">"
        "LessThanThreshold"             : "<"
        "LessThanOrEqualToThreshold"    : "<="

    add : ( shortType, resource, name )->
      type = constant.RESTYPE[ shortType ]
      # Directly add component based on original component
      if resource and resource.uid
        @component[ resource.uid ] = resource
        return resource

      # Found an original component by resource
      originComp = @getOriginalComp resource, type
      if originComp
        _.extend originComp.resource, resource
        @component[ originComp.uid ] = originComp
        return @component[ originComp.uid ]

      # New or importVpc
      comp =
        uid  : UID()
        name : name or AWS_ID( resource, type ) or shortType
        type : type
        resource : resource

      @component[ comp.uid ] = comp
      comp

    addLayout : ( component, isGroupLayout, parentComp )->
      l = @originalJson.layout[ component.uid ]

      if not l
        l =
          uid : component.uid
          coordinate : [0,0]

        if isGroupLayout then l.size = [0,0]
        if parentComp    then l.groupUId = parentComp.uid

      @layout[ l.uid ] = l
      return

    addExpandedAsg : ( originalAsg, parentComp )->
      #ExpandedAsg is not Group
      for key,node of @originalJson.layout
        if node.type is "ExpandedAsg" and node.originalId is originalAsg.uid and node.groupUId is parentComp.uid
          l = @originalJson.layout[ node.uid ]
          break

      if not l
        l =
          uid : UID()
          coordinate : [0,0]
          originalId : originalAsg.uid
          type       : "ExpandedAsg"
          groupUId   : parentComp.uid

      @layout[ l.uid ] = l
      return

    addAz : ( azName )->
      az = @azs[ azName ]
      if az then return az
      azRes = @getOriginalComp( azName, 'AZ' )
      if not azRes
        azRes =
          "RegionName": @region
          "ZoneName": azName
      az = @add( "AZ", azRes, azName )
      @addLayout( az, true, @theVpc )
      @azs[ azName ] = az
      az

    addIAM : ( arn ) ->
      iamComp = @iams[ arn ]
      if iamComp then return iamComp

      reg_iam=/arn:aws:iam::.*:server-certificate\/.*/g
      if not arn.match(reg_iam)
        console.error "[addIam] not a valid iam arn"
        return null

      tmpAry = arn.split(":")
      name = tmpAry[tmpAry.length-1].replace("server-certificate/","")

      iamRes =
        "CertificateBody" : ""
        "CertificateChain": ""
        "PrivateKey"      : ""
        "ServerCertificateMetadata":
          "Arn"                  : arn
          "ServerCertificateId"  : ""
          "ServerCertificateName": name

      iamComp = @add( "IAM", iamRes, name )
      @iams[ arn ] = iamComp
      return iamComp

      # for aws_iam in @CrPartials( "IAM" ).where({Arn:arn}) || []
      #   aws_iam = aws_iam.attributes

    addTopic : ( arn ) ->
      topicComp = @topics[ arn ]
      if topicComp then return topicComp
      topicRes =
        "TopicArn" : arn
      tmpAry = arn.split(":")
      if tmpAry.length>0
        topicName = tmpAry[tmpAry.length - 1]
      topicComp = @add( "TOPIC", topicRes, topicName )
      @topics[ arn ] = topicComp
      return topicComp

    getOriginalComp: ( jsonOrKey, type ) ->
      if type is constant.RESTYPE[ "NC" ]
        for uid, comp of @originalJson.component
          if comp.type isnt type then continue
          if comp.resource.AutoScalingGroupName is jsonOrKey.AutoScalingGroupName and comp.resource.TopicARN is jsonOrKey.TopicARN
            return comp
      else
        type = constant.RESTYPE[ type ] or type
        key = constant.AWS_RESOURCE_KEY[ type ]
        id = if _.isObject jsonOrKey then jsonOrKey[key] else jsonOrKey
        if not id then return null
        for uid, comp of @originalJson.component
          if comp.type isnt type then continue
          if ( comp[ key ] or comp.resource[ key ] ) is id
            return comp
      null

    _mapProperty : ( aws_json, resource ) ->
      for k, v of aws_json
        if typeof(v) in [ "string", "number", "boolean" ] and resource[k[0].toUpperCase() + k.slice(1)] isnt undefined
          resource[k[0].toUpperCase() + k.slice(1)] = v
      resource

    _genCompMap : ( originalJson ) ->
      compMap = {}
      for uid, comp of originalJson.component
        key = constant.AWS_RESOURCE_KEY[ comp.type ]

        if not comp.resource then continue;

        if not key then continue

        if not comp.resource[key]
          console.error "not found id " + key + " for resource", comp

        compMap[ comp.resource[key] ] =
          "uid" : uid
          "name": comp.name
      compMap

    _removeAppId : ( name ) ->
      reg_app = /app-[a-z0-9]{8}$/g
      rlt = name.match(reg_app)
      if rlt and rlt.length is 1
        #match app-id succeed
        name = name.replace(rlt[0],"")
      name

  # The order of Converters functions are important!
  # Some converter must be behind other converters.
  Converters = [

    # Retain component only belong to us
    # When and only when these component are not in @component

    () ->
      retainList = [
        'AWS.EC2.Tag'
        'AWS.AutoScaling.Tag'
        constant.RESTYPE.KP
        constant.RESTYPE.TOPIC
        constant.RESTYPE.SUBSCRIPTION
        constant.RESTYPE.IAM
        constant.RESTYPE.DHCP

      ]

      for uid, com of @originalJson.component
        if not @component[ uid ] and ( com.type in retainList )
          compJson = @add null, com
          if com.type is constant.RESTYPE.IAM
            @iams[com.resource.ServerCertificateMetadata.Arn] = compJson
          else if com.type is constant.RESTYPE.KP
            if com.name is "DefaultKP"
              @DEFAULT_KP = jQuery.extend(true, {}, com)
              @component[com.uid] = @DEFAULT_KP
        null

      if not @DEFAULT_KP
        #create DefaultKP
        kpRes =
          "KeyFingerprint" : ""
          "KeyName" : "DefaultKP"
        @add( "KP", kpRes, "DefaultKP" )

      null

    ()-> # Vpc & Dhcp
      vpc = @getResourceByType( "VPC" )[ 0 ]

      #vpc.VpcId = @vpcId
      # Cache the vpc so that other can use it.
      @theVpc = vpcComp = @add("VPC", {
        VpcId           : @vpcId
        CidrBlock       : vpc.attributes.cidrBlock
        DhcpOptionsId   : vpc.attributes.dhcpOptionsId
        InstanceTenancy : vpc.attributes.instanceTenancy

        EnableDnsHostnames : vpc.attributes.enableDnsHostnames
        EnableDnsSupport   : vpc.attributes.enableDnsSupport
      }, TAG_NAME(vpc.attributes) or @vpcId)

      @addLayout( vpcComp, true )
      return


    ()-> # Subnets
      for sb, idx in @getResourceByType("SUBNET") || []
        sb = sb.attributes
        azComp = @addAz(sb.availabilityZone)
        sbComp = @add( "SUBNET", {
          AvailabilityZone : CREATE_REF( azComp, "resource.ZoneName" )
          CidrBlock        : sb.cidrBlock
          SubnetId         : sb.id
          VpcId            : CREATE_REF( @theVpc, "resource.VpcId" )
        }, TAG_NAME(sb) or sb.id )

        @subnets[ sb.id ] = sbComp

        @addLayout( sbComp, true, azComp )
      return


    ()-> # IGW
      for aws_igw in @getResourceByType("IGW") || []
        aws_igw = aws_igw.attributes
        if not (aws_igw.attachmentSet and aws_igw.attachmentSet.length>0)
          continue
        igwRes =
          "AttachmentSet"    : [
            "VpcId": CREATE_REF( @theVpc, "resource.VpcId" )
          ]
          "InternetGatewayId": aws_igw.id

        igwComp = @add( "IGW", igwRes, "Internet-gateway" )
        @addLayout( igwComp, true, @theVpc )
        @gateways[ aws_igw.id ] = igwComp
      return


    ()-> # VGW
      for aws_vgw in @getResourceByType "VGW"
        aws_vgw = aws_vgw.attributes
        if aws_vgw.state in [ "deleted","deleting" ]
          continue
        if aws_vgw.attachments and aws_vgw.attachments.length > 0
          vgwAttach = aws_vgw.attachments[0]
        vgwRes =
          "Attachments": [
            "VpcId": CREATE_REF( @theVpc, "resource.VpcId" )
          ]
          "Type": aws_vgw.type
          "VpnGatewayId": ""

        vgwRes.VpnGatewayId = aws_vgw.id
        vgwComp = @add( "VGW", vgwRes, "VPN-gateway" )
        @addLayout( vgwComp, true, @theVpc )

        @gateways[ aws_vgw.id ] = vgwComp
      return


    ()-> #CGW
      for aws_cgw in @getResourceByType "CGW"
        aws_cgw = aws_cgw.attributes
        if aws_cgw.state in [ "deleted","deleting" ]
          continue
        cgwRes  =
          "BgpAsn"   : if 'bgpAsn' of aws_cgw then aws_cgw.bgpAsn else ""
          "CustomerGatewayId": aws_cgw.id
          "IpAddress": aws_cgw.ipAddress
          "Type"     : aws_cgw.type

        #gwRes = @_mapProperty aws_cgw, cgwRes

        #create cgw component, but add with vpn
        cgwComp = @add( "CGW", cgwRes, TAG_NAME(aws_cgw) )
        delete @component[ cgwComp.uid ]
        @gateways[ aws_cgw.id ] = cgwComp
      return


    ()-> #VPN
      for aws_vpn in @getResourceByType "VPN"
        aws_vpn = aws_vpn.attributes
        if aws_vpn.state in [ "deleted","deleting" ]
          continue
        vgwComp = @gateways[ aws_vpn.vpnGatewayId ]
        cgwComp = @gateways[ aws_vpn.customerGatewayId ]
        if not (cgwComp and vgwComp)
          continue
        vpnRes =
          "CustomerGatewayId" : CREATE_REF( cgwComp, "resource.CustomerGatewayId" )
          "Options"     :
            "StaticRoutesOnly": false
          "Routes": []
          "Type"  : aws_vpn.type
          "VpnConnectionId"   : aws_vpn.id
          "VpnGatewayId": CREATE_REF( vgwComp, "resource.VpnGatewayId" )
          #"CustomerGatewayConfiguration": ""

        #vpnRes = @_mapProperty aws_vpn, vpnRes
        # vpnRes.VpnGatewayId      = CREATE_REF( vgwComp, "resource.VpnGatewayId" )
        # vpnRes.CustomerGatewayId = CREATE_REF( cgwComp, "resource.CustomerGatewayId" )
        if aws_vpn.options and aws_vpn.options.staticRoutesOnly
          vpnRes.Options.StaticRoutesOnly = aws_vpn.options.staticRoutesOnly
          cgwComp.resource.BgpAsn = ""
        if aws_vpn.routes
          for route in aws_vpn.routes
            if route.state in [ "deleting", "deleted" ]
              continue
            vpnRes.Routes.push
              "DestinationCidrBlock" : route.destinationCidrBlock
              #"Source" : route.source

        vpnComp = @add( "VPN", vpnRes, TAG_NAME(aws_vpn) )
        #add CGW to layout
        @component[ cgwComp.uid ] = cgwComp
        @addLayout( cgwComp, false )

      return


    ()-> # SG

      that = this

      sgRefMap = {}

      genRules = (sg_rule, new_ruls) ->

          that = this

          if String(sg_rule.ipProtocol) is '-1'
            sg_rule.fromPort = '0'
            sg_rule.toPort = '65535'

          if sg_rule.groups and sg_rule.groups.length > 0

            _.each sg_rule.groups, (group) ->
              if group.groupId
                iprange = ''
                sgId = group.groupId
                sgComp = sgRefMap[sgId]
                if sgComp
                  iprange = CREATE_REF(sgComp, 'resource.GroupId')
                else
                  iprange = group.groupId

                new_ruls.push {
                  "FromPort": String(if sg_rule.fromPort then sg_rule.fromPort else ""),
                  "IpProtocol": String(sg_rule.ipProtocol),
                  "IpRanges": iprange,
                  "ToPort": String(if sg_rule.toPort then sg_rule.toPort else "")
                }

          else if sg_rule.ipRanges and sg_rule.ipRanges.length > 0

            ipranges = sg_rule.ipRanges
            _.each ipranges, (iprange) ->
              new_ruls.push {
                "FromPort": String(if sg_rule.fromPort then sg_rule.fromPort else ""),
                "IpProtocol": String(sg_rule.ipProtocol),
                "IpRanges": iprange.cidrIp,
                "ToPort": String(if sg_rule.toPort then sg_rule.toPort else "")
              }

      for aws_sg in @getResourceByType( "SG" )
        groupId = aws_sg.attributes.groupId
        sgComp = @getOriginalComp(groupId, 'SG')
        sgRefMap[groupId] = sgComp if sgComp

      vpcDefaultSg = null
      visualopsDefaultSg = null

      for aws_sg in @getResourceByType( "SG" )
        aws_sg = aws_sg.attributes

        sgRes =
          "Default": false
          "GroupDescription": ""
          "GroupId": ""
          "GroupName": ""
          "IpPermissions": []
          "IpPermissionsEgress": []
          "VpcId": ""

        sgRes = @_mapProperty aws_sg, sgRes

        originSGComp = @getOriginalComp(aws_sg.id, 'SG')
        if originSGComp
          sgRes.GroupName = originSGComp.resource.GroupName

        vpcComp = @getOriginalComp(aws_sg.vpcId, 'VPC')
        if vpcComp
          sgRes.VpcId = CREATE_REF(vpcComp.uid, 'resource.VpcId')
        sgRes.GroupDescription = aws_sg.groupDescription

        #generate ipPermissions
        if aws_sg.ipPermissions
          for sg_rule in aws_sg.ipPermissions || []
            genRules.call(@, sg_rule, sgRes.IpPermissions)

        #generate ipPermissionEgress
        if aws_sg.ipPermissionsEgress
          for sg_rule in aws_sg.ipPermissionsEgress || []
            genRules.call(@, sg_rule, sgRes.IpPermissionsEgress)

        sgComp = @add( "SG", sgRes, TAG_NAME(aws_sg) || @_removeAppId(aws_sg.groupName) )
        if aws_sg.groupName is "default"
          vpcDefaultSg = aws_sg
        else if aws_sg.groupName.indexOf("-DefaultSG-app-") isnt -1
          visualopsDefaultSg = aws_sg

        @sgs[ aws_sg.id ] = sgComp

      if visualopsDefaultSg and vpcDefaultSg
        defaultSgComp = @sgs[ vpcDefaultSg.id ]
        delete @sgs[ vpcDefaultSg.id ]
        delete @component[ defaultSgComp.uid ]
        vpcDefaultSg = null

      defaultSg = visualopsDefaultSg || vpcDefaultSg
      if defaultSg
        defaultSg = @sgs[ defaultSg.id ]

      if defaultSg
        defaultSg.name = "DefaultSG"
        defaultSg.resource.Default = true

      _.each that.sgs, (sgComp) ->
        _.each sgComp.resource.IpPermissions, (rule) ->
          if rule.IpRanges and rule.IpRanges.indexOf('sg-') is 0
            refComp = that.sgs[rule.IpRanges]
            if refComp
              ref = CREATE_REF(refComp, 'resource.GroupId')
              rule.IpRanges = ref
        _.each sgComp.resource.IpPermissionsEgress, (rule) ->
          if rule.IpRanges and rule.IpRanges.indexOf('sg-') is 0
            refComp = that.sgs[rule.IpRanges]
            if refComp
              ref = CREATE_REF(refComp, 'resource.GroupId')
              rule.IpRanges = ref
      return

    ()-> #Volume
      for aws_vol in @getResourceByType "VOL"
        aws_vol = aws_vol.attributes
        if not aws_vol.attachmentSet
          #not attached
          continue

        az = @azs[ aws_vol.availabilityZone ]

        volRes =
          "VolumeId"     : aws_vol.id
          "Size"         : Number(aws_vol.size)
          "VolumeSize"   : Number(aws_vol.size)
          "SnapshotId"   : if aws_vol.snapshotId then aws_vol.snapshotId else ""
          "Iops"         : if aws_vol.iops then aws_vol.iops else ""
          "VolumeType"      : aws_vol.volumeType
          "AvailabilityZone": CREATE_REF( az, "resource.ZoneName" )

        # AttachmentSet
        if aws_vol.attachmentSet
          instance = @instances[ aws_vol.attachmentSet[0].instanceId ]
          if instance
            volRes.AttachmentSet.Device = aws_vol.attachmentSet[0].device
            volRes.AttachmentSet.InstanceId = CREATE_REF( instance, "resource.InstanceId" )

        #create volume component, but add with instance
        volComp = @add( "VOL", volRes, aws_vol.attachmentSet[0].device )
        # add volume to layout
        delete @component[ volComp.uid ]
        @volumes[ aws_vol.id ] = volComp
        # @component[ volComp.uid ] = volComp

      return


    ()-> # Instance
      me = @
      #get all instances in asg
      for aws_asg in @getResourceByType "ASG"
        aws_asg = aws_asg.attributes

        _.each aws_asg.Instances, (e,key)->
          me.ins_in_asg.push e.InstanceId

      for aws_ins in @getResourceByType("INSTANCE") || []
        aws_ins = aws_ins.attributes

        #skip invalid instance
        if aws_ins.instanceState.name in [ "shutting-down", "terminated" ]
          continue
        #skip instances in asg
        if aws_ins.id in @ins_in_asg
          continue

        azComp = @addAz(aws_ins.placement.availabilityZone)

        subnetComp = @subnets[aws_ins.subnetId]
        if not subnetComp
          continue

        insRes =
          "BlockDeviceMapping": []
          "DisableApiTermination": false
          "EbsOptimized": ""
          "ImageId"  : ""
          "InstanceId": ""
          "InstanceType": ""
          "KeyName" : ""
          "Monitoring"  : ""
          "NetworkInterface":[]
          "Placement":
            "Tenancy"          : ""
            "AvailabilityZone" : ""
          "SecurityGroup"   : []
          "SecurityGroupId" : []
          "ShutdownBehavior": ""
          "SubnetId": ""
          "UserData":
            "Base64Encoded": false
            "Data"         : ""
          "VpcId"   : ""

        insRes = @_mapProperty aws_ins, insRes

        insRes.SubnetId = CREATE_REF( subnetComp, 'resource.SubnetId' )
        insRes.VpcId  = CREATE_REF( @theVpc, 'resource.VpcId' )
        insRes.Placement.AvailabilityZone = CREATE_REF( azComp, 'resource.ZoneName' )
        insRes.Placement.Tenancy = aws_ins.placement.tenancy

        if aws_ins.monitoring and aws_ins.monitoring
          insRes.Monitoring = aws_ins.monitoring.state

        if aws_ins.placement.tenancy is 'default'
          insRes.Placement.Tenancy = ''

        if not aws_ins.shutdownBehavior
          insRes.ShutdownBehavior = 'terminate'

        insRes.InstanceId        = aws_ins.id
        insRes.EbsOptimized      = aws_ins.ebsOptimized

        originComp = @getOriginalComp(aws_ins.id, 'INSTANCE')

        #generate KeyName for instance
        keyPairComp = @getOriginalComp(aws_ins.keyName, 'KP')
        if keyPairComp
          insRes.KeyName = CREATE_REF( keyPairComp, "resource.KeyName" )
        else
          if aws_ins.keyName
            insRes.KeyName = aws_ins.keyName
          else
            insRes.KeyName = CREATE_REF( @DEFAULT_KP, "resource.KeyName" )

        vol_in_instance = []

        #find rootDevice
        if aws_ins.rootDeviceType is 'ebs'

          ##get root device in original component
          if originComp
            insRes.BlockDeviceMapping = originComp.resource.BlockDeviceMapping || []
            insRes.BlockDeviceMapping = _.filter insRes.BlockDeviceMapping, (bdm) ->
              return false if _.isString(bdm)
              return true

          ##get root device in instance
          rootDeviceAry = []
          _.each aws_ins.blockDeviceMapping, (bdm) ->
            # get root device from instance
            if aws_ins.rootDeviceName.indexOf(bdm.deviceName) isnt -1
              volume = me.volumes[bdm.ebs.volumeId]
              if volume
                rootDevice =
                  DeviceName: bdm.deviceName
                  Ebs:
                    #VolumeId: bdm.ebs.volumeId
                    SnapshotId: volume.resource.SnapshotId
                    VolumeSize: volume.resource.Size
                    VolumeType: volume.resource.VolumeType
                if volume.resource.VolumeType is 'io1'
                  rootDevice.Ebs.Iops = volume.resource.Iops
                rootDeviceAry.push rootDevice
          ##use original data if root device no change
          if insRes.BlockDeviceMapping.length isnt rootDeviceAry.length
            insRes.BlockDeviceMapping = rootDeviceAry

        #find external volume
        _.each aws_ins.blockDeviceMapping || [], (bdm)->
          # external volume point to instance
          if aws_ins.rootDeviceType is 'instance-store' or aws_ins.rootDeviceName.indexOf( bdm.deviceName ) is -1
            volComp = me.volumes[ bdm.ebs.volumeId ]
            if volComp
              #add volume component
              me.component[ volComp.uid ] = volComp
              vol_in_instance.push volComp.uid


        #generate instance component
        insComp = @add( "INSTANCE", insRes, TAG_NAME(aws_ins) )

        #set instanceId of volume
        _.each vol_in_instance, (e,key)->
          volComp = me.component[ e ]
          if volComp
            volComp.resource.AttachmentSet = {} if not volComp.resource.AttachmentSet
            volComp.resource.AttachmentSet.InstanceId = CREATE_REF( insComp, "resource.InstanceId" )

        @addLayout( insComp, false, subnetComp )
        @instances[ aws_ins.id ] = insComp
      return


    ()-> #ENI
      for aws_eni in @getResourceByType("ENI") || []
        aws_eni = aws_eni.attributes
        azComp = @addAz(aws_eni.availabilityZone)

        # if aws_eni.attachment
        #   insComp = @instances[aws_eni.attachment.instanceId]
        #   if not insComp
        #     continue
        # else
        #   continue

        subnetComp = @subnets[aws_eni.subnetId]
        if not subnetComp
          continue

        eniRes =
          "AssociatePublicIpAddress" : false
          "Attachment":
              "AttachmentId" : ""
              "DeviceIndex"  : "1"
              "InstanceId"   : ""
          "AvailabilityZone": ""
          "Description": ""
          "GroupSet"   : []
          "NetworkInterfaceId"  : ""
          "PrivateIpAddressSet" : []
          "SourceDestCheck": true
          "SubnetId"       : ""
          # "PrivateDnsName" : ""
          "VpcId"          : ""

        if aws_eni.attachment and aws_eni.attachment.instanceOwnerId and aws_eni.attachment.instanceOwnerId in [ "amazon-elb", "amazon-rds" ]
          continue

        eniRes = @_mapProperty aws_eni, eniRes

        #check Automatically assign Public IP
        if aws_eni.association and aws_eni.association.publicIp
          eniRes.AssociatePublicIpAddress = true

        eniRes.NetworkInterfaceId = aws_eni.id

        eniRes.AvailabilityZone = CREATE_REF( azComp, 'resource.ZoneName' )
        eniRes.SubnetId         = CREATE_REF( subnetComp, 'resource.SubnetId' )
        eniRes.VpcId            = CREATE_REF( @theVpc, 'resource.VpcId' )

        #attached ENI
        if aws_eni.attachment
          if not ( aws_eni.attachment.deviceIndex in [ "0", 0 ] )
            #eni0 no need attachmentId
            eniRes.Attachment.AttachmentId = aws_eni.attachment.attachmentId

          insComp = @instances[aws_eni.attachment.instanceId]
          if insComp
            eniRes.Attachment.InstanceId = CREATE_REF( insComp, 'resource.InstanceId' )
            eniRes.Attachment.DeviceIndex = String(if aws_eni.attachment.deviceIndex is 0 then '0' else aws_eni.attachment.deviceIndex)

        for ip in aws_eni.privateIpAddressesSet
          #AutoAssign set to false in app
          eniRes.PrivateIpAddressSet.push {"PrivateIpAddress": ip.privateIpAddress, "AutoAssign" : false, "Primary" : ip.primary}

        for group in aws_eni.groupSet
          eniRes.GroupSet.push
            "GroupId": CREATE_REF(@sgs[ group.groupId ], 'resource.GroupId')
            "GroupName": CREATE_REF(@sgs[ group.groupId ], 'resource.GroupName')

        eniComp = @add( "ENI", eniRes, TAG_NAME(aws_eni) )
        @enis[ aws_eni.id ] = eniComp
        #add external or unattached ENI to layout
        if not aws_eni.attachment or not ( aws_eni.attachment.deviceIndex in [ "0", 0 ] )
          @addLayout( eniComp, false, subnetComp )
      return


    ()-> #EIP
      for aws_eip in @getResourceByType "EIP"
        aws_eip = aws_eip.attributes

        eni = @enis[ aws_eip.networkInterfaceId ]
        if not eni
          continue

        eipRes =
          "AllocationId": aws_eip.id
          "Domain": aws_eip.domain
          "InstanceId": "" #aws_eip.instanceId
          "NetworkInterfaceId": CREATE_REF( eni, "resource.NetworkInterfaceId" )
          "PrivateIpAddress": ""
          "PublicIp": aws_eip.publicIp

        idx = 0
        for ip in eni.resource.PrivateIpAddressSet
          if ip.PrivateIpAddress is aws_eip.privateIpAddress
            eipRes.PrivateIpAddress = CREATE_REF( eni, "resource.PrivateIpAddressSet.#{idx}.PrivateIpAddress" )
          idx++

        eipComp = @add( "EIP", eipRes )
      return



    ()-> # Rtbs
      for aws_rtb in @getResourceByType("RT") || []
        aws_rtb = aws_rtb.attributes
        rtbRes =
          "AssociationSet" : []
          "PropagatingVgwSet" : []
          "RouteSet"       : []
          "RouteTableId"   : aws_rtb.id
          "VpcId"          : CREATE_REF( @theVpc, 'resource.VpcId' )

        #associationSet
        for i in aws_rtb.associationSet
          asso =
            Main : if i.main is false then false else "true"
            RouteTableAssociationId : ""
            SubnetId : ""
          if not asso.Main
            asso.RouteTableAssociationId = i.routeTableAssociationId
            subnetComp = @subnets[i.subnetId]
            if i.subnetId and subnetComp
              asso.SubnetId = CREATE_REF( subnetComp, 'resource.SubnetId' )
          rtbRes.AssociationSet.push asso

        #routeSet
        xgw_in_route = {}
        for i in aws_rtb.routeSet
          if i.state isnt "active"
            continue
          if i.origin and i.origin is "EnableVgwRoutePropagation"
            continue
          insComp = @instances[i.instanceId]
          eniComp = @enis[i.networkInterfaceId]
          gwComp  = @gateways[i.gatewayId]
          route =
            "DestinationCidrBlock" : i.destinationCidrBlock
            "GatewayId"      : ""
            "InstanceId"     : ""
            "NetworkInterfaceId" : if i.networkInterfaceId and eniComp then CREATE_REF( eniComp, 'resource.NetworkInterfaceId' ) else ""
            "Origin"         : if i.gatewayId is "local" then i.origin else ""
          if i.gatewayId
            xgw_in_route[i.gatewayId] = true
            if i.gatewayId isnt "local" and gwComp
              if gwComp.type is "AWS.VPC.VPNGateway"
                route.GatewayId = CREATE_REF( gwComp, 'resource.VpnGatewayId' )
              else if gwComp.type is "AWS.VPC.InternetGateway"
                route.GatewayId = CREATE_REF( gwComp, 'resource.InternetGatewayId' )
            else
              route.GatewayId = i.gatewayId
          rtbRes.RouteSet.push route

        #propagatingVgwSet
        for i in aws_rtb.propagatingVgwSet
          gwComp = @gateways[i.gatewayId]
          if gwComp and xgw_in_route[i.gatewayId]
            rtbRes.PropagatingVgwSet.push CREATE_REF(gwComp, 'resource.VpnGatewayId' )

        rtbComp = @add( "RT", rtbRes, TAG_NAME(aws_rtb) )
        @addLayout( rtbComp, true, @theVpc )
      return


    ()-> #ACL
      for aws_acl in @getResourceByType("ACL") || []
        aws_acl    = aws_acl.attributes
        aclRes =
          "AssociationSet": []
          "Default" : false
          "EntrySet": []
          "NetworkAclId": ""
          "VpcId"   : ""
        aclRes = @_mapProperty aws_acl, aclRes

        aclRes.VpcId = CREATE_REF( @theVpc, 'resource.VpcId' )
        aclRes.NetworkAclId = aws_acl.id
        if aws_acl.default
          aclRes.Default = aws_acl.default
          aclName = "DefaultACL"
        else
          aclName = TAG_NAME(aws_acl)

        for acl in aws_acl.entries

          egress = acl.egress
          if _.isString(egress)
            if egress is 'true'
              egress = true
            else
              egress = false

          aclRes.EntrySet.push
            "RuleAction": acl.ruleAction
            "Protocol"  : Number(acl.protocol)
            "CidrBlock" : acl.cidrBlock
            "Egress"    : acl.egress
            "IcmpTypeCode":
              "Type": if acl.icmpTypeCode then String(acl.icmpTypeCode.type) else ""
              "Code": if acl.icmpTypeCode then String(acl.icmpTypeCode.code) else ""
            "PortRange":
              "To"  : if acl.portRange then String(acl.portRange.to) else ""
              "From": if acl.portRange then String(acl.portRange.from) else ""
            "RuleNumber": acl.ruleNumber

        for acl in aws_acl.associationSet
          subnetComp = @subnets[acl.subnetId]
          if not subnetComp
            continue
          aclRes.AssociationSet.push
            "NetworkAclAssociationId": acl.networkAclAssociationId
            "SubnetId": CREATE_REF( subnetComp, 'resource.SubnetId' )

        originComp = @getOriginalComp( aws_acl.id, "ACL" )
        if originComp and originComp.resource.AssociationSet.sort().toString() is aclRes.AssociationSet.sort().toString()
          aclRes.AssociationSet = jQuery.extend(true, [], originComp.resource.AssociationSet)

        aclComp = @add( "ACL", aclRes, aclName )
      return

    ()-> #ELB
      me = @
      for aws_elb in @getResourceByType("ELB") || []
        aws_elb = aws_elb.attributes

        elbRes =
          "HealthCheck":
            "Timeout": "",
            "Target" : ""
            "HealthyThreshold"  : ""
            "UnhealthyThreshold": ""
            "Interval": ""
          "Policies":
            "AppCookieStickinessPolicies": [{
              CookieName: '',
              PolicyName: ''
            }]
            "OtherPolicies"              : []
            "LBCookieStickinessPolicies" : [{
              CookieExpirationPeriod: '',
              PolicyName: ''
            }]
          "BackendServerDescriptions": [{
            InstantPort: ""
            PoliciyNames: ""
          }]
          "SecurityGroups": []
          "CreatedTime"   : ""
          "CanonicalHostedZoneNameID": ""
          "ListenerDescriptions"     : []
          "DNSName": ""
          "Scheme" : ""
          "CanonicalHostedZoneName": ""
          "Instances": []
          "SourceSecurityGroup":
            "OwnerAlias": ""
            "GroupName" : ""
          "Subnets": []
          "VpcId"  : ""
          "LoadBalancerName" : ""
          "AvailabilityZones": []
          "CrossZoneLoadBalancing": ""
          "ConnectionDraining":
            "Enabled" : false
            "Timeout" : null

        elbRes = @_mapProperty aws_elb, elbRes

        originComp = @getOriginalComp(aws_elb.Name, 'ELB')
        elbRes.ConnectionDraining.Enabled = aws_elb.ConnectionDraining.Enabled
        if originComp
          elbRes.ConnectionDraining.Timeout = originComp.resource.ConnectionDraining.Timeout
        else
          elbRes.ConnectionDraining.Timeout = Number(aws_elb.ConnectionDraining.Timeout) if aws_elb.ConnectionDraining.Enabled

        delete elbRes.CanonicalHostedZoneName if elbRes.CanonicalHostedZoneName
        delete elbRes.CanonicalHostedZoneNameID if elbRes.CanonicalHostedZoneNameID

        if aws_elb.SecurityGroups
          for sgId in aws_elb.SecurityGroups
            elbRes.SecurityGroups.push CREATE_REF( @sgs[sgId], 'resource.GroupId' )

        elbRes.VpcId = CREATE_REF( @theVpc, 'resource.VpcId' )
        if aws_elb.Subnets
          for subnetId in aws_elb.Subnets
            elbRes.Subnets.push CREATE_REF( @subnets[subnetId], 'resource.SubnetId')

        # if aws_elb.AvailabilityZones
        #   for az in aws_elb.AvailabilityZones
        #     azComp = @addAz(sb.availabilityZone)
        #     elbRes.AvailabilityZones.push CREATE_REF( azComp )

        elbRes.DNSName = aws_elb.Dnsname
        elbRes.CrossZoneLoadBalancing = aws_elb.CrossZoneLoadBalancing.Enabled

        if aws_elb.ListenerDescriptions
          for listener in aws_elb.ListenerDescriptions
            sslCertRef = ''

            # add ServerCertificate component
            if listener.Listener.SslcertificateId
              iamComp = @addIAM( listener.Listener.SslcertificateId )
              if iamComp
                sslCertRef = CREATE_REF(iamComp, 'resource.ServerCertificateMetadata.Arn')

            data =
              "PolicyNames": ''
              "Listener":
                "LoadBalancerPort": listener.Listener.LoadBalancerPort
                "InstanceProtocol": listener.Listener.InstanceProtocol
                "Protocol"        : listener.Listener.Protocol
                "SSLCertificateId": sslCertRef || listener.Listener.SslcertificateId
                "InstancePort"    : listener.Listener.InstancePort
            elbRes.ListenerDescriptions.push data

        elbRes.HealthCheck = aws_elb.HealthCheck
        # elbRes.ListenerDescriptions = aws_elb.ListenerDescriptions

        if aws_elb.Instances
          for instanceId in aws_elb.Instances
            #skip instances in asg
            if not (instanceId in me.ins_in_asg)
              if @instances[ instanceId ]
                elbRes.Instances.push {
                  InstanceId: CREATE_REF( @instances[ instanceId ], 'resource.InstanceId' )
                }


        elbComp = @add( "ELB", elbRes, aws_elb.Name )
        @addLayout( elbComp, false, @theVpc )
        @elbs[ aws_elb.Name ] = elbComp
      return


    ()-> #LC
      me = @
      for aws_lc in @getResourceByType 'LC'
        aws_lc = aws_lc.attributes
        lcRes =
          "AssociatePublicIpAddress": false
          "BlockDeviceMapping"      :[]
          # 0: Object
          #   DeviceName: "/dev/sda1"
          #   Ebs:
          #     SnapshotId: "snap-ef432332"
          #     VolumeSize: 8
          #     VolumeType: "standard"
          "EbsOptimized"      : false
          "ImageId"           : ""
          "InstanceMonitoring": false
          "InstanceType"      : ""
          "KeyName"           : "" #"@{uid.resource.KeyName}"
          "LaunchConfigurationARN" : "" #"arn:aws:autoscaling:us-east-1:994554139310:launchConfiguration:20c7629d-a192-42b3-9b7a-f319ec648b9a:launchConfigurationName/launch-config-0---app-aae6fe2f"
          "LaunchConfigurationName": "" #"launch-config-0---app-aae6fe2f"
          "SecurityGroups"    : []
          #0: "@{uid.resource.GroupId}"
          "UserData" : ""

        lcRes = @_mapProperty aws_lc, lcRes

        lcRes.LaunchConfigurationARN  = aws_lc.id
        lcRes.LaunchConfigurationName = aws_lc.Name
        lcRes.InstanceMonitoring      = aws_lc.InstanceMonitoring.Enabled
        lcRes.UserData                = ""

        #convert SecurityGroups to REF
        sg = []
        _.each aws_lc.SecurityGroups, (e,key)->
          sgComp = me.sgs[ e ]
          if sgComp
            sg.push CREATE_REF( sgComp, "resource.GroupId" )

        if sg.length is 0
          #sg of LC is not in current VPC, means this lc is not in this VPC
          continue

        lcRes.SecurityGroups = sg

        #generate BlockDeviceMapping
        bdm = lcRes.BlockDeviceMapping
        _.each aws_lc.BlockDeviceMapping || [], (e,key)->
          if e.Ebs is null and e.VirtualName
            #instance-store, ignore
            data =
              "DeviceName" : e.DeviceName
              "Ebs"        : null
              "NoDevice"   : e.NoDevice
              "VirtualName": e.VirtualName
          else
            #ebs
            data =
              "DeviceName": e.DeviceName
              "Ebs":
                "VolumeSize": if e.Ebs then Number(e.Ebs.VolumeSize) else 0
                "VolumeType": if e.Elb then e.Ebs.VolumeType else ""
            if e.Ebs
              if e.Ebs.SnapshotId
                data.Ebs.SnapshotId = e.Ebs.SnapshotId
              if data.Ebs.VolumeType is "io1"
                data.Ebs.Iops = e.Ebs.Iops
            bdm.push data

        #generate KeyName for lc
        keyPairComp = @getOriginalComp(aws_lc.KeyName, 'KP')
        if not keyPairComp
          lcRes.KeyName = aws_lc.KeyName if aws_lc.KeyName
        else
          originComp = @getOriginalComp(aws_lc.id, 'LC')
          if originComp
            lcRes.KeyName = originComp.resource.KeyName
          else
            lcRes.KeyName = CREATE_REF( keyPairComp, "resource.KeyName" )

        lcComp = @add( "LC", lcRes, aws_lc.Name )
        @addLayout lcComp
        delete @component[ aws_lc.id ]
        @lcs[ aws_lc.Name ] = lcComp
      return


    ()-> #ASG
      me = @
      for aws_asg in @getResourceByType "ASG"

        aws_asg = aws_asg.attributes

        if not @lcs[aws_asg.LaunchConfigurationName]
          continue

        asgRes =
          "AutoScalingGroupARN" : ""
          "AutoScalingGroupName": ""
          "AvailabilityZones"   : []
            # 0: "@{uid.resource.ZoneName}"
            # 1: "@{uid.resource.ZoneName}"
          "DefaultCooldown"        : "0"
          "DesiredCapacity"        : "0"
          "HealthCheckGracePeriod" : "0"
          "HealthCheckType"        : ""
          "LaunchConfigurationName": "" #"@{uid.resource.LaunchConfigurationName}"
          "LoadBalancerNames"      : []
            #0: "@{uid.resource.LoadBalancerName}"
            #1: "@{uid.resource.LoadBalancerName}"
          "MaxSize": "0"
          "MinSize": "0"
          "TerminationPolicies": []
            #0: "Default"
          "VPCZoneIdentifier": "" #"@{uid.resource.SubnetId} , @{uid.resource.SubnetId}"

        asgRes = @_mapProperty aws_asg, asgRes

        originASGComp = @getOriginalComp(aws_asg.id, 'ASG')

        asgRes.AutoScalingGroupARN  = aws_asg.id
        asgRes.AutoScalingGroupName = aws_asg.Name
        asgRes.TerminationPolicies  = aws_asg.TerminationPolicies

        #convert LaunchConfigurationName to REF
        asgRes.LaunchConfigurationName = CREATE_REF( @lcs[ aws_asg.LaunchConfigurationName ], "resource.LaunchConfigurationName" )

        #convert VPCZoneIdentifier to REF
        vpcZoneIdentifier = []
        _.each aws_asg.Subnets, (e,key)->
          subnetComp = me.subnets[e]
          if subnetComp
            vpcZoneIdentifier.push CREATE_REF( subnetComp, "resource.SubnetId" )
        if vpcZoneIdentifier.length is 0
          #asg is not in current VPC
          continue
        asgRes.VPCZoneIdentifier = vpcZoneIdentifier.join( " , " )

        #convert ELB to REF
        elb = []
        _.each aws_asg.LoadBalancerNames, (e,key)->
          elbComp = me.elbs[e]
          elb.push CREATE_REF( elbComp, "resource.LoadBalancerName" )
        asgRes.LoadBalancerNames = elb

        #convert AZ to REF
        az = []
        _.each aws_asg.AvailabilityZones, (e,key)->
          azComp = me.addAz( e )
          az.push CREATE_REF( azComp, "resource.ZoneName" )
        asgRes.AvailabilityZones = az

        asgComp = @add( "ASG", asgRes, TAG_NAME(aws_asg) or aws_asg.Name )

        origSubnetComp = ""
        origSubnetLayout = @originalJson.layout[asgComp.uid]
        addOriginal = false
        _.each aws_asg.Subnets, (e,key)->
          subnetComp = me.subnets[e]
          if (not addOriginal) and ( (origSubnetLayout and origSubnetLayout.groupUId is subnetComp.uid) or (not origSubnetLayout) )
            #add original ASG layout
            me.addLayout asgComp, true, subnetComp
            addOriginal = true
          else
            #add ExpandAsg layout
            me.addExpandedAsg asgComp,subnetComp

        @asgs[ aws_asg.Name ] = asgComp
      return

    ()-> #NC
      for aws_nc in @getResourceByType( "NC" )
        aws_nc = aws_nc.attributes
        ncRes =
          "AutoScalingGroupName": aws_nc.AutoScalingGroupName
          "NotificationType": aws_nc.NotificationType
          "TopicARN": aws_nc.TopicARN

        #convert AutoScalingGroupName to REF
        asgComp = @asgs[ncRes.AutoScalingGroupName]
        if asgComp
          ncRes.AutoScalingGroupName = CREATE_REF( asgComp, 'resource.AutoScalingGroupName' )
        else
          continue

        #found original Topic component
        topicComp = _.first _.filter @originalJson.component, ( com ) ->
          if com.type is constant.RESTYPE.TOPIC
            return com.resource.TopicArn is ncRes.TopicARN
        if topicComp
          #ref existed topic
          ncRes.TopicARN = CREATE_REF( topicComp, 'resource.TopicArn' )
        else
          #add new Topic
          topicComp = @addTopic( ncRes.TopicARN )
          if topicComp
            ncRes.TopicARN = CREATE_REF( topicComp, 'resource.TopicArn' )

        ncComp = @add( "NC", ncRes, "SnsNotification")
      return

    ()-> #SP
      for aws_sp in @getResourceByType( "SP" )
        aws_sp = aws_sp.attributes
        spRes =
          "AdjustmentType"      : "" #"ChangeInCapacity"
          "AutoScalingGroupName": "" #"@{uid.resource.AutoScalingGroupName}"
          "Cooldown"  : 0
          "MinAdjustmentStep": ""
          "PolicyARN" : "" #"arn:aws:autoscaling:us-east-1:994554139310:scalingPolicy:69df7c02-ed5f-42cf-870a-d649206cb169:autoScalingGroupName/asg0---app-aae6fe2f:policyName/asg0-policy-0"
          "PolicyName": "" #"asg0-policy-0"
          "ScalingAdjustment" : ""

        spRes = @_mapProperty aws_sp, spRes

        #convert AutoScalingGroupName to REF
        asgComp = @asgs[aws_sp.AutoScalingGroupName]

        spRes.ScalingAdjustment = String(spRes.ScalingAdjustment) if spRes.ScalingAdjustment

        if asgComp
          spRes.AutoScalingGroupName = CREATE_REF( asgComp, 'resource.AutoScalingGroupName' )
        else
          continue

        spRes.PolicyARN = aws_sp.id
        spRes.PolicyName = aws_sp.Name
        spComp = @add( "SP", spRes, aws_sp.Name )
        @sps[ aws_sp.id ] = spComp
      return

    ()-> #CW
      me = @
      for aws_cw in @getResourceByType( "CW" )
        aws_cw = aws_cw.attributes
        cwRes =
          "AlarmActions": []
            # 0: "@{8634BFD3-6E51-4231-BF38-BD310D4A4925.resource.PolicyARN}"
            # 1: "@{52ADA7AD-8486-49E8-A959-5A427B2D6113.resource.TopicArn}"
          "AlarmArn" : "" #"arn:aws:cloudwatch:us-east-1:994554139310:alarm:asg0-policy-0-alarm---app-aae6fe2f"
          "AlarmName": "" #"asg0-policy-0-alarm---app-aae6fe2f"
          "ComparisonOperator": ""
          "Dimensions": []
             # 0:
              # "name" : "AutoScalingGroupName"
              # "value": "" #"@{uid.resource.AutoScalingGroupName}"
          "EvaluationPeriods"      : ""
          "InsufficientDataActions": []
          "MetricName": "" #"CPUUtilization"
          "Namespace" : "" #"AWS/AutoScaling"
          "OKAction"  : []
          "Period"    : 0
          "Statistic" : "" #"Average"
          "Threshold" : ""
          "Unit"      : ""

        cwRes = @_mapProperty aws_cw, cwRes

        dimension = []
        _.each aws_cw.Dimensions, (e,key)->
          if e.Name is "AutoScalingGroupName"
            asgComp = me.asgs[ e.Value ]
            if asgComp
              data =
                "name" : e.Name
                "value": CREATE_REF( asgComp, "resource.AutoScalingGroupName" )
              dimension.push data
        if dimension.length is 0
          #CW is not for asg in current VPC
          continue
        cwRes.Dimensions = dimension

        reg_sp    = /arn:aws:autoscaling:.*:scalingPolicy:/g
        reg_topic = /arn:aws:sns:.*:.*/g


        #get valid alarmAction
        validAlarmAction = []
        hasSP = false
        _.each aws_cw.AlarmActions, (e,key)->
          if e.match(reg_topic)
            #TOPIC
            topicComp = me.addTopic(e)
            if topicComp
              validAlarmAction.push e
          else if e.match(reg_sp)
            #SP
            spComp = me.sps[e]
            if spComp
              hasSP = true
              validAlarmAction.push e

        if not hasSP
          #must has SP when convert CW, currently one CW has One SP
          continue

        #convert AlarmActions to REF:
        alarmActionAry = []
        _.each validAlarmAction, (e,key)->
          if e.match(reg_topic)
            #TOPIC
            topicComp = me.addTopic(e)
            if topicComp
              alarmActionAry.push CREATE_REF(topicComp, "resource.TopicArn")
          else if e.match(reg_sp)
            #SP
            spComp = me.sps[e]
            if spComp
              alarmActionAry.push CREATE_REF(spComp, "resource.PolicyARN")

        cwRes.AlarmActions = alarmActionAry

        #convert OKAction to REF:
        okActionAry = []
        _.each aws_cw.Okactions, (e,key)->
          if e.match(reg_sp)
            spComp = me.sps[e]
            if spComp
              okActionAry.push CREATE_REF(spComp, "resource.PolicyARN")
        cwRes.OKAction = okActionAry

        cwRes.Threshold = String(aws_cw.Threshold)
        cwRes.EvaluationPeriods = String(aws_cw.EvaluationPeriods)
        if aws_cw.ComparisonOperator
          cwRes.ComparisonOperator = @COMPARISONOPERATOR[ aws_cw.ComparisonOperator ]

        cwRes.AlarmArn  = aws_cw.id
        cwRes.AlarmName = aws_cw.Name

        cwComp = @add( "CW", cwRes, aws_cw.Name )
      return

    ()-> #RDS OptionGroup
      for aws_og in @getResourceByType( "DBOG" )
        aws_og = aws_og.attributes
        if aws_og.OptionGroupName.indexOf("default:") is 0
          console.warn "skip default OptionGroup #{aws_og.OptionGroupName}"
          continue

        ogRes =
          "CreatedBy"   : ""
          "EngineName"  : ""
          "MajorEngineVersion"    : ""
          "OptionGroupDescription": ""
          "OptionGroupName" : ""
          "Options": []
          "VpcId": "" #"@{uid.resource.VpcId}"

        ogRes = @_mapProperty aws_og, ogRes
        ogRes.OptionGroupName = aws_og.id

        #ref to VpcId
        ogRes.VpcId = CREATE_REF( @theVpc, "resource.VpcId" )

        #options(different by different ParameterGroupFamily)
        for op in aws_og.Options || []
          op_item = @_mapProperty op, { "OptionName":"", "OptionSettings":[], "Port":"", "VpcSecurityGroupMemberships":[] }
          op_item.Port = if op_item.Port then op_item.Port.toString() else ""
          #resolve OptionSettings
          for set in op.OptionSettings
            set_item = @_mapProperty set, { "Name":"", "Value":"" }
            op_item.OptionSettings.push set_item
          #resolve SG
          for sg in op.VpcSecurityGroupMemberships
            sgComp = @sgs[ sg.VpcSecurityGroupId ]
            if sgComp
              op_item.VpcSecurityGroupMemberships.push CREATE_REF sgComp, "resource.GroupId"
            else
              console.error "can not find SG #{sg.VpcSecurityGroupId} for OptionGroup"
          ogRes.Options.push op_item

        # Found an original component
        originComp = @getOriginalComp(aws_og.id, 'DBOG')
        if originComp
          compName = originComp.name
          ogRes.CreatedBy = originComp.resource.CreatedBy
        else
          compName = aws_og.OptionGroupName
          console.error "[temp]can not find original component"

        #generate OptionGroup component
        ogComp = @add( "DBOG", ogRes, compName )
        @ogs[ aws_og.id ] = ogComp
      return

    ()-> #RDS DBSubnetGroup
      for aws_sbg in @getResourceByType( "DBSBG" )
        aws_sbg = aws_sbg.attributes
        sbgRes =
          "CreatedBy"        : "",
          "DBSubnetGroupName": ""
          "SubnetIds"        : [
            # "@{uid.resource.SubnetId}",
            # "@{uid.resource.SubnetId}"
          ]
          "DBSubnetGroupDescription": ""

        sbgRes = @_mapProperty aws_sbg, sbgRes
        sbgRes.DBSubnetGroupName = aws_sbg.id

        for subnet in aws_sbg.Subnets
          subnetComp = @subnets[ subnet.SubnetIdentifier ]
          sbgRes.SubnetIds.push CREATE_REF(subnetComp, "resource.SubnetId")

        # Found an original component
        originComp = @getOriginalComp(aws_sbg.id, 'DBSBG')
        if originComp
          compName = originComp.name
          sbgRes.CreatedBy = originComp.resource.CreatedBy
          if sbgRes.SubnetIds.sort().toString() is originComp.resource.SubnetIds.sort().toString()
            #keep original sequence
            sbgRes.SubnetIds = jQuery.extend(true, [], originComp.resource.SubnetIds)
        else
          compName = aws_sbg.DBSubnetGroupName

        #generate DBSubnetGroup component
        sbgComp = @add( "DBSBG", sbgRes, TAG_NAME(aws_sbg) or compName )
        @addLayout( sbgComp, true, @theVpc )
        @sbgs[ aws_sbg.id ] = sbgComp
      return

    ()-> #RDS DBInstance
      dbinsAry = []
      #sort, DBInstance -> ReadReplica
      for aws_dbins in @getResourceByType( "DBINSTANCE" )
        aws_dbins = aws_dbins.attributes
        if aws_dbins.ReadReplicaSourceDBInstanceIdentifier
          #ReadReplica
          dbinsAry.push aws_dbins
        else
          #DBInstance
          dbinsAry.unshift aws_dbins
      #
      for aws_dbins in dbinsAry
        subnetComp = @sbgs[aws_dbins.sbgId]
        if not subnetComp
          console.warn "can not found subnet of DBInstance"
          continue

        #dbsubnetgroup
        sbgComp = @sbgs[ aws_dbins.DBSubnetGroup.DBSubnetGroupName ]
        if not sbgComp
          console.warn "can not found DBSubnetGroup of DBInstance"
          continue

        dbInsRes =
          "CreatedBy"              : ""
          "DBInstanceIdentifier"   : ""
          "DBSnapshotIdentifier"   : ""
          "AllocatedStorage"       : 0
          "AutoMinorVersionUpgrade": false
          "AvailabilityZone"       : ""
          "MultiAZ"                : false
          "Iops"                   : ""
          "BackupRetentionPeriod"  : 0
          "CharacterSetName"       : ""
          "DBInstanceClass"        : ""
          "DBName"  : ""
          "Endpoint":
            "Port"     : 0
            "Address"  : ""
          "Engine"            : ""
          "EngineVersion"     : ""
          "LicenseModel"      : ""
          "MasterUsername"    : ""
          "MasterUserPassword": ""
          "OptionGroupMembership":
            "OptionGroupName"       : ""
          "DBParameterGroups"    :
            "DBParameterGroupName"  : ""
          "PendingModifiedValues": ""
          "PreferredBackupWindow": ""
          "PreferredMaintenanceWindow": ""
          "PubliclyAccessible": false
          "DBSubnetGroup":
            "DBSubnetGroupName": "" #"@{uid.resource.DBSubnetGroupName}"
          "VpcSecurityGroupIds": [
            #"@{uid.resource.GroupId}"
          ]

        dbInsRes = @_mapProperty aws_dbins, dbInsRes

        #clear AZ when MultiAZ is true
        if dbInsRes.MultiAZ
          dbInsRes.AvailabilityZone = ""

        dbInsRes.AllocatedStorage = Number(aws_dbins.AllocatedStorage)
        dbInsRes.BackupRetentionPeriod = Number(aws_dbins.BackupRetentionPeriod)

        if aws_dbins.ReadReplicaSourceDBInstanceIdentifier
          #ReadReplica
          srcDbInsComp = @dbinstances[ aws_dbins.ReadReplicaSourceDBInstanceIdentifier ]
          if srcDbInsComp
            dbInsRes.ReadReplicaSourceDBInstanceIdentifier = CREATE_REF srcDbInsComp, "resource.DBInstanceIdentifier"
          else
            console.error "can not find Source DBInstance for ReadReplica #{aws_dbins.ReadReplicaSourceDBInstanceIdentifier}"        

        #endpoint
        if aws_dbins.Endpoint
          dbInsRes.Endpoint.Address = aws_dbins.Endpoint.Address
          dbInsRes.Endpoint.Port = aws_dbins.Endpoint.Port

        #ref to OptionGroupMembership
        if aws_dbins.OptionGroupMemberships[0]
          ogComp = @ogs[ aws_dbins.OptionGroupMemberships[0].OptionGroupName ]
          if ogComp
            dbInsRes.OptionGroupMembership.OptionGroupName = CREATE_REF ogComp, "resource.OptionGroupName"
          else
            #if no component, then use OptionGroupName
            dbInsRes.OptionGroupMembership.OptionGroupName = aws_dbins.OptionGroupMemberships[0].OptionGroupName
            if aws_dbins.OptionGroupMemberships[0].OptionGroupName.indexOf("default:") isnt 0
              console.warn "can not find OptionGroup #{ aws_dbins.OptionGroupMemberships[0].OptionGroupName } for DBInstance"

        #DBParameterGroups(Share resource)
        if aws_dbins.DBParameterGroups[0]
          dbInsRes.DBParameterGroups.DBParameterGroupName = aws_dbins.DBParameterGroups[0].DBParameterGroupName

        #ref to DBSubnetGroup
        dbInsRes.DBSubnetGroup.DBSubnetGroupName = CREATE_REF sbgComp, "resource.DBSubnetGroupName"

        #ref to SecurityGroups
        for sg in aws_dbins.VpcSecurityGroups
          sgComp = @sgs[ sg.VpcSecurityGroupId ]
          if sgComp
            dbInsRes.VpcSecurityGroupIds.push CREATE_REF sgComp, "resource.GroupId"
          else
            console.warn "can not found component for SG " + sg.VpcSecurityGroupId

        # Found an original component
        originComp = @getOriginalComp(aws_dbins.id, 'DBINSTANCE')
        if originComp
          compName = originComp.name
          dbInsRes.CreatedBy     = originComp.resource.CreatedBy
          if not aws_dbins.Endpoint
            dbInsRes.Endpoint.Port = originComp.resource.Endpoint.Port
        else
          compName = aws_dbins.Name || aws_dbins.DBInstanceIdentifier

        #generate DBSubnetGroup component
        dbInsComp = @add( "DBINSTANCE", dbInsRes, TAG_NAME(aws_dbins) or compName )
        @addLayout( dbInsComp, false, subnetComp )
        @dbinstances[ aws_dbins.id ] = dbInsComp
      return
  ]


  processServerGroup = (cd) ->

    diffTree = new DiffTree()
    originComps = cd.originAppJSON.component
    newComps = cd.component

    getRelatedInstanceGroupUID = (comp) ->
      resType = comp.type
      if resType is constant.RESTYPE.INSTANCE
        return comp.serverGroupUid
      if resType is constant.RESTYPE.ENI
        instanceRef = comp.resource.Attachment.InstanceId
        if instanceRef
          instanceUID = MC.extractID(instanceRef)
          instanceComp = originComps[instanceUID]
          if instanceComp
            return instanceComp.serverGroupUid
        else
          serverGroupUid = comp.serverGroupUid
          if serverGroupUid isnt comp.uid
            eniComp = originComps[serverGroupUid]
            if eniComp
              return getRelatedInstanceGroupUID(eniComp)

      if resType is constant.RESTYPE.VOL
        instanceRef = comp.resource.AttachmentSet.InstanceId
        if instanceRef
          instanceUID = MC.extractID(instanceRef)
          instanceComp = originComps[instanceUID]
          if instanceComp
            return instanceComp.serverGroupUid
      if resType is constant.RESTYPE.EIP
        eniRef = comp.resource.NetworkInterfaceId
        if eniRef
          eniUID = MC.extractID(eniRef)
          eniComp = originComps[eniUID]
          if eniComp
            return getRelatedInstanceGroupUID(eniComp)
      return ''

    # find all server group related res
    originServerGroupComps = {}
    _.each originComps, (comp) ->
      if comp.number and comp.number > 1
        originServerGroupComps[comp.uid] = comp

    newServerGroupComps = {}
    _.each newComps, (comp) ->
      if originServerGroupComps[comp.uid]
        newServerGroupComps[comp.uid] = comp
      null

    # diff if have any change for server group
    diffRet = diffTree.compare originServerGroupComps, newServerGroupComps

    # break up all related server group res
    if diffRet
      _.each diffRet, (comp, uid) ->
        newCompObj = newServerGroupComps[uid]
        if newCompObj
          serverGroupUID = getRelatedInstanceGroupUID(newCompObj)
          if serverGroupUID
            _.each newServerGroupComps, (newComp) ->
              if getRelatedInstanceGroupUID(newComp) is serverGroupUID
                newComp.serverGroupName = newComp.name if newComp.serverGroupName
                newComp.number = 1 if newComp.number
                newComp.index = 0 if newComp.index
                newComp.serverGroupUid = newComp.uid if newComp.serverGroupUid

    # process elb connected instance server group
    _.each cd.elbs, (insComp) ->
      instanceAry = _.map insComp.resource.Instances, (refObj) ->
        return MC.extractID(refObj.InstanceId)
      originComp = originComps[insComp.uid]
      if originComp
        originInstanceAry = _.map originComp.resource.Instances, (refObj) ->
          return MC.extractID(refObj.InstanceId)
        diffElbInstance = diffTree.compare instanceAry, originInstanceAry
        if diffElbInstance
          diffInstanceAry = []
          _.each diffElbInstance, (comp) ->
            diffInstanceAry.push(comp.__old__) if comp.__old__
            diffInstanceAry.push(comp.__new__) if comp.__new__
            null
          _.each diffInstanceAry, (instanceUID) ->
            serverGroupInstanceComp = newServerGroupComps[instanceUID]
            if serverGroupInstanceComp
              serverGroupUID = serverGroupInstanceComp.serverGroupUid
              _.each newServerGroupComps, (comp, uid) ->
                _serverGroupUID = getRelatedInstanceGroupUID(comp)
                if _serverGroupUID is serverGroupUID
                  comp.serverGroupName = comp.name if comp.serverGroupName
                  comp.number = 1 if comp.number
                  comp.index = 0 if comp.index
                  comp.serverGroupUid = comp.uid if comp.serverGroupUid

    # process added/removed related res for instance server group
    newAddRemoveComps = {}
    oldAddRemoveComps = {}
    _.each newComps, (insComp) ->
      if insComp.type in [constant.RESTYPE.ENI, constant.RESTYPE.EIP, constant.RESTYPE.INSTANCE, constant.RESTYPE.VOL]
        newAddRemoveComps[insComp.uid] = insComp if not originComps[insComp.uid]
    _.each originComps, (insComp) ->
      if insComp.type in [constant.RESTYPE.ENI, constant.RESTYPE.EIP, constant.RESTYPE.INSTANCE, constant.RESTYPE.VOL]
        oldAddRemoveComps[insComp.uid] = insComp if not newComps[insComp.uid]
      null

    addRemoveDiffRet = diffTree.compare newAddRemoveComps, oldAddRemoveComps

    diffInstanceAry = []
    if addRemoveDiffRet
      _.each addRemoveDiffRet, (comp, uid) ->
        serverGroupInstanceComp = newComps[uid] or originComps[uid]
        serverGroupUID = getRelatedInstanceGroupUID(serverGroupInstanceComp)
        _.each newComps, (comp, uid) ->
          _serverGroupUID = getRelatedInstanceGroupUID(comp)
          if _serverGroupUID is serverGroupUID
            comp.serverGroupName = comp.name if comp.serverGroupName
            comp.number = 1 if comp.number
            comp.index = 0 if comp.index
            comp.serverGroupUid = comp.uid if comp.serverGroupUid

  convertResToJson = ( region, vpcId, originalJson )->
    console.log [
      "VOL"
      "INSTANCE"
      "SG"
      "ELB"
      "ACL"
      "CGW"
      "ENI"
      "IGW"
      "RT"
      "SUBNET"
      "VPC"
      "VPN"
      "VGW"
      "ASG"
      "LC"
      "NC"
      "SP"
      "IAM"
      "RETAIN"
    ].map (t)-> CloudResources( constant.RESTYPE[t], region )

    cd = new ConverterData( region, vpcId, originalJson )
    func.call( cd ) for func in Converters

    # process for server group when visualize vpc

    if cd.originAppJSON

      try
        processServerGroup(cd)
      catch err
        console.info('Server Group process exception when convert app json')

    cd

  __createRequestParam = ( region, vpcId )->
    RESTYPE = constant.RESTYPE
    # Creates a parameter that can be used to fetch additional resources.
    filter = { filter : {'vpc-id':vpcId} }
    additionalRequestParam =
      'AWS.EC2.SecurityGroup'    : filter
      'AWS.VPC.NetworkAcl'       : filter
      'AWS.VPC.NetworkInterface' : filter

    subnetIdsInVpc = {}
    for sb in CloudResources( RESTYPE.SUBNET, region ).where({vpcId:vpcId})
      subnetIdsInVpc[ sb.id ] = true

    asgNamesInVpc = []
    lcNamesInVpc  = []
    for asg in CloudResources( RESTYPE.ASG, region ).models
      if subnetIdsInVpc[ asg.get("VPCZoneIdentifier") ]
        asgNamesInVpc.push asg.get("AutoScalingGroupName")
        lcNamesInVpc.push  asg.get("LaunchConfigurationName")

    if asgNamesInVpc.length
      additionalRequestParam[ RESTYPE.LC ] = { id : _.uniq(lcNamesInVpc) }
      additionalRequestParam[ RESTYPE.NC ] = { id : asgNamesInVpc }
      additionalRequestParam[ RESTYPE.SP ] = { filter : {AutoScalingGroupName:asgNamesInVpc} }

    additionalRequestParam

  CloudResources.getAllResourcesForVpc = convertResToJson
  return
