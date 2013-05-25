#*************************************************************************************
#* Filename     : instance_vo.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 13:33:47
#* Description  : vo define for instance
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [], () ->

    #vo declaration
    #TO-DO
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

    #public
    #TO-DO

