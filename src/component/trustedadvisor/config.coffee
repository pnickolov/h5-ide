define({

    validDebug: ''

    syncTimeout: 10000

    componentTypeToFileMap:
        'AWS.AutoScaling.Group'     : 'asg'
        'AWS.EC2.SecurityGroup'     : 'sg'
        'AWS.VPC.VPNGateway'        : 'vpn'
        'AWS.VPC.InternetGateway'   : 'igw'
        'AWS.EC2.Instance'          : 'instance'
        'AWS.ELB'                   : 'elb'
        'AWS.VPC.NetworkInterface'  : 'eni'
        'AWS.VPC.NetworkAcl'        : 'acl'

    globalList:
        eip: [ 'isHasIGW' ]
        az: [ 'isAZAlone' ]
        sg: [ 'isStackUsingOnlyOneSG', 'isAssociatedSGNumExceedLimit' ]
        vpc: [ 'isVPCAbleConnectToOutside' ]
        stack: [ '~isHaveNotExistAMI' ] # `~` means work in stack mode only.

    asyncList:
        cgw: [ 'isCGWHaveIPConflict' ]
        stack: [ 'verify', 'isHaveNotExistAMIAsync' ]
        subnet: ['getAllAWSENIForAppEditAndDefaultVPC']
})
