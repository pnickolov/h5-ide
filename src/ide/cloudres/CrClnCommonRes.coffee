
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
      data.DescribeLoadBalancersResponse.DescribeLoadBalancersResult.LoadBalancerDescriptions?.member
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
    parseFetchData : ( data )-> data.DescribeVolumesResponse.volumeSet?.item
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

      instances
  }

