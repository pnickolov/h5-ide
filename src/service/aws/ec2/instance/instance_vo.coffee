###
       Copyright 2012, Jimmy Xu <jimmy.xu@madeiracloud.com>
       Create at 2013-05-17 16:45:23
       Description : Value Object for EC2 Instance jsonrpc interface
       Comment     : The property name is same with aws return xml
###

define [], () ->

    #private
    instance = {
        securityGroups             : [] # Array of securityGroup Name
        instanceId                 : ""
        imageId                    : ""
        instanceState_code         : 0
        instanceState_name         : ""
        privateDnsName             : ""
        dnsName                    : ""
        reason                     : ""
        keyName                    : ""
        amiLaunchIndex             : 0
        productCodes               : ""
        instanceType               : ""
        launchTime                 : ""
        placement_availabilityZone : ""
        placement_groupName        : ""
        kernelId                   : ""
        monitoring_state           : ""
        privateIpAddress           : ""
        ipAddress                  : ""
        architecture               : ""
        rootDeviceType             : ""
        rootDeviceName             : ""
        blockDeviceMapping         : [] # type of BlockDeviceMappingVO
        virtualizationType         : ""
        clientToken                : ""
        tagSet                     : [] # type of TagSetVO
        hypervisor                 : ""
        disableApiTermination      : ""
        shutdownBehavior           : ""
        networkInterfaceSet        : []
        ebsOptimized               : ""
    }

    component = {
        type     : 'AWS.EC2.Instance'
        name     : ''
        state    : ''
        uid      : ''
        resource : {
            InstanceId            : ''
            ImageId               : ''
            KeyName               : '' #@UID2.Name'
            SecurityGroupId       : []
            SecurityGroup         : ''
            BlockDeviceMapping    : [] # [UID1,UID
            Monitoring            : ''
            InstanceType          : ''
            KernelId              : ''
            RamdiskId             : ''
            ShutdownBehavior      : ''
            DisableApiTermination : ''
            SourceDestCheck       : ''
            SubnetId              : ''
            VpcId                 : ''
            PrivateIpAddress      : ''
            Placement             :
                AvailabilityZone     :''
                GroupName            :''
                Tenancy              :''
            UserData              :''
            EbsOptimized          :''
            Platform              :''
        }
        software : {}
    }

    #public
    instance : instance