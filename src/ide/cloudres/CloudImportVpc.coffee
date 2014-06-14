
define ["CloudResources", "ide/cloudres/CrCollection", "constant", "ApiRequest"], ( CloudResources, CrCollection, constant, ApiRequest )->

  # Helpers
  CREATE_REF = ( compOrUid )-> "@{#{compOrUid.uid or compOrUid}.r.p}"
  UID        = MC.guid
  DEFAULT_SG = {}
  NAME       = ( res_attributes )->
    if res_attributes.tagSet
      name = res_attributes.tagSet.name || res_attributes.tagSet.Name
    name || res_attributes.id


  # Class used to collect components / layouts
  class ConverterData
    CrPartials : ( type )-> CloudResources( constant.RESTYPE[type], @region )

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
      @elbs      = {} # res id   => comp
      @lcs       = {} # res name => comp
      @asgs      = {} # res name => comp
      @topics    = {} # res arn  => comp
      @ins_in_asg= [] # instances in asg
      @component = {}
      @layout    = {}
      @originalJson = jQuery.extend(true, {component: {}, layout: {}}, originalJson); #original app json

      # Use the originalJson to generate uid for a existing resource.
      @compMap = {}
      if @originalJson
        @compMap = @_genCompMap(@originalJson)
      ###
      if originalJson
        for uid, comp of originalJson
          @compMap[ comp.resource.xxx ] = uid
      ###
      return @

    add : ( type_string, res_attributes, component_resources, default_name )->
      if not res_attributes and not default_name and not component_resources.uid
        console.error "[ConverterData.add] if res_attributes is null, then must specify default_name"
        return null

      # directly add component based on original component
      if component_resources and component_resources.uid
        @component[ component_resources.uid ] = component_resources
        return component_resources

      # found an original component by component_resources
      originComp = @getOriginalComp component_resources, constant.RESTYPE[ type_string ]
      if originComp
        _.extend originComp.resource, component_resources
        @component[ originComp.uid ] = originComp

        return @component[ originComp.uid ]

      comp =
        uid  : ""
        name : ""
        type : constant.RESTYPE[ type_string ]
        resource : component_resources
      #generate uid
      if res_attributes and @compMap[ res_attributes.id ]
        #existed resource
        comp.uid = @compMap[ res_attributes.id ].uid
        comp.name = @compMap[ res_attributes.id ].name
      else
        #new resource
        comp.uid  = UID()
        comp.name = if default_name then default_name else NAME( res_attributes )

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

    addAz : ( azName )->
      az = @azs[ azName ]
      if az then return az
      az = @add( "AZ", { id : azName }, @getOriginalComp azName, 'AZ' )
      @addLayout( az, true, @theVpc )
      @azs[ azName ] = az
      az

    addIAM : ( arn ) ->
      iamComp = @iams[ arn ]
      if iamComp then return iamComp

      for aws_iam in @CrPartials( "IAM" ).where({Arn:arn}) || []
        aws_iam = aws_iam.attributes
        iamRes =
          "CertificateBody" : ""
          "CertificateChain": ""
          "PrivateKey"      : ""
          "ServerCertificateMetadata":
            "Arn"                  : aws_iam.Arn
            "ServerCertificateId"  : aws_iam.id
            "ServerCertificateName": aws_iam.Name
        iamComp = @add( "IAM", aws_iam, iamRes, aws_iam.Name )
        @iams[ aws_iam.Arn ] = iamComp
        return iamComp
      return null

    addTopic : ( arn ) ->
      topicComp = @topics[ arn ]
      if topicComp then return topicComp

      for aws_topic in @CrPartials( "TOPIC" ).where({id:arn}) || []
        aws_topic = aws_topic.attributes
        topicRes =
          "TopicArn" : aws_topic.id
        topicComp = @add( "TOPIC", aws_topic, topicRes, aws_topic.Name )
        @topics[ aws_topic.id ] = topicComp
        return topicComp
      return null

    getOriginalComp: ( jsonOrKey, type ) ->
      type = constant.RESTYPE[ type ] or type
      key = constant.AWS_RESOURCE_KEY[ type ]
      id = if _.isObject jsonOrKey then jsonOrKey[key] else jsonOrKey


      for uid, comp of @originalJson.component
        if comp.type isnt type then continue

        if ( comp[ key ] or comp.resource[ key ] ) is id
          return comp

      null

    _mapProperty : ( aws_json, resource ) ->
      for k, v of aws_json
        if typeof(v) is "string" and resource[k[0].toUpperCase() + k.slice(1)] isnt undefined
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



  # The order of Converters functions are important!
  # Some converter must be behind other converters.
  Converters = [
    ()-> # Vpc & Dhcp
      vpc = @CrPartials( "VPC" ).get( @vpcId ).attributes

      vpc.VpcId = @vpcId
      # Cache the vpc so that other can use it.
      @theVpc = vpcComp = @add("VPC", vpc, {
        VpcId           : vpc.VpcId
        CidrBlock       : vpc.cidrBlock
        DhcpOptionsId   : vpc.dhcpOptionsId
        InstanceTenancy : vpc.instanceTenancy

        EnableDnsHostnames : vpc.enableDnsHostnames
        EnableDnsSupport   : vpc.enableDnsSupport
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
        if not (aws_igw.attachmentSet and aws_igw.attachmentSet.length>0)
          continue
        igwRes =
          "AttachmentSet"    :
            "VpcId": CREATE_REF( @theVpc )
          "InternetGatewayId": aws_igw.id

        igwComp = @add( "IGW", aws_igw, igwRes, "Internet-gateway" )
        @addLayout( igwComp, true, @theVpc )
        @gateways[ aws_igw.id ] = igwComp
      return


    ()-> # VGW
      for aws_vgw in @CrPartials( "VGW" ).where({vpcId:@vpcId}) || []
        aws_vgw = aws_vgw.attributes
        if aws_vgw.state in [ "deleted","deleting" ]
          continue
        if aws_vgw.attachments and aws_vgw.attachments.length > 0
          vgwAttach = aws_vgw.attachments[0]
        vgwRes =
          "Attachments": [
            "VpcId": CREATE_REF( @theVpc )
          ]
          "Type": aws_vgw.type
          "VpnGatewayId": ""

        vgwRes.VpnGatewayId = aws_vgw.id
        vgwComp = @add( "VGW", aws_vgw, vgwRes, "VPN-gateway" )
        @addLayout( vgwComp, true, @theVpc )

        @gateways[ aws_vgw.id ] = vgwComp
      return


    ()-> #CGW
      for aws_cgw in @CrPartials( "CGW" ).where({category:@region}) || []
        aws_cgw = aws_cgw.attributes
        if aws_cgw.state in [ "deleted","deleting" ]
          continue
        cgwRes  =
          "BgpAsn"   : ""
          "CustomerGatewayId": ""
          "IpAddress": ""
          "Type"     : ""

        cgwRes = @_mapProperty aws_cgw, cgwRes
        cgwRes.CustomerGatewayId = aws_cgw.id
        #create cgw component, but add with vpn
        cgwComp = @add( "CGW", aws_cgw, cgwRes, aws_cgw.id )
        delete @component[ cgwComp.uid ]
        @gateways[ aws_cgw.id ] = cgwComp
      return


    ()-> #VPN
      for aws_vpn in @CrPartials( "VPN" ).where({category:@region}) || []
        aws_vpn = aws_vpn.attributes
        if aws_vpn.state in [ "deleted","deleting" ]
          continue
        vgwComp = @gateways[ aws_vpn.vpnGatewayId ]
        cgwComp = @gateways[ aws_vpn.customerGatewayId ]
        if not (cgwComp and vgwComp)
          continue
        vpnRes =
          "CustomerGatewayId" : ""
          "Options"     :
            "StaticRoutesOnly": "true"
          "Routes": []
          "Type"  : "ipsec.1"
          "VpnConnectionId"   : ""
          "VpnGatewayId": ""
          "CustomerGatewayConfiguration": ""

        vpnRes = @_mapProperty aws_vpn, vpnRes
        vpnRes.VpnGatewayId      = CREATE_REF( vgwComp )
        vpnRes.CustomerGatewayId = CREATE_REF( cgwComp )
        if aws_vpn.options and aws_vpn.options.staticRoutesOnly
          vpnRes.Options.StaticRoutesOnly = aws_vpn.options.staticRoutesOnly
        if aws_vpn.routes
          for route in aws_vpn.routes
            vpnRes.Routes.push
              "DestinationCidrBlock" : route.destinationCidrBlock
              "Source" : route.source

        vpnComp = @add( "VPN", aws_vpn, vpnRes, aws_vpn.id )
        #add CGW to layout
        @component[ cgwComp.uid ] = cgwComp
        @addLayout( cgwComp, false )

      return


    ()-> # SG
      for aws_sg in @CrPartials( "SG" ).where({vpcId:@vpcId}) || []
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
        #generate ipPermissions
        if aws_sg.ipPermissions
          for sg_rule in aws_sg.ipPermissions || []
            ipranges = ''
            if sg_rule.groups.length>0 and sg_rule.groups[0].groupId
              ipranges = sg_rule.groups[0].groupId
            else if sg_rule.ipRanges and sg_rule.ipRanges.length>0
              ipranges = sg_rule.ipRanges[0].cidrIp

            if ipranges
              sgRes.IpPermissions.push {
                "FromPort": if sg_rule.fromPort then sg_rule.fromPort else "",
                "IpProtocol": sg_rule.ipProtocol,
                "IpRanges": ipranges,
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
              sgRes.IpPermissionsEgress.push {
                "FromPort": if sg_rule.fromPort then sg_rule.fromPort else "",
                "IpProtocol": sg_rule.ipProtocol,
                "IpRanges": ipranges,
                "ToPort": if sg_rule.toPort then sg_rule.toPort else ""
              }

        sgComp = @add( "SG", aws_sg, sgRes, aws_sg.groupName )
        if aws_sg.groupName is "default"
          DEFAULT_SG["default"] = sgComp
        else if aws_sg.groupName.indexOf("-DefaultSG-app-") isnt -1
          DEFAULT_SG["DefaultSG"] = sgComp

        @sgs[ aws_sg.id ] = sgComp
      return

    ()-> #Volume
      for aws_vol in @CrPartials( "VOL" ).where({category:@region}) || []
        aws_vol = aws_vol.attributes
        if not aws_vol.instanceId
          #not attached
          continue

        #azComp = @addAz(aws_vol.availabilityZone)
        volRes =
          "VolumeId"     : aws_vol.id
          "Size"         : Number(aws_vol.size)
          "SnapshotId"   : if aws_vol.snapshotId then aws_vol.snapshotId else ""
          "Iops"         : if aws_vol.iops then aws_vol.iops else ""
          "AttachmentSet":
            "Device"      : aws_vol.device
            "InstanceId"  : ""
          "VolumeType"      : aws_vol.volumeType
          "AvailabilityZone": CREATE_REF( aws_vol.availabilityZone )

        #create volume component, but add with instance
        volComp = @add( "VOL", aws_vol, volRes, "vol" + aws_vol.device )
        delete @component[ volComp.uid ]
        @volumes[ aws_vol.id ] = volComp
      return


    ()-> # Instance
      me = @
      #get all instances in asg
      for aws_asg in @CrPartials( "ASG" ).where({category:@region}) || []
        aws_asg = aws_asg.attributes
        _.each aws_asg.Instances, (e,key)->
          me.ins_in_asg.push e.InstanceId

      for aws_ins in @CrPartials( "INSTANCE" ).where({vpcId:@vpcId}) || []
        aws_ins = aws_ins.attributes

        #skip invalid instance
        if aws_ins.instanceState.name in [ "shutting-down", "terminated " ]
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
          "DisableApiTermination": ""
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
            "Base64Encoded": ""
            "Data"         : ""
          "VpcId"   : ""

        insRes = @_mapProperty aws_ins, insRes

        insRes.Subnet = CREATE_REF( subnetComp )
        insRes.VpcId  = CREATE_REF( @theVpc )
        insRes.Placement.AvailabilityZone = CREATE_REF( azComp )

        if aws_ins.monitoring and aws_ins.monitoring
          insRes.Monitoring = aws_ins.monitoring.state

        insRes.Placement.Tenancy = aws_ins.placement.tenancy
        insRes.InstanceId        = aws_ins.id
        insRes.EbsOptimized      = aws_ins.ebsOptimized

        #generate instance component
        insComp = @add( "INSTANCE", aws_ins, insRes )

        #generate BlockDeviceMapping for instance
        bdm = insComp.resource.BlockDeviceMapping
        _.each aws_ins.blockDeviceMapping, (e,key)->
          volComp = me.volumes[ e.ebs.volumeId ]

          if not volComp then return

          volRes = volComp.resource
          if aws_ins.rootDeviceName.indexOf( e.deviceName ) isnt -1
            # rootDevice
            data =
              "DeviceName": volRes.AttachmentSet.Device
              "Ebs":
                "VolumeSize": Number(volRes.Size)
                "VolumeType": volRes.VolumeType
            if volRes.SnapshotId
              data.Ebs.SnapshotId = volRes.SnapshotId
            if volRes.VolumeType is "io1"
              data.Ebs.Iops = volRes.Iops
            bdm.push data
          else
            # not rootDevice
            bdm.push "#" + volComp.uid
            #add volume component
            volComp.resource.AttachmentSet.InstanceId = CREATE_REF( insComp )
            me.component[ volComp.uid ] = volComp

        # # default_kp # TODO :
        # if default_kp and default_kp.resource and aws_ins.keyName is default_kp.resource.KeyName
        #   insComp.resource.KeyName = "@{" + default_kp.uid + ".resource.KeyName}"

        @addLayout( insComp, false, subnetComp )
        @instances[ aws_ins.id ] = insComp
      return


    ()-> #ENI
      for aws_eni in @CrPartials( "ENI" ).where({vpcId:@vpcId}) || []
        aws_eni = aws_eni.attributes
        azComp = @addAz(aws_eni.availabilityZone)
        insComp = @instances[aws_eni.instanceId]
        if not insComp
          continue

        subnetComp = @subnets[aws_eni.subnetId]
        if not subnetComp
          continue

        eniRes =
          "AssociatePublicIpAddress" : false
          "Attachment":
              "AttachmentId" : ""
              "DeviceIndex"  : ""
              "InstanceId"   : ""
          "AvailabilityZone": ""
          "Description": ""
          "GroupSet"   : []
          "NetworkInterfaceId"  : ""
          "PrivateIpAddressSet" : []
          "SourceDestCheck": true
          "SubnetId"       : ""
          "PrivateDnsName" : ""
          "VpcId"          : ""

        if aws_eni.instanceOwnerId and aws_eni.instanceOwnerId in [ "amazon-elb", "amazon-rds" ]
          continue

        eniRes = @_mapProperty aws_eni, eniRes

        #check Automatically assign Public IP
        if aws_eni.association and aws_eni.association.publicIp
          eniRes.AssociatePublicIpAddress = true

        eniRes.AvailabilityZone = CREATE_REF( azComp )
        eniRes.SubnetId         = CREATE_REF( subnetComp )
        eniRes.VpcId            = CREATE_REF( @theVpc )
        if not ( aws_eni.deviceIndex in [ "0", 0 ] )
          #eni0 no need attachmentId
          eniRes.Attachment.AttachmentId = aws_eni.attachmentId


        eniRes.Attachment.InstanceId = CREATE_REF( insComp )
        eniRes.Attachment.DeviceIndex = if aws_eni.deviceIndex is 0 then '0' else aws_eni.deviceIndex

        for ip in aws_eni.privateIpAddressesSet
          eniRes.PrivateIpAddressSet.push {"PrivateIpAddress": ip.privateIpAddress, "AutoAssign" : "false", "Primary" : ip.primary}

        eniRes.GroupSet.push
          "GroupId": CREATE_REF @sgs[ aws_eni.groupId ]
          "GroupName": aws_eni.groupName


        eniComp = @add( "ENI", aws_eni, eniRes, "eni" + aws_eni.deviceIndex )
        if not ( aws_eni.deviceIndex in [ "0", 0 ] )
          @addLayout( eniComp, false, subnetComp )

        @enis[ aws_eni.id ] = eniComp
      return


    ()-> #EIP
      for aws_eip in @CrPartials( "EIP" ).where({category:@region}) || []
        aws_eip = aws_eip.attributes

        eni = @enis[ aws_eip.networkInterfaceId ]
        if not eni
          continue

        eipRes =
          "AllocationId": ""
          "Domain": ""
          "InstanceId": ""
          "NetworkInterfaceId": ""
          "PrivateIpAddress": ""
          "PublicIp": ""

        eipRes = @_mapProperty aws_eip, eipRes
        eipRes.AllocationId = eip.id
        eipRes.InstanceId   = ""
        eipRes.NetworkInterfaceId = CREATE_REF( eni )
        eipRes.PrivateIpAddress   = CREATE_REF( eni )

        eipComp = @add( "EIP", aws_eip, eipRes )
      return



    ()-> # Rtbs
      for aws_rtb in @CrPartials( "RT" ).where({vpcId:@vpcId}) || []
        aws_rtb = aws_rtb.attributes
        rtbRes =
          "AssociationSet" : []
          "PropagatingVgwSet" : []
          "RouteSet"       : []
          "RouteTableId"   : aws_rtb.id
          "VpcId"          : CREATE_REF( @theVpc )

        #associationSet
        for i in aws_rtb.associationSet
          asso =
            Main : if i.main is false then false else "true"
            RouteTableAssociationId : i.routeTableAssociationId
          subnetComp = @subnets[i.subnetId]
          if i.subnetId and subnetComp
            asso.SubnetId = CREATE_REF( subnetComp )
          rtbRes.AssociationSet.push asso

        #routeSet
        for i in aws_rtb.routeSet
          insComp = @instances[i.instanceId]
          eniComp = @enis[i.networkInterfaceId]
          gwComp  = @gateways[i.gatewayId]
          route =
            "DestinationCidrBlock" : i.destinationCidrBlock
            "GatewayId"      : ""
            "InstanceId"     : if i.instanceId and insComp then CREATE_REF( insComp ) else ""
            "NetworkInterfaceId"   : if i.networkInterfaceId and eniComp then CREATE_REF( eniComp ) else ""
            "Origin"         : i.origin
          if i.gatewayId
            if i.gatewayId isnt "local" and gwComp
              route.GatewayId = CREATE_REF( gwComp )
            else
              route.GatewayId = i.gatewayId
          rtbRes.RouteSet.push route

        #propagatingVgwSet
        for i in aws_rtb.propagatingVgwSet
          gwComp = @gateways[i.gatewayId]
          if gwComp
            rtbRes.PropagatingVgwSet.push CREATE_REF( gwComp )

        rtbComp = @add( "RT", aws_rtb, rtbRes )
        @addLayout( rtbComp, true, @theVpc )
      return


    ()-> #ACL
      for aws_acl in @CrPartials( "ACL" ).where({vpcId:@vpcId}) || []
        aws_acl    = aws_acl.attributes
        subnetComp = @subnets[aws_acl.subnetId]
        aclRes =
          "AssociationSet": []
          "Default" : false
          "EntrySet": []
          "NetworkAclId": ""
          "VpcId"   : ""
        aclRes = @_mapProperty aws_acl, aclRes

        aclRes.VpcId = CREATE_REF( @theVpc )
        aclRes.NetworkAclId = aws_acl.id

        for acl in aws_acl.entrySet
          aclRes.EntrySet.push
            "RuleAction": acl.ruleAction
            "Protocol"  : acl.protocol
            "CidrBlock" : acl.cidrBlock
            "Egress"    : acl.egress
            "IcmpTypeCode":
              "Type": if acl.icmpTypeCode then acl.icmpTypeCode.type else ""
              "Code": if acl.icmpTypeCode then acl.icmpTypeCode.code else ""
            "PortRange":
              "To"  : if acl.portRange then acl.portRange.to else ""
              "From": if acl.portRange then acl.portRange.from else ""
            "RuleNumber": acl.ruleNumber

        for acl in aws_acl.associationSet
          aclRes.AssociationSet.push
            "NetworkAclAssociationId": acl.networkAclAssociationId
            "SubnetId": CREATE_REF( subnetComp )

        aclComp = @add( "ACL", aws_acl, aclRes )
      return

    ()-> #ELB
      me = @
      for aws_elb in @CrPartials( "ELB" ).where({vpcId:@vpcId}) || []
        aws_elb = aws_elb.attributes

        elbRes =
          "HealthCheck":
            "Timeout": "5",
            "Target" : "HTTP:80/index.html"
            "HealthyThreshold"  : "9"
            "UnhealthyThreshold": "4"
            "Interval": "30"
          "Policies":
            "AppCookieStickinessPolicies": []
            "OtherPolicies"              : []
            "LBCookieStickinessPolicies" : []
          "BackendServerDescriptions": []
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
          "CrossZoneLoadBalancing": "false"

        elbRes = @_mapProperty aws_elb, elbRes

        elbRes.CrossZoneLoadBalancing = if aws_elb.CrossZoneLoadBalancing then aws_elb.CrossZoneLoadBalancing else ""
        elbRes.HealthCheck.Timeout    = aws_elb.HealthCheck.Timeout
        elbRes.HealthCheck.Interval   = aws_elb.HealthCheck.Interval
        elbRes.HealthCheck.UnhealthyThreshold = aws_elb.HealthCheck.UnhealthyThreshold
        elbRes.HealthCheck.Target             = aws_elb.HealthCheck.Target
        elbRes.HealthCheck.HealthyThreshold   = aws_elb.HealthCheck.HealthyThreshold

        if aws_elb.SecurityGroups
          for sgId in aws_elb.SecurityGroups
            elbRes.SecurityGroups.push CREATE_REF( @sgs[sgId] )

        elbRes.VpcId = CREATE_REF( @theVpc )
        if aws_elb.Subnets
          for subnetId in aws_elb.Subnets
            elbRes.Subnets.push CREATE_REF( @subnets[subnetId])

        # if aws_elb.AvailabilityZones
        #   for az in aws_elb.AvailabilityZones
        #     azComp = @addAz(sb.availabilityZone)
        #     elbRes.AvailabilityZones.push CREATE_REF( azComp )

        if aws_elb.ListenerDescriptions
          for listener in aws_elb.ListenerDescriptions
            data =
              "PolicyNames": if listener.PolicyNames then listener.PolicyNames else ''
              "Listener":
                "LoadBalancerPort": listener.Listener.LoadBalancerPort
                "InstanceProtocol": listener.Listener.InstanceProtocol
                "Protocol"        : listener.Listener.Protocol
                "SSLCertificateId": if listener.Listener.SSLCertificateId then listener.Listener.SSLCertificateId else ""
                "InstancePort"    : listener.Listener.InstancePort
            #add ServerCertificate component
            if listener.Listener.SSLCertificateId
              iamComp = @addIAM( listener.Listener.SSLCertificateId )
              data.Listener.SSLCertificateId = CREATE_REF( iamComp )
            elbRes.ListenerDescriptions.push data

        if aws_elb.Instances
          for instanceId in aws_elb.Instances
            #skip instances in asg
            if not (instanceId in me.ins_in_asg)
              elbRes.Instances.push CREATE_REF( @instances[ instanceId ] )

        elbComp = @add( "ELB", aws_elb, elbRes, aws_elb.id )
        @addLayout( elbComp, false, @theVpc )
        @elbs[ aws_elb.id ] = elbComp
      return


    ()-> #LC
      me = @
      for aws_lc in @CrPartials( "LC" ).filter( (model) -> model.RES_TAG is me.vpcId ) || []
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
        lcRes.InstanceMonitoring = aws_lc.InstanceMonitoring.Enabled

        #convert SecurityGroups to REF
        sg = []
        _.each aws_lc.SecurityGroups, (e,key)->
          sgComp = me.sgs[ e ]
          if sgComp
            sg.push CREATE_REF( sgComp )
        if sg.length is 0
          #sg of LC is not in current VPC, means this lc is not in this VPC
          continue

        lcRes.SecurityGroups = sg

        #generate BlockDeviceMappings
        bdm = lcRes.BlockDeviceMapping
        _.each aws_lc.BlockDeviceMappings, (e,key)->
          data =
            "DeviceName": e.DeviceName
            "Ebs":
              "VolumeSize": Number(e.ebs.VolumeSize)
              "VolumeType": e.ebs.VolumeType
          if e.ebs.SnapshotId
            data.Ebs.SnapshotId = e.ebs.SnapshotId
          if data.Ebs.VolumeType is "io1"
            data.Ebs.Iops = e.Ebs.Iops
          bdm.push data

        lcComp = @add( "LC", aws_lc, lcRes, aws_lc.Name )
        delete @component[ aws_lc.id ]
        @lcs[ aws_lc.Name ] = lcComp
      return


    ()-> #ASG
      me = @
      for aws_asg in @CrPartials( "ASG" ).where({category:@region}) || []
        aws_asg = aws_asg.attributes

        asgRes =
          "AutoScalingGroupARN" : ""
          "AutoScalingGroupName": ""
          "AvailabilityZones"   : []
            # 0: "@{uid.resource.ZoneName}"
            # 1: "@{uid.resource.ZoneName}"
          "DefaultCooldown"        : 0
          "DesiredCapacity"        : 0
          "HealthCheckGracePeriod" : 0
          "HealthCheckType"        : ""
          "LaunchConfigurationName": "" #"@{uid.resource.LaunchConfigurationName}"
          "LoadBalancerNames"      : []
            #0: "@{uid.resource.LoadBalancerName}"
            #1: "@{uid.resource.LoadBalancerName}"
          MaxSize: 0
          MinSize: 0
          TerminationPolicies: []
            #0: "Default"
          VPCZoneIdentifier: "" #"@{uid.resource.SubnetId} , @{uid.resource.SubnetId}"

        asgRes = @_mapProperty aws_asg, asgRes

        asgRes.AutoScalingGroupARN  = aws_asg.id
        asgRes.AutoScalingGroupName = aws_asg.Name
        asgRes.TerminationPolicies  = aws_asg.TerminationPolicies

        #convert LaunchConfigurationName to REF
        asgRes.LaunchConfigurationName = CREATE_REF( @lcs[ aws_asg.LaunchConfigurationName ] )

        #convert VPCZoneIdentifier to REF
        vpcZoneIdentifier = []
        firstSubnetComp = ""
        _.each aws_asg.Subnets, (e,key)->
          subnetComp = me.subnets[e]
          if subnetComp
            if not firstSubnetComp
              firstSubnetComp = subnetComp
            vpcZoneIdentifier.push CREATE_REF( subnetComp )
        if vpcZoneIdentifier.length is 0
          #asg is not in current VPC
          continue
        asgRes.VPCZoneIdentifier = vpcZoneIdentifier.join( "," )

        #convert ELB to REF
        elb = []
        _.each aws_asg.LoadBalancerNames, (e,key)->
          elbComp = me.elbs[e]
          elb.push CREATE_REF( elbComp )
        asgRes.LoadBalancerNames = elb

        #convert AZ to REF
        az = []
        _.each aws_asg.AvailabilityZones, (e,key)->
          azComp = me.addAz( e )
          az.push CREATE_REF( azComp )
        asgRes.AvailabilityZones = az

        asgComp = @add( "ASG", aws_asg, asgRes, aws_asg.Name )
        @addLayout( asgComp, true, firstSubnetComp )
        @asgs[ aws_asg.Name ] = asgComp
      return

    ()-> #NC
      for aws_nc in @CrPartials( "NC" ).where({category:@region}) || []
        aws_nc = aws_nc.attributes
        ncRes =
          "AutoScalingGroupName": "" #"@{uid.resource.AutoScalingGroupName}"
          "NotificationType": []
          "TopicARN": "" #"@{uid.resource.TopicArn}"
        ncRes = @_mapProperty aws_nc, ncRes

        #convert AutoScalingGroupName to REF
        asgComp = @asgs[aws_nc.AutoScalingGroupName]
        if asgComp
          ncRes.AutoScalingGroupName = CREATE_REF( asgComp )
        else
          continue

        #convert Topic to REF
        #topicComp = @addTopic( aws_nc.TopicARN )
        ncRes.TopicARN = CREATE_REF( aws_nc.TopicARN )

        ncComp = @add( "NC", aws_nc, ncRes, "SnsNotification")
      return

    ()-> #SP
      for aws_sp in @CrPartials( "SP" ).where({category:@region}) || []
        aws_sp = aws_sp.attributes
        spRes =
          "AdjustmentType"      : "" #"ChangeInCapacity"
          "AutoScalingGroupName": "" #"@{uid.resource.AutoScalingGroupName}"
          "Cooldown"  : 0
          "MinAdjustmentStep": ""
          "PolicyARN" : "" #"arn:aws:autoscaling:us-east-1:994554139310:scalingPolicy:69df7c02-ed5f-42cf-870a-d649206cb169:autoScalingGroupName/asg0---app-aae6fe2f:policyName/asg0-policy-0"
          "PolicyName": "" #"asg0-policy-0"
          "ScalingAdjustment": ""

        spRes = @_mapProperty aws_sp, spRes

        #convert AutoScalingGroupName to REF
        asgComp = @asgs[aws_sp.AutoScalingGroupName]
        if asgComp
          spRes.AutoScalingGroupName = CREATE_REF( asgComp )
        else
          continue

        spRes.PolicyARN = aws_sp.id
        spRes.PolicyName = aws_sp.Name
        spComp = @add( "SP", aws_sp, spRes, aws_sp.Name )
      return

    ()-> #CW
      me = @
      for aws_cw in @CrPartials( "CW" ).where({category:@region}) || []
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
                "value": CREATE_REF( asgComp )
              dimension.push data
        if dimension.length is 0
          #CW is not for asg in current VPC
          continue

        #convert AlarmActions to REF: TODO

        #OKAction: TODO


        cwRes.AlarmArn  = aws_cw.id
        cwRes.AlarmName = aws_cw.Name

        cwComp = @add( "CW", aws_cw, cwRes, aws_cw.Name )
      return

    # Retain component only belong to us
    # When and only when these component are not in @component

    () ->
      retainList = [
        'AWS.EC2.Tag'
        constant.RESTYPE.KP
        constant.RESTYPE.TOPIC
        constant.RESTYPE.SUBSCRIPTION
        constant.RESTYPE.IAM
        constant.RESTYPE.DHCP

      ]

      for uid, com of @originalJson.component
        if not @component[ uid ] and ( com.type in retainList )
          @add null, null, com
        null

      null

  ]


  # getNC       : ()->
  # getSP       : ()->

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

  CloudResources.getAllResourcesForVpc = convertResToJson
  return
