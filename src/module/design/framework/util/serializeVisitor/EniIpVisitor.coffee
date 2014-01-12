
define [ "Design", "constant" ], ( Design, constant )->

  # EniIpVisitor is an util function to allow Subnet to re-assign IPs for all Eni,
  # when deserializing.

  prepareEniData = ( uid, eniArray )->
    subnetCid = Design.instance().component( uid ).get("cidr")

    ipSet        = []
    reserveIpSet = []

    if Design.instance().modeIsStack()
      # In stack mode, we always genarate new Ip for auto assign ips.
      for eni in eniArray
        for ip in eni.resource.PrivateIpAddressSet
          if ip.AutoAssign is true
            ipSet.push ip
          else
            reserveIpSet.push( ip.PrivateIpAddress )

    else
      for eni in eniArray
        for ip in eni.resource.PrivateIpAddressSet
          if ip.PrivateIpAddress is "x.x.x.x"
            ipSet.push ip
          else
            reserveIpSet.push( ip.PrivateIpAddress )

    { subnetCid : subnetCid, ipSet : ipSet, reserveIpSet : reserveIpSet }


  generateIpForEnis = ( data )->
    validIpSet = MC.aws.eni.getAvailableIPInCIDR( data.subnetCid, data.reserveIpSet, data.ipSet.length )

    validIpSet = _.filter validIpSet, ( ip )-> ip.available

    for ip, idx in data.ipSet
      if validIpSet[idx]
        ip.PrivateIpAddress = validIpSet[ idx ].ip
      else
        ip.PrivateIpAddress = ""
    null

  Design.registerSerializeVisitor ( components )->

    # Do nothing in app mode
    if Design.instance().modeIsApp() then return

    subnetEnisMap = {}

    # 1. collect all Eni and classify them by its subnet
    for uid, comp of components
      if comp.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
        array = subnetEnisMap[ comp.resource.SubnetId ]
        if not array
          array = subnetEnisMap[ comp.resource.SubnetId ] = []

        array.splice( _.sortedIndex( array, comp, "name" ), 0, comp )

    # 2. generate ips for all the Eni.
    for uid, eniArray of subnetEnisMap
      uid  = MC.extractID( uid )
      data = prepareEniData( uid, eniArray )
      generateIpForEnis( data )

    null

  null

