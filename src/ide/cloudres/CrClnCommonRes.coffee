
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

    trAwsXml : ( data )-> data.DescribeLoadBalancersResponse.DescribeLoadBalancersResult.LoadBalancerDescriptions?.member
    parseFetchData : ( elbs )->
      for elb in elbs
        for key, value of elb
          fixKey = key.substring(0,1).toUpperCase() + key.substring(1)
          delete elb[key]
          elb[fixKey] = value

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
    parseExternalData: ( data ) ->
      @camelToPascal data
      @unifyApi data, @type
      @convertBoolAndNumToString data
      _.each data, (dataItem) ->
        dataItem.Instances = _.map dataItem.Instances, (obj) ->
          return obj.InstanceId
        dataItem.ListenerDescriptions = _.map dataItem.ListenerDescriptions, (obj) ->
          obj.PolicyNames = {
            member: obj.PolicyNames
          }
          return obj
      return data
      # @parseFetchData data

  }

  ### VPN ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVpnCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VPN
    modelIdAttribute : "vpnConnectionId"

    trAwsXml : ( data )-> data.DescribeVpnConnectionsResponse.vpnConnectionSet?.item
    parseFetchData : ( vpns )->
      for vpn in vpns || []
        vpn.vgwTelemetry = vpn.vgwTelemetry?.item || []
      vpns
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### EIP ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrEipCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.EIP
    modelIdAttribute : "allocationId"
    trAwsXml : ( data )-> data.DescribeAddressesResponse.addressesSet?.item
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### VPC ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVpcCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VPC
    modelIdAttribute : "vpcId"
    trAwsXml : ( data )-> data.DescribeVpcsResponse.vpcSet?.item
    # parseExternalData: ( data ) ->
    #   @unifyApi data, @type
      #@parseFetchData data
  }

  ### ASG ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrAsgCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.ASG
    modelIdAttribute : "AutoScalingGroupARN"
    trAwsXml : ( data )-> data.DescribeAutoScalingGroupsResponse.DescribeAutoScalingGroupsResult.AutoScalingGroups?.member
    parseFetchData : ( asgs )->
      for asg in asgs
        asg.Name = asg.AutoScalingGroupName
        delete asg.AutoScalingGroupName
        asg.AvailabilityZones   = asg.AvailabilityZones || []
        asg.Instances           = asg.Instances || []
        asg.LoadBalancerNames   = asg.LoadBalancerNames || []
        asg.TerminationPolicies = asg.TerminationPolicies || []
        asg.Subnets             = (asg.VPCZoneIdentifier || asg.VpczoneIdentifier).split(",")
        delete asg.VPCZoneIdentifier
      asgs
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### CloudWatch ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrCloudwatchCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.CW
    trAwsXml : ( data )-> data.DescribeAlarmsResponse.DescribeAlarmsResult.MetricAlarms?.member
    parseFetchData : ( cws )->
      for cw in cws
        for key, value of cw
          fixKey = key.substring(0,1).toUpperCase() + key.substring(1)
          delete cw[key]
          cw[fixKey] = value

        cw.Dimensions   = cw.Dimensions || []
        cw.AlarmActions = cw.AlarmActions || []
        cw.id   = cw.AlarmArn
        cw.Name = cw.AlarmName
        delete cw.AlarmArn
        delete cw.AlarmName

      cws
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### CGW ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrCgwCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.CGW
    modelIdAttribute : "customerGatewayId"
    trAwsXml : ( data )-> data.DescribeCustomerGatewaysResponse.customerGatewaySet?.item
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### VGW ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVgwCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VGW
    modelIdAttribute : "vpnGatewayId"
    trAwsXml : ( data )-> data.DescribeVpnGatewaysResponse.vpnGatewaySet?.item
    parseFetchData : ( vgws )->
      for vgw in vgws
        if vgw.vpcAttachments
          vgw.attachments = vgw.vpcAttachments || []
        else if vgw.attachments
          vgw.attachments = vgw.attachments?.item || []
        else
          continue

        vgw.id = vgw.vpnGatewayId
        if vgw.attachments and vgw.attachments.length>0
          vgw.vpcId = vgw.attachments[0].vpcId
          vgw.attachmentState = vgw.attachments[0].state
      vgws
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### IGW ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrIgwCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.IGW
    modelIdAttribute : "internetGatewayId"
    trAwsXml : ( data )-> data.DescribeInternetGatewaysResponse.internetGatewaySet?.item
    parseFetchData : ( igws )->
      for igw in igws
        igw.attachmentSet = igw.attachmentSet?.item || igw.attachments ||[]
        igw.id = igw.internetGatewayId
        #delete igw.internetGatewayId
        if igw.attachmentSet and igw.attachmentSet.length>0
          igw.vpcId = igw.attachmentSet[0].vpcId
          igw.state = igw.attachmentSet[0].state
      igws
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### RTB ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrRtbCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.RT
    trAwsXml : ( data )-> data.DescribeRouteTablesResponse.routeTableSet?.item
    parseFetchData : ( rtbs )->
      for rtb in rtbs
        rtb.routeSet = rtb.routeSet?.item || rtb.routes || []
        rtb.associationSet = rtb.associationSet?.item || []
        rtb.propagatingVgwSet = rtb.propagatingVgwSet?.item ||rtb.propagatingVgws|| []
        rtb.id = rtb.routeTableId
        delete rtb.routeTableId
      rtbs
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### INSTANCE ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrInstanceCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.INSTANCE
    trAwsXml : ( data )->
      instances = []
      for i in data.DescribeInstancesResponse.reservationSet?.item || []
        for ins in i.instancesSet?.item || []
          instances.push ins

      instances

    parseFetchData : ( data )->
      for ins in data
        if ins.instanceState and ins.instanceState.name in [ "terminated", "shutting-down" ]
          continue
        ins.blockDeviceMapping  = ins.blockDeviceMapping?.item || []
        ins.networkInterfaceSet = ins.networkInterfaceSet?.item || []
        ins.groupSet            = ins.groupSet?.item || []
        ins.id = ins.instanceId
        #delete ins.instanceId
      data
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      for ins in data
        if ins.instanceState and ins.instanceState.name in [ "terminated", "shutting-down" ]
          continue
        ins.id = ins.instanceId
        #delete ins.instanceId
      data
  }

  ### VOLUME ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVolumeCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VOL
    trAwsXml : ( data )-> data.DescribeVolumesResponse.volumeSet?.item
    parseFetchData : ( volumes )->
      for vol in volumes
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
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      #_.each data, (dataItem) ->
      #@parseFetchData data
  }

  ### LC ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrLcCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.LC
    AwsResponseType : "DescribeLaunchConfigurationsResponse"
    modelIdAttribute : "LaunchConfigurationARN"
    trAwsXml : ( data )-> data.DescribeLaunchConfigurationsResponse.DescribeLaunchConfigurationsResult.LaunchConfigurations?.member
    parseFetchData : ( lcs )->
      for lc in lcs
        for key, value of lc
            fixKey = key.substring(0,1).toUpperCase() + key.substring(1)
            lc[fixKey] = value
            delete lc[key]

        lc.Name = lc.LaunchConfigurationName
        delete lc.LaunchConfigurationName
        lc.BlockDeviceMappings = lc.BlockDeviceMappings?.member or lc.BlockDeviceMappings
        lc.SecurityGroups      = lc.SecurityGroups?.member or lc.SecurityGroups
      lcs

    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data

  }

  ### ScalingPolicy ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrScalingPolicyCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.SP
    AwsResponseType : "DescribePoliciesResponse"
    modelIdAttribute : "PolicyARN"
    trAwsXml : ( data )-> data.DescribePoliciesResponse.DescribePoliciesResult.ScalingPolicies?.member
    parseFetchData : ( sps )->
      for sp in sps
        sp.Name = sp.PolicyName
        delete sp.PolicyName
      sps
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### AvailabilityZone ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrAzCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.AZ
    AwsResponseType  : "DescribeAvailabilityZonesResponse"
    modelIdAttribute : "zoneName"
    trAwsXml : ( data )-> data.DescribeAvailabilityZonesResponse.availabilityZoneInfo?.item
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }


  ### NotificationConfiguartion ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrNotificationCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.NC
    AwsResponseType : "DescribeNotificationConfigurationsResponse"
    trAwsXml : ( data )-> data.DescribeNotificationConfigurationsResponse.DescribeNotificationConfigurationsResult.NotificationConfigurations?.member
    parseFetchData : ( ncs )->
      newNcList = []

      for nc in ncs
        first = nc[ 0 ]
        newNcList.push
          AutoScalingGroupName: first.autoScalingGroupName
          TopicARN: first.topicARN
          NotificationType: _.pluck nc, 'notificationType'

      newNcList
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }


  ### ACL ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrAclCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.ACL
    AwsResponseType : "DescribeNetworkAclsResponse"
    trAwsXml : ( data )-> data.DescribeNetworkAclsResponse.networkAclSet?.item
    parseFetchData : ( acls )->
      for acl in acls
        acl.id = acl.networkAclId
        #delete acl.networkAclId
        acl.entrySet = acl.entrySet?.item || []
        acl.associationSet = acl.associationSet?.item || []
        if acl.associationSet.length > 0
          acl.subnetId = acl.associationSet[0].subnetId
      acls
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      for acl in data
        acl.id = acl.networkAclId
        #delete acl.networkAclId
        if acl.associationSet.length > 0
          acl.subnetId = acl.associationSet[0].subnetId
      data
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
    trAwsXml : ( data )-> data.DescribeNetworkInterfacesResponse.networkInterfaceSet?.item
    parseFetchData : ( enis )->
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
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      #@parseFetchData data
  }


  ### SUBNET ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSubnetCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.SUBNET
    modelIdAttribute : "subnetId"
    doFetch : ()-> ApiRequest("subnet_DescribeSubnets", {region_name : @region()})
    trAwsXml : ( data )-> data.DescribeSubnetsResponse.subnetSet?.item
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

  ### SG ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSgCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.SG
    AwsResponseType : "DescribeSecurityGroupsResponse"
    doFetch : ()-> ApiRequest("sg_DescribeSecurityGroups", {region_name : @region()})
    trAwsXml : ( data )-> data.DescribeSecurityGroupsResponse.securityGroupInfo?.item
    parseFetchData : ( sgs )->
      # for sg in sgs
        # sg.ipPermissions       = sg.ipPermissions?.item || []
        # _.each sg.ipPermissions, (rule,idx)->
        #   _.each rule, (e,key)->
        #     if key in ["groups","ipRanges"]
        #       sg.ipPermissions[idx][key] = e?.item || []

        # sg.ipPermissionsEgress = sg.ipPermissionsEgress?.item || []
        # _.each sg.ipPermissionsEgress, (rule,idx)->
        #   _.each rule, (e,key)->
        #     if key in ["groups","ipRanges"]
        #       sg.ipPermissionsEgress[idx][key] = e?.item || []

        # sg.id = sg.groupId
        # delete sg.groupId
      sgs
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @parseFetchData data
  }

