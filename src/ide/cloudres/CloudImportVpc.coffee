
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
      @volumes   = {} # res id => comp
      @sgs       = {} # res id => comp
      @iams      = {} # res id => comp
      @lcs       = {} # res id => comp
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

    _mapProperty : ( aws_json, resource ) ->
      for k, v of aws_json
        if typeof(v) is "string" and resource[k[0].toUpperCase() + k.slice(1)] isnt undefined
          resource[k[0].toUpperCase() + k.slice(1)] = v
      resource

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

    ()-> # KP
      kpRes =
        "KeyFingerprint": ""
        "KeyName": "DefaultKP"
      @add( "KP", null, kpRes, 'DefaultKP' )
      return


    ()-> #Volume
      for aws_vol in @CrPartials( "VOL" ).where({category:@region}) || []
        aws_vol = aws_vol.attributes
        if not aws_vol.instanceId
          #not attached
          continue

        azComp = @addAz(aws_vol.availabilityZone)
        volRes =
          "VolumeId"     : aws_vol.id
          "Size"         : Number(aws_vol.size)
          "SnapshotId"   : if aws_vol.snapshotId then aws_vol.snapshotId else ""
          "Iops"         : if aws_vol.iops then aws_vol.iops else ""
          "AttachmentSet":
            "Device"      : aws_vol.device
            "InstanceId"  : ""
          "VolumeType"      : aws_vol.volumeType
          "AvailabilityZone": CREATE_REF( azComp )

        #create volume component, but add with instance
        volComp = @add( "VOL", aws_vol, volRes, "vol" + aws_vol.device )
        delete @component[ volComp.uid ]
        @volumes[ aws_vol.id ] = volComp
      return


    ()-> # Instance
      for aws_ins in @CrPartials( "INSTANCE" ).where({vpcId:@vpcId}) || []
        aws_ins = aws_ins.attributes
        if aws_ins.instanceState.name in [ "shutting-down", "terminated " ]
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
        me = @
        bdm = insComp.resource.BlockDeviceMapping
        _.each aws_ins.blockDeviceMapping, (e,key)->
          volComp = me.volumes[ e.ebs.volumeId ]
          volRes = volComp.resource
          if aws_ins.rootDeviceName.indexOf( e.deviceName ) isnt -1
            # rootDevice
            data =
              "DeviceName": volRes.AttachmentSet.Device
              "Ebs":
                "SnapshotId": if volRes.SnapshotId then volRes.SnapshotId else ""
                "VolumeSize": Number(volRes.Size)
                "VolumeType": volRes.VolumeType
            if data.Ebs.VolumeType is "io1"
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
        
        if aws_eni.deviceIndex isnt "0"
          #eni0 no need attachmentId
          eniRes.Attachment.AttachmentId = aws_eni.attachmentId
        eniRes.Attachment.InstanceId = CREATE_REF( insComp )
        eniRes.Attachment.DeviceIndex = aws_eni.deviceIndex

        for ip in aws_eni.privateIpAddressesSet
          eniRes.PrivateIpAddressSet.push {"PrivateIpAddress": ip.privateIpAddress, "AutoAssign" : "false", "Primary" : ip.primary}

        eniRes.GroupSet.push {
          "GroupId": aws_eni.groupId,
          "GroupName": aws_eni.groupName
          }

        eniComp = @add( "ENI", aws_eni, eniRes, "eni" + aws_eni.deviceIndex )
        if aws_eni.deviceIndex isnt "0"
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
            elbRes.Instances.push CREATE_REF( @instances[ instanceId ] )

        elbComp = @add( "ELB", aws_elb, elbRes, aws_elb.id )
        @addLayout( elbComp, false, @theVpc )
      return


    ()-> #LC
      for aws_lc in @CrPartials( "LC" ).where({category:@region}) || []
        aws_lc = aws_lc.attributes
        lcRes =
          'BlockDeviceMapping': []
          'CreatedTime': ''
          'EbsOptimized': ''
          'IamInstanceProfile': ''
          'ImageId': ''
          'InstanceMonitoring': ''
          'InstanceType': ''
          'KernelId': ''
          'KeyName': ''
          'LaunchConfigurationARN': ''
          'LaunchConfigurationName': ''
          'RamdiskId': ''
          'SecurityGroups': []
          'SpotPrice': ''
          'UserData': ''

        lcRes = @_mapProperty aws_lc, lcRes

        lcRes.SecurityGroups = aws_lc.SecurityGroups
        if aws_lc.BlockDeviceMappings
          lcRes.BlockDeviceMapping = aws_lc.BlockDeviceMappings
        lcRes.InstanceMonitoring = aws_lc.InstanceMonitoring.Enabled

        lcComp = @add( "LC", aws_lc, lcRes, aws_lc.LaunchConfigurationName )
        delete @component[ aws_lc.id ]
        @lcs[ aws_lc.id ] = lcComp
      return


    ()-> #ASG
      for aws_asg in @CrPartials( "ASG" ).where({category:@region}) || []
        aws_asg = aws_asg.attributes

        asgRes =
          'AutoScalingGroupARN' : ''
          'AutoScalingGroupName': ''
          'AvailabilityZones'   : []
          'CreatedTime'    : ''
          'DefaultCooldown': ""
          'DesiredCapacity': ""
          'EnabledMetrics' : []
          'HealthCheckGracePeriod': ""
          'HealthCheckType': ""
          'Instances'      : []
          'LaunchConfigurationName': ''
          'LoadBalancerNames': []
          'MaxSize': ""
          'MinSize': ""
          'PlacementGroup': ''
          'Status' : ''
          'SuspendedProcesses' : []
          'TerminationPolicies': []
          'VPCZoneIdentifier'  : ''
          'InstanceId': ''
          'ShouldDecrementDesiredCapacity': ''

        asgRes = @_mapProperty aws_asg, asgRes

        asgRes.TerminationPolicies = aws_asg.TerminationPolicies
        asgRes.LoadBalancerNames = aws_asg.LoadBalancerNames

        me = @
        az = []
        _.each aws_asg.AvailabilityZones, (e,key)->
          azComp = me.addAz( e )
          az.push CREATE_REF( azComp )
        asgRes.AvailabilityZones = az

        vpcZoneIdentifier = []
        _.each aws_asg.Subnets, (e,key)->
          subnetComp = me.subnets[e]
          vpcZoneIdentifier.push CREATE_REF( subnetComp )
        asgRes.VPCZoneIdentifier = vpcZoneIdentifier.join( "," )

        asgComp = @add( "ASG", aws_asg, asgRes, aws_asg.AutoScalingGroupName )
      return

    ()-> #Topic
      for aws_topic in @CrPartials( "TOPIC" ).where({category:@region}) || []
        aws_topic = aws_topic.attributes
      return

    ()-> #NC
      for aws_nc in @CrPartials( "NC" ).where({category:@region}) || []
        aws_nc = aws_nc.attributes

      return

    ()-> #SP
      for aws_sp in @CrPartials( "SP" ).where({category:@region}) || []
        aws_sp = aws_sp.attributes
      return

    ()-> #CW
      for aws_cw in @CrPartials( "CW" ).where({category:@region}) || []
        aws_cw = aws_cw.attributes
      return


  ]


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
      "IAM"
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
      RESTYPE.EIP
      RESTYPE.VOL
      RESTYPE.INSTANCE
      RESTYPE.IAM
      RESTYPE.LC
      RESTYPE.ASG
      RESTYPE.TOPIC
      RESTYPE.NC
      RESTYPE.SP
      RESTYPE.CW
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
