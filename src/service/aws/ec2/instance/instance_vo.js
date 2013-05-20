/*
       Copyright 2012, Jimmy Xu <jimmy.xu@madeiracloud.com>
       Create at 2013-05-17 16:45:23
       Description : Value Object for EC2 Instance jsonrpc interface
       Comment     : The property name is same with aws return xml
*/


(function() {
  define([], function() {
    var component, instance;

    instance = {
      securityGroups: [],
      instanceId: "",
      imageId: "",
      instanceState_code: 0,
      instanceState_name: "",
      privateDnsName: "",
      dnsName: "",
      reason: "",
      keyName: "",
      amiLaunchIndex: 0,
      productCodes: "",
      instanceType: "",
      launchTime: "",
      placement_availabilityZone: "",
      placement_groupName: "",
      kernelId: "",
      monitoring_state: "",
      privateIpAddress: "",
      ipAddress: "",
      architecture: "",
      rootDeviceType: "",
      rootDeviceName: "",
      blockDeviceMapping: [],
      virtualizationType: "",
      clientToken: "",
      tagSet: [],
      hypervisor: "",
      disableApiTermination: "",
      shutdownBehavior: "",
      networkInterfaceSet: [],
      ebsOptimized: ""
    };
    component = {
      type: 'AWS.EC2.Instance',
      name: '',
      state: '',
      uid: '',
      resource: {
        InstanceId: '',
        ImageId: '',
        KeyName: '',
        SecurityGroupId: [],
        SecurityGroup: '',
        BlockDeviceMapping: [],
        Monitoring: '',
        InstanceType: '',
        KernelId: '',
        RamdiskId: '',
        ShutdownBehavior: '',
        DisableApiTermination: '',
        SourceDestCheck: '',
        SubnetId: '',
        VpcId: '',
        PrivateIpAddress: '',
        Placement: {
          AvailabilityZone: '',
          GroupName: '',
          Tenancy: ''
        },
        UserData: '',
        EbsOptimized: '',
        Platform: ''
      },
      software: {}
    };
    return {
      instance: instance
    };
  });

}).call(this);
