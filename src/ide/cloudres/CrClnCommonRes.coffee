
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
    # modelIdAttribute : "LoadBalancerName"

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
      @convertNumTimeToString data
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
  }

  ### EIP ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrEipCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.EIP
    modelIdAttribute : "allocationId"
    trAwsXml : ( data )-> data.DescribeAddressesResponse.addressesSet?.item
    # parseExternalData: ( data ) ->
    #   @unifyApi data, @type
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
        asg.id   = asg.AutoScalingGroupARN
        asg.Name = asg.AutoScalingGroupName
        #delete asg.AutoScalingGroupARN
        #delete asg.AutoScalingGroupName
        asg.AvailabilityZones   = asg.AvailabilityZones?.member || []
        asg.Instances           = asg.Instances?.member || []
        asg.LoadBalancerNames   = asg.LoadBalancerNames?.member || []
        asg.TerminationPolicies = asg.TerminationPolicies?.member || []
        asg.Subnets             = (asg.VPCZoneIdentifier || asg.VpczoneIdentifier).split(",")
        #delete asg.VPCZoneIdentifier
      asgs
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @camelToPascal data
      for asg in data
        asg.id   = asg.AutoScalingGroupARN
        asg.Name = asg.AutoScalingGroupName
        #delete asg.AutoScalingGroupARN
        #delete asg.AutoScalingGroupName
        asg.Subnets             = (asg.VPCZoneIdentifier || asg.VpczoneIdentifier).split(",")
        #delete asg.VPCZoneIdentifier
      data
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
      data
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
        if vgw.attachments and vgw.attachments.length>0
          vgw.vpcId = vgw.attachments[0].vpcId
          vgw.attachmentState = vgw.attachments[0].state
      vgws
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      for vgw in data
        if vgw.attachments and vgw.attachments.length>0
          vgw.vpcId = vgw.attachments[0].vpcId
          vgw.attachmentState = vgw.attachments[0].state
      data

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
        if igw.attachmentSet and igw.attachmentSet.length>0
          igw.vpcId = igw.attachmentSet[0].vpcId
          igw.state = igw.attachmentSet[0].state
      igws
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      for igw in data
        if igw.attachmentSet and igw.attachmentSet.length>0
          igw.vpcId = igw.attachmentSet[0].vpcId
          igw.state = igw.attachmentSet[0].state
      data

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
        rtb.routeSet = rtb.routeSet?.item || []
        rtb.associationSet = rtb.associationSet?.item || []
        rtb.propagatingVgwSet = rtb.propagatingVgwSet?.item []
        rtb.id = rtb.routeTableId
        #delete rtb.routeTableId
      rtbs
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      for rtb in data
        rtb.id = rtb.routeTableId
        #delete rtb.routeTableId
      data
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
      @convertNumTimeToString data
      @unifyApi data, @type

      for ins in data

        if ins.instanceState and ins.instanceState.name in [ "terminated", "shutting-down" ]
          continue
        ins.id = ins.instanceId

        for eni in ins.networkInterfaceSet
          if eni.privateIpAddresses
            eni.privateIpAddressesSet = {item: eni.privateIpAddresses}
            delete eni.privateIpAddresses
          if eni.groups
            eni.groupSet = {item: eni.groups}
            delete eni.groups

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
        #delete vol.volumeId
        vol.attachmentSet = vol.attachmentSet?.item || []
        _.each vol.attachmentSet, (e,key)->
          status = vol.status
          attachmentStatus = e.status
          _.extend vol, e
          vol.status = status
          vol.attachmentStatus = attachmentStatus
        #delete vol.attachmentSet
      volumes
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      for vol in data
        vol.id = vol.volumeId
        _.each vol.attachmentSet, (e,key)->
          status = vol.state
          attachmentStatus = e.state
          _.extend vol, e
          vol.status = status
          vol.attachmentStatus = attachmentStatus
      data
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
    parseFetchData : ( data )->
      for lc in data
        lc.id = lc.LaunchConfigurationARN
        lc.Name = lc.LaunchConfigurationName
        #delete lc.LaunchConfigurationARN
        #delete lc.LaunchConfigurationName
        lc.BlockDeviceMappings = lc.BlockDeviceMappings?.member || []
        lc.SecurityGroups      = lc.SecurityGroups?.member || []
      data

    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @camelToPascal data
      for lc in data
        lc.id = lc.LaunchConfigurationARN
        lc.Name = lc.LaunchConfigurationName
        #delete lc.LaunchConfigurationARN
        #delete lc.LaunchConfigurationName
      data
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
        #delete sp.PolicyName
      sps
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @camelToPascal data
      for sp in data
        sp.Name = sp.PolicyName
        #delete sp.PolicyName
      data
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
          AutoScalingGroupName: first.AutoScalingGroupName
          TopicARN: first.TopicARN
          NotificationType: _.pluck nc, 'NotificationType'
      newNcList

    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @camelToPascal data

      newNcList = []
      for nc in data
        first = nc[ 0 ]
        newNcList.push
          AutoScalingGroupName: first.AutoScalingGroupName
          TopicARN: first.TopicARN
          NotificationType: _.pluck nc, 'NotificationType'
      newNcList

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
            # if key is "attachment"
            #   _.extend enis[index], e
            if key is "groupSet"
              enis[index].groupSet = enis[index].groupSet?.item || []
            if key is "privateIpAddressesSet"
              enis[index].privateIpAddressesSet = enis[index].privateIpAddressesSet?.item || []

            # Remove All Object in data resource to remove [Object, Object]
            # if _.isObject(e) and key isnt "privateIpAddressesSet"
            #   delete enis[index][key]
        enis
    parseExternalData: ( data ) ->
      @convertNumTimeToString data
      @unifyApi data, @type
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
    # parseExternalData: ( data ) ->
    #   @unifyApi data, @type
      # @parseFetchData data
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
      for sg in sgs
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
        # delete sg.groupId
      sgs
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @convertNumTimeToString data

      for sg in data
        sg.ipPermissions = sg.ipPermissions || []
        sg.ipPermissionsEgress = sg.ipPermissionsEgress || []
        sgRuls = sg.ipPermissions.concat(sg.ipPermissionsEgress)
        _.each sgRuls, (rule, idx) ->
          if rule.ipRanges and rule.ipRanges.length
            rule.ipRanges = [{
              cidrIp: rule.ipRanges[0]
            }]
          rule.groups = []
          if rule.userIdGroupPairs
            rule.groups = rule.userIdGroupPairs
            delete rule.userIdGroupPairs
      data

      # @parseFetchData data
  }

