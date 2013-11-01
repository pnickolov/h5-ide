define({

    validDebug: ''

    componentTypeToFileMap:
        'AWS.AutoScaling.Group'     : 'asg'
        'AWS.EC2.SecurityGroup'     : 'sg'
        'AWS.VPC.VPNGateway'        : 'vpn'
        'AWS.VPC.VPNGateway'        : 'vpn'
        'AWS.VPC.InternetGateway'   : 'igw'
        'AWS.VPC.RouteTable'        : 'rtb'

    globalList:
        eip: [ 'isHasIGW' ]
        az: [ 'isAZAlone' ]

    asyncList:
        cgw: [ 'isCGWHaveIPConflict' ]


})
