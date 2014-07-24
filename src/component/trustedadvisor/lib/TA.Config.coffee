define({

    validDebug: ''

    syncTimeout: 10000

    componentTypeToFileMap:
        'AWS.AutoScaling.Group'                 : [ 'asg' ]
        'AWS.EC2.SecurityGroup'                 : [ 'sg' ]
        'AWS.VPC.VPNGateway'                    : [ 'vgw' ]
        'AWS.VPC.VPNConnection'                 : [ 'vpn' ]
        'AWS.VPC.CustomerGateway'               : [ 'cgw' ]
        'AWS.VPC.InternetGateway'               : [ 'igw' ]
        'AWS.EC2.Instance'                      : [ 'instance', 'state' ]
        'AWS.ELB'                               : [ 'elb' ]
        'AWS.VPC.NetworkInterface'              : [ 'eni' ]
        'AWS.VPC.NetworkAcl'                    : [ 'acl' ]
        'AWS.AutoScaling.LaunchConfiguration'   : [ 'state' ]
        'AWS.VPC.RouteTable'                    : [ 'rtb' ]
        'AWS.EC2.EBS.Volume'                    : [ 'ebs' ]
        'AWS.EC2.KeyPair'                       : [ 'kp' ]

    globalList:
        eip: [ 'isHasIGW' ]
        az: [ 'isAZAlone' ]
        sg: [ 'isStackUsingOnlyOneSG', 'isAssociatedSGNumExceedLimit' ]
        vpc: [ 'isVPCAbleConnectToOutside' ]
        stack: [ '~isHaveNotExistAMI' ] # `~` means work in stack mode only.
        kp: [ 'longLiveNotice' ]

    asyncList:
        cgw: [ 'isCGWHaveIPConflict' ]
        stack: [ 'verify', 'isHaveNotExistAMIAsync' ]
        subnet: [ 'getAllAWSENIForAppEditAndDefaultVPC' ]
        ebs: [ 'isSnapshotExist' ]
        kp: [ 'isKeyPairExistInAws' ]
        elb: [ 'isSSLCertExist' ]
        asg: [ 'isTopicNonexist' ]
        vpc: [ 'isVPCUsingNonexistentDhcp' ]
        og: [ 'unusedOgWontCreate' ]


})
