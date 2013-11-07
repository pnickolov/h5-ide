define({

    validDebug: ''

    syncTimeout: 10000

    componentTypeToFileMap:
        'AWS.AutoScaling.Group'     : 'asg'
        'AWS.EC2.SecurityGroup'     : 'sg'
        'AWS.VPC.VPNGateway'        : 'vpn'
        'AWS.VPC.InternetGateway'   : 'igw'
        'AWS.VPC.RouteTable'        : 'rtb'
        'AWS.EC2.Instance'          : 'instance'
        'AWS.ELB'                   : 'elb'
        'AWS.VPC.NetworkInterface'  : 'eni'

    globalList:
        eip: [ 'isHasIGW' ]
        az: [ 'isAZAlone' ]
        sg: [ 'isStackUsingOnlyOneSG', 'isAssociatedSGNumExceedLimit' ]
        vpc: [ 'isVPCAbleConnectToOutside' ]

    asyncList:
        cgw: [ 'isCGWHaveIPConflict' ]
        stack: [ 'verify' ]

})
