
define [ "../DesignAws", "constant" ], ( Design, constant )->

  # EniIpVisitor is an util function to allow Subnet to re-assign IPs for all Eni,
  # when serializing.

  prepareEniData = ( uid, eniArray )->
    subnet = Design.instance().component( uid )

    AzModel = Design.modelClassForType constant.RESTYPE.AZ

    console.assert subnet, "Cannot find eni's subnet when assigning Eni's ip."

    subnetCid = subnet.get("cidr")

    if not subnetCid
      console.error "Cannot found cidr when assigning Eni Ip"
      return

    ipSet        = []
    reserveIpSet = []

    # We always genarate new Ip for auto assign ips.
    for eni in eniArray
      for ip in eni.resource.PrivateIpAddressSet
        if ip.AutoAssign is true
          ipSet.push ip
        else
          reserveIpSet.push( ip.PrivateIpAddress )

    { subnetCid : subnetCid, ipSet : ipSet, reserveIpSet : reserveIpSet }


  generateIpForEnis = ( data )->
    validIpSet = Design.modelClassForType(constant.RESTYPE.ENI).getAvailableIPInCIDR( data.subnetCid, data.reserveIpSet, data.ipSet.length )

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
      if comp.type is constant.RESTYPE.ENI

        if comp.resource.SubnetId and comp.resource.SubnetId[0] is "@"
          key = comp.resource.SubnetId
        else
          key = comp.resource.AvailabilityZone

        array = subnetEnisMap[ key ]
        if not array
          array = subnetEnisMap[ key ] = []

        array.splice( _.sortedIndex( array, comp, "name" ), 0, comp )

    # 2. generate ips for all the Eni.
    for uid, eniArray of subnetEnisMap
      uid  = MC.extractID( uid )
      data = prepareEniData( uid, eniArray )
      if data
        generateIpForEnis( data )

    null

  null

