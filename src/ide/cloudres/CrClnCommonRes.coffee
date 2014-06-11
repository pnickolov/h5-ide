
define [
  "./CrCommonCollection"
  "./CrCollection"
  "./CrModel"
  "ApiRequest"
  "constant"
], ( CrCommonCollection, CrCollection, CrModel, ApiRequest, constant )->

  ### Elb ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrElbCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.ELB
    modelIdAttribute : "LoadBalancerName"

    parseFetchData : ( data )->
      elbs = data.DescribeLoadBalancersResponse.DescribeLoadBalancersResult.LoadBalancerDescriptions?.member
      for elb in elbs || []
        elb.AvailabilityZones = elb.AvailabilityZones?.member || []
        elb.Instances         = elb.Instances?.member || []
        elb.SecurityGroups    = elb.SecurityGroups?.member || []
        elb.Subnets           = elb.Subnets?.member || []
        elb.ListenerDescriptions = elb.ListenerDescriptions?.member || []
        for i, idx in elb.Instances
          elb.Instances[ idx ] = i.InstanceId
        elb.vpcId = elb.VPCId
        delete elb.VPCId
      elbs
  }

  ### VPN ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVpnCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VPN
    modelIdAttribute : "vpnConnectionId"
    parseFetchData : ( data )->
      vpns = data.DescribeVpnConnectionsResponse.vpnConnectionSet = data.DescribeVpnConnectionsResponse.vpnConnectionSet?.item
      for vpn in vpns || []
        vpn.vgwTelemetry = vpn.vgwTelemetry?.item
      vpns
  }

  ### EIP ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrEipCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.EIP
    modelIdAttribute : "allocationId"
    parseFetchData : ( data )-> data.DescribeAddressesResponse.addressesSet?.item
  }

  ### VPC ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVpcCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VPC
    modelIdAttribute : "vpcId"
    parseFetchData : ( data )-> data.DescribeVpcsResponse.vpcSet?.item
  }

  ### ASG ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrAsgCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.ASG
    modelIdAttribute : "AutoScalingGroupARN"
    parseFetchData : ( data )->
      asgs = data.DescribeAutoScalingGroupsResponse.DescribeAutoScalingGroupsResult.AutoScalingGroups?.member
      for asg in asgs ||[]
        asg.AvailabilityZones   = asg.AvailabilityZones?.member || []
        asg.Instances           = asg.Instances?.member || []
        asg.LoadBalancerNames   = asg.LoadBalancerNames?.member || []
        asg.TerminationPolicies = asg.TerminationPolicies?.member || []
        asg.Subnets             = asg.VPCZoneIdentifier.split(",")
        delete asg.VPCZoneIdentifier
      asgs
  }

  ### CloudWatch ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrCloudwatchCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.CW
    parseFetchData : ( data )->
      cws = data.DescribeAlarmsResponse.DescribeAlarmsResult.MetricAlarms?.member
      for cw in cws || []
        cw.Dimensions = cw.Dimensions?.member || []
        cw.id = cw.AlarmArn
        delete cw.AlarmArn
      cws
  }

  ### CGW ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrCgwCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.CGW
    modelIdAttribute : "customerGatewayId"
    parseFetchData : ( data )-> data.DescribeCustomerGatewaysResponse.customerGatewaySet?.item
  }

  ### VGW ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVgwCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VGW
    modelIdAttribute : "vpnGatewayId"
    parseFetchData : ( data )-> 
      vgws = data.DescribeVpnGatewaysResponse.vpnGatewaySet?.item
      for vgw in vgws || []
        vgw.attachments = vgw.attachments?.item || []
        vgw.id = vgw.vpnGatewayId
        if vgw.attachments and vgw.attachments.length>0
          vgw.vpcId = vgw.attachments[0].vpcId
          vgw.attachmentState = vgw.attachments[0].state
      vgws
  }

  ### IGW ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrIgwCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.IGW
    modelIdAttribute : "internetGatewayId"
    parseFetchData : ( data )->
      igws = data.DescribeInternetGatewaysResponse.internetGatewaySet?.item
      for igw in igws || []
        igw.attachmentSet = igw.attachmentSet?.item || []
        igw.id = igw.internetGatewayId
        #delete igw.internetGatewayId
        if igw.attachmentSet and igw.attachmentSet.length>0
          igw.vpcId = igw.attachmentSet[0].vpcId
          igw.state = igw.attachmentSet[0].state
      igws
  }

  ### RTB ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrRtbCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.RT
    parseFetchData : ( data )->
      rtbs = data.DescribeRouteTablesResponse.routeTableSet?.item
      for rtb in rtbs || []
        rtb.routeSet = rtb.routeSet?.item || []
        rtb.associationSet = rtb.associationSet?.item || []
        rtb.propagatingVgwSet = rtb.propagatingVgwSet?.item || []
        rtb.id = rtb.routeTableId
        delete rtb.routeTableId
      rtbs
  }

  ### INSTANCE ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrInstanceCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.INSTANCE
    parseFetchData : ( data )->
      itemset = data.DescribeInstancesResponse.reservationSet
      if not itemset then return

      instances = []
      for i in itemset.item
        try
          for ami in i.instancesSet.item
            ami.blockDeviceMapping  = ami.blockDeviceMapping?.item || []
            ami.networkInterfaceSet = ami.networkInterfaceSet?.item || []
            ami.groupSet            = ami.groupSet?.item || []

            ami.id = ami.instanceId
            delete ami.instanceId
            instances.push ami
        catch e
          console.error "Fail to parse instance data", i

      instances
  }

  ### VOLUME ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVolumeCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VOL
    parseFetchData : ( data )->
      volumes = data.DescribeVolumesResponse.volumeSet?.item
      for vol in volumes || []
        vol.id = vol.volumeId
        delete vol.volumeId
        vol.attachmentSet = vol.attachmentSet?.item || []
        _.each vol.attachmentSet, (e,key)->
          status = vol.status
          attachmentStatus = e.status
          _.extend vol, e
          vol.status = status
          vol.attachmentStatus = attachmentStatus
        delete vol.attachmentSet
      volumes
  }

  ### LC ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrLcCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.LC
    AwsResponseType : "DescribeLaunchConfigurationsResponse"
    modelIdAttribute : "LaunchConfigurationARN"
    parseFetchData : ( data )->
      lcs = data.DescribeLaunchConfigurationsResponse.DescribeLaunchConfigurationsResult.LaunchConfigurations?.member
      for lc in lcs || []
        lc.BlockDeviceMappings = lc.BlockDeviceMappings?.member
        lc.SecurityGroups      = lc.SecurityGroups?.member
      lcs
  }

  ### ScalingPolicy ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrScalingPolicyCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.SP
    AwsResponseType : "DescribePoliciesResponse"
    modelIdAttribute : "PolicyARN"
    parseFetchData : ( data )-> data.DescribePoliciesResponse.DescribePoliciesResult.ScalingPolicies?.member
  }

  ### AvailabilityZone ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrAzCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.AZ
    AwsResponseType  : "DescribeAvailabilityZonesResponse"
    modelIdAttribute : "zoneName"
    parseFetchData : ( data )-> data.DescribeAvailabilityZonesResponse.availabilityZoneInfo?.item
  }


  ### NotificationConfiguartion ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrNotificationCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.NC
    AwsResponseType : "DescribeNotificationConfigurationsResponse"
    modelIdAttribute : "PolicyARN"
    parseFetchData : ( data )->
      ncs = data.DescribeNotificationConfigurationsResponse.DescribeNotificationConfigurationsResult.NotificationConfigurations?.member
      for nc in ncs || []
        nc.id = nc.TopicARN + ":" + nc.AutoScalingGroupName + ":" + nc.NotificationType
      ncs
  }


  ### ACL ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrAclCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.ACL
    AwsResponseType : "DescribeNetworkAclsResponse"
    parseFetchData : ( data )->
      acls = data.DescribeNetworkAclsResponse.networkAclSet?.item
      for acl in acls || []
        acl.id = acl.networkAclId
        delete acl.networkAclId
        acl.entrySet = acl.entrySet?.item || []
        acl.associationSet = acl.associationSet?.item || []
        if acl.associationSet.length > 0
          acl.subnetId = acl.associationSet[0].subnetId
      acls
  }

  ### ENI ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrEniCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.ENI
    modelIdAttribute : "networkInterfaceId"
    AwsResponseType : "DescribeNetworkInterfacesResponse"
    doFetch : ()-> ApiRequest("eni_DescribeNetworkInterfaces", {region_name : @region()})
    parseFetchData : ( data )->
      enis = data.DescribeNetworkInterfacesResponse.networkInterfaceSet?.item || []

      # Format Object in some typical data resource.
      # format attachment and groupSet in "ENI"
      _.each enis, (eni, index)->
          _.each eni, (e,key)->
            if key is "attachment"
              _.extend enis[index], e
            if key is "groupSet"
              _.extend enis[index], e.item[0]
            if key is "privateIpAddressesSet"
              enis[index].privateIpAddressesSet = enis[index].privateIpAddressesSet?.item || []
            # Remove All Object in data resource to remove [Object, Object]
            if _.isObject(e) and key isnt "privateIpAddressesSet"
              delete enis[index][key]
        enis
  }


  ### SUBNET ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSubnetCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.SUBNET
    modelIdAttribute : "subnetId"
    doFetch : ()-> ApiRequest("subnet_DescribeSubnets", {region_name : @region()})
    parseFetchData : ( data )-> data.DescribeSubnetsResponse.subnetSet?.item
  }

  ### SG ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSgCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.SG
    AwsResponseType : "DescribeSecurityGroupsResponse"
    doFetch : ()-> ApiRequest("sg_DescribeSecurityGroups", {region_name : @region()})
    parseFetchData : ( data )->
      sgs = data.DescribeSecurityGroupsResponse.securityGroupInfo?.item
      for sg in sgs || []
        sg.ipPermissions       = sg.ipPermissions?.item || []
        _.each sg.ipPermissions, (rule,idx)->
          _.each rule, (e,key)->
            if key in ["groups","ipRanges"]
              sg.ipPermissions[idx][key] = e?.item || []

        sg.ipPermissionsEgress = sg.ipPermissionsEgress?.item || []
        _.each sg.ipPermissionsEgress, (rule,idx)->
          _.each rule, (e,key)->
            if key in ["groups","ipRanges"]
              sg.ipPermissionsEgress[idx][key] = e?.item || []

        sg.id = sg.groupId
        delete sg.groupId
      sgs
  }

