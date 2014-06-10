
define ["CloudResources", "ide/cloudres/CrCollection", "constant", "ApiRequest"], ( CloudResources, CrCollection, constant, ApiRequest )->

  # Helpers
  CREATE_REF = ( comp )-> "@{#{comp.uid}.r.p}"
  UID        = MC.guid
  DEFAULT_SG = {}
  NAME       = ( res_attributes )->
    if res_attributes.tagSet
      name = res_attributes.tagSet.name || res_attributes.tagSet.Name
    name || res_attributes.id


  # Class used to collect components / layouts
  class ConverterData
    CrPartials : ( type )-> CloudResources( constant.RESTYPE[type], @region )

    constructor : ( region, vpcId )->
      # @theVpc  = null
      @region    = region
      @vpcId     = vpcId
      @azs       = {}
      @subnets   = {} # res id => comp
      @instances = {} # res id => comp
      @enis      = {} # res id => comp
      @gateways  = {} # res id => comp
      @component = {}
      @layout    = {}

    add : ( type_string, res_attributes, component_resources, default_name )->
      if not res_attributes and not default_name
        console.error "[ConverterData.add] if res_attributes is null, then must specify default_name"
        return null
      comp =
        uid  : UID()
        name : if default_name then default_name else NAME( res_attributes )
        type : constant.RESTYPE[ type_string ]
        resource : component_resources
      @component[ comp.uid ] = comp
      comp

    addLayout : ( component, isGroupLayout, parentComp )->
      l =
        uid : component.uid
        coordinate : [0,0]

      if isGroupLayout then l.size = [0,0]
      if parentComp    then l.groupUId = parentComp.uid

      @layout[ l.uid ] = l
      return

    addAz : ( azName )->
      az = @azs[ azName ]
      if az then return az
      az = @add( "AZ", { id : azName }, undefined )
      @addLayout( az, true, @theVpc )
      @azs[ azName ] = az
      az

    _mapProperty : ( aws_json, madeira_json ) ->
      for k, v of aws_json
        if typeof(v) is "string" and madeira_json.resource[k[0].toUpperCase() + k.slice(1)] isnt undefined
          madeira_json.resource[k[0].toUpperCase() + k.slice(1)] = v
      madeira_json

  # The order of Converters functions are important!
  # Some converter must be behind other converters.
  Converters = [
    ()-> # Vpc & Dhcp
      vpc = @CrPartials( "VPC" ).get( @vpcId ).attributes
      if vpc.dhcpOptionsId
        dhcp = @add("DHCP", { id : "DhcpOption" }, {
          DhcpOptionsId : vpc.dhcpOptionsId
        })

      # Cache the vpc so that other can use it.
      @theVpc = vpcComp = @add("VPC", vpc, {
        CidrBlock       : vpc.cidrBlock
        DhcpOptionsId   : if dhcp then CREATE_REF(dhcp) else ""
        InstanceTenancy : vpc.instanceTenancy
        VpcId           : vpc.id
        # EnableDnsHostnames : false # TODO :
        # EnableDnsSupport   : true  # TODO :
      })

      @addLayout( vpcComp, true )
      return


    ()-> # Subnets
      for sb, idx in @CrPartials( "SUBNET" ).where({vpcId:@vpcId}) || []
        sb = sb.attributes
        azComp = @addAz(sb.availabilityZone)
        sbComp = @add( "SUBNET", sb, {
          AvailabilityZone : CREATE_REF( azComp )
          CidrBlock        : sb.cidrBlock
          SubnetId         : sb.id
          VpcId            : CREATE_REF( @theVpc )
        })

        @subnets[ sb.id ] = sbComp

        @addLayout( sbComp, true, azComp )
      return


    ()-> # IGW
      for aws_igw in @CrPartials( "IGW" ).where({vpcId:@vpcId}) || []
        aws_igw = aws_igw.attributes
        if aws_igw.attachmentSet and aws_igw.attachmentSet.length > 0
          igwAttach = aws_igw.attachmentSet[0]
        igwRes =
          "resource":
            "InternetGatewayId": aws_igw.id
            "AttachmentSet": [
              "VpcId": if igwAttach then igwAttach.vpcId else ""
              "State": if igwAttach then igwAttach.state else ""
            ]
        igwComp = @add( "IGW", aws_igw, igwRes, "Internet-gateway" )
        @addLayout( igwComp, true, @theVpc )

        @gateways[ aws_igw.id ] = igwComp
      return


    ()-> # VGW
      for aws_vgw in @CrPartials( "VGW" ).where({vpcId:@vpcId}) || []
        aws_vgw = aws_vgw.attributes
        if aws_vgw.attachments and aws_vgw.attachments.length > 0
          vgwAttach = aws_vgw.attachments[0]
        vgwRes =
          "resource":
            "Attachments": [
              "VpcId": vgwAttach.vpcId
              "State": vgwAttach.state
            ]
            "Type": aws_vgw.type
            #"AvailabilityZone": "",
            "VpnGatewayId": aws_vgw.vpnGatewayId
            "State": aws_vgw.state

        vgwComp = @add( "VGW", aws_vgw, vgwRes, "VPN-gateway" )
        @addLayout( vgwComp, true, @theVpc )

        @gateways[ aws_vgw.id ] = vgwComp
      return


    # getCGW : ()->
    # getVPN : ()->


    ()-> # SG
      for aws_sg in @CrPartials( "SG" ).where({vpcId:@vpcId}) || []
        aws_sg = aws_sg.attributes

        sgRes =
          "resource":
            "IpPermissions": []
            "IpPermissionsEgress": []
            "GroupId": ""
            "Default": false
            "VpcId": ""
            "GroupName": ""
            "OwnerId": ""
            "GroupDescription": ""

        sgRes = @_mapProperty aws_sg, sgRes
        #generate ipPermissions
        if aws_sg.ipPermissions
          for sg_rule in aws_sg.ipPermissions || []
            ipranges = ''
            if sg_rule.groups.length>0 and sg_rule.groups[0].groupId
              ipranges = sg_rule.groups[0].groupId
            else if sg_rule.ipRanges and sg_rule.ipRanges.length>0
              ipranges = sg_rule.ipRanges[0].cidrIp

            if ipranges
              sgRes.resource.IpPermissions.push {
                "IpProtocol": sg_rule.ipProtocol,
                "IpRanges": ipranges,
                "FromPort": if sg_rule.fromPort then sg_rule.fromPort else "",
                "ToPort": if sg_rule.toPort then sg_rule.toPort else ""
              }
        #generate ipPermissionEgress
        if aws_sg.ipPermissionsEgress
          for sg_rule in aws_sg.ipPermissionsEgress || []
            ipranges = ''
            if sg_rule.groups.length>0 and sg_rule.groups[0].groupId
              ipranges = sg_rule.groups[0].groupId
            else if sg_rule.ipRanges and sg_rule.ipRanges.length>0
              ipranges = sg_rule.ipRanges[0].cidrIp

            if ipranges
              sgRes.resource.IpPermissionsEgress.push {
                "IpProtocol": sg_rule.ipProtocol,
                "IpRanges": ipranges,
                "FromPort": if sg_rule.fromPort then sg_rule.fromPort else "",
                "ToPort": if sg_rule.toPort then sg_rule.toPort else ""
              }

        sgComp = @add( "SG", aws_sg, sgRes.resource, aws_sg.groupName )
        if aws_sg.groupName is "default"
          DEFAULT_SG["default"] = sgComp
        else if aws_sg.groupName.indexOf("-DefaultSG-app-") isnt -1
          DEFAULT_SG["DefaultSG"] = sgComp
      return

    ()-> # KP
      kpRes =
        "resource":
          "KeyFingerprint": ""
          "KeyName": "DefaultKP"
      @add( "KP", null, kpRes.resource, 'DefaultKP' )
      return


    ()-> # Instance
      for aws_ins in @CrPartials( "INSTANCE" ).where({vpcId:@vpcId}) || []
        aws_ins = aws_ins.attributes
        azComp = @addAz(aws_ins.placement.availabilityZone)
        insRes =
          "resource":
            "RamdiskId" : ""
            "InstanceId": ""
            "DisableApiTermination": ""
            "ShutdownBehavior": ""
            "SecurityGroupId" : []
            "SecurityGroup"   : []
            "UserData":
              "Base64Encoded": ""
              "Data"         : ""
            "ImageId"  : ""
            "Placement":
              "Tenancy"          : ""
              "AvailabilityZone" : ""
              "GroupName"        : ""
            "BlockDeviceMapping": []
            "KernelId": ""
            "KeyName" : ""
            "SubnetId": ""
            "VpcId"   : ""
            "InstanceType": ""
            "Monitoring"  : ""
            "EbsOptimized": ""
            "NetworkInterface":[]


        # if aws_ins.tagSet
        #   tag = resolveEC2Tag aws_ins.tagSet
        #   if tag.isApp
        #     insRes.name = tag.name
        #   else if tag.Name
        #     insRes.name = tag.Name


        # for group in aws_eni.groupSet.item

        #   eni_json.resource.GroupSet.push
        #     "GroupId": group.groupId,
        #     "GroupName": group.groupName
        #

        insRes = @_mapProperty aws_ins, insRes

        insRes.resource.Subnet = CREATE_REF( @subnets[aws_ins.subnetId] )
        insRes.resource.VpcId  = CREATE_REF( @theVpc )
        insRes.resource.Placement.AvailabilityZone = CREATE_REF( azComp )

        if aws_ins.monitoring and aws_ins.monitoring
          insRes.resource.Monitoring = aws_ins.monitoring.state

        insRes.resource.Placement.Tenancy = aws_ins.placement.tenancy
        insRes.resource.InstanceId        = aws_ins.id
        insRes.resource.EbsOptimized      = aws_ins.ebsOptimized

        # # default_kp
        # if default_kp and default_kp.resource and aws_ins.keyName is default_kp.resource.KeyName
        #   insRes.resource.KeyName = "@{" + default_kp.uid + ".resource.KeyName}"

        insComp = @add( "INSTANCE", aws_ins, insRes.resource )
        @addLayout( insComp, false, @subnets[aws_ins.subnetId] )

        @instances[ aws_ins.id ] = insComp
      return


    ()-> #ENI
      for aws_eni in @CrPartials( "ENI" ).where({vpcId:@vpcId}) || []
        aws_eni = aws_eni.attributes
        azComp = @addAz(aws_eni.availabilityZone)
        eniRes =
          "resource" :
            "AssociatePublicIpAddress" : false
            "PrivateIpAddressSet" : []
            "Status"    : ''
            "GroupSet"  : []
            "PrivateDnsName" : ""
            "SourceDestCheck": true
            "RequestId" : ""
            "MacAddress": ""
            "OwnerId"   : ""
            "RequestManaged"  : ""
            "SecondPriIpCount": ""
            "Attachment":
                "DeviceIndex"  : ""
                "InstanceId"   : ""
            "AvailabilityZone": ""
            "Description": ""
            "SubnetId"   : ""
            "VpcId"      : ""
            "PrivateIpAddress"  : ""
            "NetworkInterfaceId": ""

        if aws_eni.instanceOwnerId and aws_eni.instanceOwnerId in [ "amazon-elb", "amazon-rds" ]
          continue

        eniRes = @_mapProperty aws_eni, eniRes

        #check Automatically assign Public IP
        if aws_eni.association and aws_eni.association.publicIp
          eniRes.resource.AssociatePublicIpAddress = true

        eniRes.resource.AvailabilityZone = CREATE_REF( azComp )
        eniRes.resource.SubnetId         = CREATE_REF( @subnets[aws_eni.subnetId] )
        eniRes.resource.VpcId            = CREATE_REF( @theVpc )
        
        if aws_eni.deviceIndex isnt "0"
          #eni0 no need attachmentId
          eniRes.resource.Attachment.AttachmentId = aws_eni.attachmentId
        eniRes.resource.Attachment.InstanceId = CREATE_REF( @instances[aws_eni.instanceId] )
        eniRes.resource.Attachment.DeviceIndex = aws_eni.deviceIndex

        for ip in aws_eni.privateIpAddressesSet
          eniRes.resource.PrivateIpAddressSet.push {"PrivateIpAddress": ip.privateIpAddress, "AutoAssign" : "false", "Primary" : ip.primary}

        eniRes.resource.GroupSet.push {
          "GroupId": aws_eni.groupId,
          "GroupName": aws_eni.groupName
          }

        eniComp = @add( "ENI", aws_eni, eniRes.resource, "eni" + aws_eni.deviceIndex )
        if aws_eni.deviceIndex isnt "0"
          @addLayout( eniComp, false, @subnets[aws_eni.subnetId] )

        @enis[ aws_eni.id ] = eniComp
      return


    ()-> #Volume
      for aws_vol in @CrPartials( "VOL" ).where({category:@region}) || []
        aws_vol = aws_vol.attributes
        if aws_vol.attachmentSet.length is 0
          continue

        instance = @instances[ aws_vol.attachmentSet[0].instanceId ]
        if not instance
          continue

        azComp = @addAz(aws_vol.availabilityZone)
        volRes =
          "resource":
            "VolumeId"     : aws_vol.id
            "AvailabilityZone": CREATE_REF( azComp )
            "Size"         : Number(aws_vol.size)
            "SnapshotId"   : if aws_vol.snapshotId then aws_vol.snapshotId else ""
            "Iops"         : if aws_vol.iops then aws_vol.iops else ""
            "AttachmentSet":
              "Device"       : aws_vol.attachmentSet[0].device
              "InstanceId"   : CREATE_REF( instance )
            "VolumeType"   : aws_vol.volumeType

        #volRes = @_mapProperty aws_vol, volRes
        #check rootDevice

        # instanceId = aws_vol.attachmentSet.instanceId
        # if res_cache[ instanceId ]
        #   rootDeviceName = @instances[ instanceId ].rootDeviceName
        #   deviceName     = aws_vol.attachmentSet.item[0].device
        #   if rootDeviceName.indexOf(deviceName) is 0
        #     #is root device
        #     return null

        volComp = @add( "VOL", aws_vol, volRes.resource, "vol" + aws_vol.attachmentSet[0].device )
        #@vols[ aws_vol.id ] = volComp

    ()-> #EIP
      for aws_eip in @CrPartials( "EIP" ).where({category:@region}) || []
        aws_eip = aws_eip.attributes

        eni = @enis[ aws_eip.networkInterfaceId ]
        if not eni
          continue

        eipRes =
          "resource":
            "InstanceId": ""
            "PrivateIpAddress": ""
            "NetworkInterfaceId": ""
            "Domain": ""
            "PublicIp": ""
            "AllocationId": ""

        eipRes = @_mapProperty aws_eip, eipRes
        eipRes.resource.InstanceId = ""
        eipRes.resource.NetworkInterfaceId = CREATE_REF( eni )
        eipRes.resource.PrivateIpAddress   = CREATE_REF( eni )

        eipComp = @add( "EIP", aws_eip, eipRes.resource )
      return



    ()-> # Rtbs
      for aws_rtb in @CrPartials( "RT" ).where({vpcId:@vpcId}) || []
        aws_rtb = aws_rtb.attributes
        rtbRes =
          "resource" :
            "RouteTableId"   : aws_rtb.id
            "VpcId"          : CREATE_REF( @theVpc )
            "AssociationSet" : []
            "RouteSet"       : []
            "PropagatingVgwSet" : []
        #associationSet
        for i in aws_rtb.associationSet
          asso =
            Main : if i.main is false then false else "true"
            RouteTableAssociationId : i.routeTableAssociationId

          if i.subnetId
            asso.SubnetId = CREATE_REF( @subnets[i.subnetId] )
          rtbRes.resource.AssociationSet.push asso

        #routeSet
        for i in aws_rtb.routeSet
          route =
            "State" : i.state
            "Origin": i.origin
            "InstanceId"     : if i.instanceId then CREATE_REF( @instances[i.instanceId] ) else ""
            "InstanceOwnerId": if i.instanceOwnerId then i.instanceOwnerId else ""
            "GatewayId"      : ""
            "NetworkInterfaceId"   : if i.networkInterfaceId then CREATE_REF( @enis[i.networkInterfaceId] ) else ""
            "DestinationCidrBlock" : i.destinationCidrBlock
          if i.gatewayId
            if i.gatewayId isnt "local" and @gateways[i.gatewayId]
              route.GatewayId = CREATE_REF( @gateways[i.gatewayId] )
            else
              route.GatewayId = i.gatewayId
          rtbRes.resource.RouteSet.push route

        #propagatingVgwSet
        for i in aws_rtb.propagatingVgwSet
          rtbRes.resource.PropagatingVgwSet.push CREATE_REF( @gateways[i.gatewayId] )

        rtbComp = @add( "RT", aws_rtb, rtbRes.resource )
        @addLayout( rtbComp, true, @theVpc )
      return



  ]


  # getVOL      : ()->
  # getSG       : ()->
  # getELB      : ()->
  # getACL      : ()->
  # getASG      : ()->
  # getLC       : ()->
  # getNC       : ()->
  # getSP       : ()->

  convertResToJson = ( region, vpcId )->
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
    ].map (t)-> CloudResources( constant.RESTYPE[t], region )

    cd = new ConverterData( region, vpcId )
    func.call( cd ) for func in Converters

    # find default SG
    if DEFAULT_SG["DefaultSG"]
      #old app
      default_sg = cd.component[ DEFAULT_SG["DefaultSG"].uid ]
      if default_sg
        default_sg.name = "DefaultSG"
        default_sg.resource.Default = true
      #delete "default" SG component
      if DEFAULT_SG["default"] and cd.component[ DEFAULT_SG["default"].uid ]
        delete cd.component[ DEFAULT_SG["default"].uid ]
    else if DEFAULT_SG["default"]
      #new app
      default_sg = cd.component[ DEFAULT_SG["default"].uid ]
      if default_sg
        default_sg.name = "DefaultSG"
        default_sg.resource.Default   = true
        default_sg.resource.GroupName = "DefaultSG" #do not use 'default' as GroupName
      else
        console.warn "can not found default sg in component"

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

  __parseAndCache = ( region, data )->
    # Parse and cached additional datas.
    for d in data[ region ]
      d = $.xml2json( $.parseXML(d) )
      for resType of d
        if d.hasOwnProperty( resType )
          Collection = CrCollection.getClassByAwsResponseType( resType )
          if Collection then break

      col = CloudResources( Collection.type, region )
      col.parseExternalData( d )
    return

  # Returns a promise that will resolve once every resource in the vpc is fetched.
  CloudResources.getAllResourcesForVpc = ( region, vpcId )->
    RESTYPE = constant.RESTYPE

    # These resources are fetched first, because most of them are already fetched by dashboard.
    requests = []
    requests.push(CloudResources( type, region ).fetch()) for type in [
      RESTYPE.VPC
      RESTYPE.ELB
      RESTYPE.RT
      RESTYPE.CGW
      RESTYPE.IGW
      RESTYPE.VGW
      RESTYPE.VPN
      # RESTYPE.EIP
      RESTYPE.VOL
      RESTYPE.INSTANCE
    ]

    # When we get all the asgs and subnets, we can start loading other resources.
    # Including SecurityGroup, Acl, Eni, Lc, NotificationConfiguration, ScalingPolicy
    requests.push Q.all([
      CloudResources( RESTYPE.SUBNET, region ).fetch()
      CloudResources( RESTYPE.ASG, region ).fetch()
    ]).then ()->
      # Aquire additional resources. Returns a promise here, so that getAllResourcesForVpc() will
      # Wait until this request is done.
      ApiRequest("aws_resource", {
        region_name : region
        resources   : __createRequestParam( region, vpcId )
        addition    : "all"
        retry_times : 1
      }).then ( data )-> __parseAndCache( region, data )

    # When all the resources are fetched, we create component out of the resources.
    Q.all( requests ).then ()-> convertResToJson( region, vpcId )

  return
