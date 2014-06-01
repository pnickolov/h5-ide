
define [
  "./CrCommonCollection"
  "ApiRequest"
  "constant"
], ( CrCommonCollection, ApiRequest, constant )->

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
        for i, idx in elb.Instances
          elb.Instances[ idx ] = i.InstanceId
      elbs
  }

  ### VPN ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVpnCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VPN
    modelIdAttribute : "vpnConnectionId"
    parseFetchData : ( data )-> data.DescribeVpnConnectionsResponse.vpnConnectionSet?.item
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

  ### VOLUME ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrVolumeCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.VOL
    modelIdAttribute : "volumeId"
    parseFetchData : ( data )->
      volumes = data.DescribeVolumesResponse.volumeSet?.item
      for vol in volumes || []
        vol.attachmentSet = vol.attachmentSet?.item || []
      volumes
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
    ClassName : "CrCloudWatchCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.ASG
    modelIdAttribute : "AutoScalingGroupARN"
    parseFetchData : ( data )->
      asgs = data.DescribeAutoScalingGroupsResponse.DescribeAutoScalingGroupsResult.AutoScalingGroups?.member
      for asg in asgs ||[]
        asg.AvailabilityZones   = asg.AvailabilityZones?.member || []
        asg.Instances           = asg.Instances?.member || []
        asg.TerminationPolicies = asg.TerminationPolicies?.member || []
      asgs
  }

  ### CloudWatch ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrAsgCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.CW
    modelIdAttribute : "AlarmArn"
    parseFetchData : ( data )->
      cws = data.DescribeAlarmsResponse.DescribeAlarmsResult.MetricAlarms?.member
      for cw in cws || []
        cw.Dimensions = cw.Dimensions?.member || []
      cws
  }

  ### AMI ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrAmiCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.INSTANCE
    modelIdAttribute : "instanceId"
    parseFetchData : ( data )->
      itemset = data.DescribeInstancesResponse.reservationSet
      if not itemset then return

      instances = []
      for i in itemset.item
        try
          for ami in i.instancesSet.item
            instances.push ami
        catch e
          console.error "Fail to parse instance data", i

      for ami in instances
        ami.blockDeviceMapping  = ami.blockDeviceMapping?.item || []
        ami.networkInterfaceSet = ami.networkInterfaceSet?.item || []
        ami.groupSet            = ami.groupSet?.item || []

      instances
  }

