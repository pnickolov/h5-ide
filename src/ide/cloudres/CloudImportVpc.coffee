
define ["CloudResources", "ide/cloudres/CrCollection", "constant", "ApiRequest"], ( CloudResources, CrCollection, constant, ApiRequest )->

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
    ]

    # When we get all the asgs and subnets, we can start loading other resources.
    # Including SecurityGroup, Acl, Eni, Lc, NotificationConfiguration, ScalingPolicy
    requests.push Q.all([
      CloudResources( RESTYPE.SUBNET, region ).fetch()
      CloudResources( RESTYPE.ASG, region ).fetch()
    ]).then ()->
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

      # Aquire additional resources. Returns a promise here, so that getAllResourcesForVpc() will
      # Wait until this request is done.
      ApiRequest("aws_resource", {
        region_name : region
        resources   : additionalRequestParam
        addition    : "all"
        retry_times : 1
      }).then ( data )->
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

    Q.all( requests ).then ()->
      # Gather all the resources that are in the vpc.
      console.log [
        RESTYPE.SG
        RESTYPE.ACL
        RESTYPE.ENI
        RESTYPE.NC
        RESTYPE.LC
        RESTYPE.SP
      ].map ( t )-> CloudResources( t, region )
