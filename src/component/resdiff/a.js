define ( [], function() {
    return {
  "agent": {
    "enabled": true,
    "module": {
      "repo": "https://github.com/MadeiraCloud/salt.git",
      "tag": "v2014-04-15"
    }
  },
  "id": "stack-4285e4c7",
  "name": "untitled-15",
  "region": "us-east-1",
  "platform": "ec2-vpc",
  "version": "2014-02-17",
  "component": {
    "B1648523-2C81-4868-B985-F83317861A26": {
      "name": "DefaultACL",
      "type": "AWS.VPC.NetworkAcl",
      "uid": "B1648523-2C81-4868-B985-F83317861A26",
      "resource": {
        "AssociationSet": [
          {
            "NetworkAclAssociationId": "",
            "SubnetId": "@{B6C491EA-E696-4532-AA3E-78E4899CCEDA.resource.SubnetId}"
          }
        ],
        "Default": true,
        "EntrySet": [
          {
            "Egress": true,
            "Protocol": -1,
            "RuleAction": "allow",
            "RuleNumber": 100,
            "CidrBlock": "0.0.0.0/0",
            "IcmpTypeCode": {
              "Code": "",
              "Type": ""
            },
            "PortRange": {
              "From": "",
              "To": ""
            }
          },
          {
            "Egress": true,
            "Protocol": -1,
            "RuleAction": "deny",
            "RuleNumber": 32767,
            "CidrBlock": "0.0.0.0/0",
            "IcmpTypeCode": {
              "Code": "",
              "Type": ""
            },
            "PortRange": {
              "From": "",
              "To": ""
            }
          },
          {
            "Egress": false,
            "Protocol": -1,
            "RuleAction": "allow",
            "RuleNumber": 100,
            "CidrBlock": "0.0.0.0/0",
            "IcmpTypeCode": {
              "Code": "",
              "Type": ""
            },
            "PortRange": {
              "From": "",
              "To": ""
            }
          },
          {
            "Egress": false,
            "Protocol": -1,
            "RuleAction": "deny",
            "RuleNumber": 32767,
            "CidrBlock": "0.0.0.0/0",
            "IcmpTypeCode": {
              "Code": "",
              "Type": ""
            },
            "PortRange": {
              "From": "",
              "To": ""
            }
          }
        ],
        "NetworkAclId": "",
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}"
      }
    },
    "2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9": {
      "name": "vpc",
      "type": "AWS.VPC.VPC",
      "uid": "2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9",
      "resource": {
        "EnableDnsSupport": true,
        "InstanceTenancy": "default",
        "EnableDnsHostnames": false,
        "DhcpOptionsId": "",
        "VpcId": "",
        "CidrBlock": "10.0.0.0/16"
      }
    },
    "F7B14373-F8FD-403B-AA9D-FF4DB0BAB5AF": {
      "name": "RT-0",
      "type": "AWS.VPC.RouteTable",
      "uid": "F7B14373-F8FD-403B-AA9D-FF4DB0BAB5AF",
      "resource": {
        "PropagatingVgwSet": [],
        "RouteTableId": "",
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "AssociationSet": [
          {
            "Main": "true",
            "RouteTableAssociationId": "",
            "SubnetId": ""
          }
        ],
        "RouteSet": [
          {
            "Origin": "CreateRouteTable",
            "DestinationCidrBlock": "10.0.0.0/16",
            "InstanceId": "",
            "NetworkInterfaceId": "",
            "GatewayId": "local"
          }
        ]
      }
    },
    "DB21A1D2-3DF3-4E30-8830-8870CB4D2FC9": {
      "name": "DefaultKP",
      "type": "AWS.EC2.KeyPair",
      "uid": "DB21A1D2-3DF3-4E30-8830-8870CB4D2FC9",
      "resource": {
        "KeyFingerprint": "",
        "KeyName": ""
      }
    },
    "6F6F58B0-4529-415C-9C0A-D218A7FB641B": {
      "name": "DefaultSG",
      "type": "AWS.EC2.SecurityGroup",
      "uid": "6F6F58B0-4529-415C-9C0A-D218A7FB641B",
      "resource": {
        "Default": true,
        "GroupId": "",
        "GroupName": "DefaultSG",
        "GroupDescription": "default VPC security group",
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "IpPermissions": [
          {
            "FromPort": "22",
            "ToPort": "22",
            "IpRanges": "0.0.0.0/0",
            "IpProtocol": "tcp"
          }
        ],
        "IpPermissionsEgress": [
          {
            "FromPort": "0",
            "ToPort": "65535",
            "IpRanges": "0.0.0.0/0",
            "IpProtocol": "-1"
          },
          {
            "FromPort": "0",
            "ToPort": "65535",
            "IpRanges": "@{6F6F58B0-4529-415C-9C0A-D218A7FB641B.resource.GroupId}",
            "IpProtocol": "-1"
          }
        ]
      }
    },
    "AC3BBD64-DECB-485F-8C0A-664058A1D533": {
      "uid": "AC3BBD64-DECB-485F-8C0A-664058A1D533",
      "name": "us-east-1a",
      "type": "AWS.EC2.AvailabilityZone",
      "resource": {
        "ZoneName": "us-east-1a",
        "RegionName": "us-east-1"
      }
    },
    "B6C491EA-E696-4532-AA3E-78E4899CCEDA": {
      "name": "subnet0",
      "type": "AWS.VPC.Subnet",
      "uid": "B6C491EA-E696-4532-AA3E-78E4899CCEDA",
      "resource": {
        "AvailabilityZone": "@{AC3BBD64-DECB-485F-8C0A-664058A1D533.resource.ZoneName}",
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "SubnetId": "",
        "CidrBlock": "10.0.0.0/24"
      }
    },
    "C366FD4E-C68F-4976-BD95-27557CF782E1": {
      "type": "AWS.EC2.Instance",
      "uid": "C366FD4E-C68F-4976-BD95-27557CF782E1",
      "name": "host-1",
      "index": 0,
      "number": 1,
      "serverGroupUid": "C366FD4E-C68F-4976-BD95-27557CF782E1",
      "serverGroupName": "host-1",
      "state": null,
      "resource": {
        "UserData": {
          "Base64Encoded": false,
          "Data": ""
        },
        "BlockDeviceMapping": [
          {
            "DeviceName": "/dev/sda1",
            "Ebs": {
              "SnapshotId": "snap-ef432332",
              "VolumeSize": 8,
              "VolumeType": "standard"
            }
          }
        ],
        "Placement": {
          "Tenancy": "",
          "AvailabilityZone": "@{AC3BBD64-DECB-485F-8C0A-664058A1D533.resource.ZoneName}"
        },
        "InstanceId": "",
        "ImageId": "ami-178e927e",
        "KeyName": "@{DB21A1D2-3DF3-4E30-8830-8870CB4D2FC9.resource.KeyName}",
        "EbsOptimized": false,
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "SubnetId": "@{B6C491EA-E696-4532-AA3E-78E4899CCEDA.resource.SubnetId}",
        "Monitoring": "disabled",
        "NetworkInterface": [],
        "InstanceType": "m1.small",
        "DisableApiTermination": false,
        "ShutdownBehavior": "terminate",
        "SecurityGroup": [],
        "SecurityGroupId": []
      }
    },
    "31A47A3B-336F-45E0-A6ED-23E696801EE3": {
      "index": 0,
      "uid": "31A47A3B-336F-45E0-A6ED-23E696801EE3",
      "type": "AWS.VPC.NetworkInterface",
      "name": "host-1-eni0",
      "serverGroupUid": "31A47A3B-336F-45E0-A6ED-23E696801EE3",
      "serverGroupName": "eni0",
      "number": 1,
      "resource": {
        "SourceDestCheck": false,
        "Description": "",
        "NetworkInterfaceId": "",
        "AvailabilityZone": "@{AC3BBD64-DECB-485F-8C0A-664058A1D533.resource.ZoneName}",
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "SubnetId": "@{B6C491EA-E696-4532-AA3E-78E4899CCEDA.resource.SubnetId}",
        "AssociatePublicIpAddress": true,
        "PrivateIpAddressSet": [
          {
            "PrivateIpAddress": "10.0.0.4",
            "AutoAssign": true,
            "Primary": true
          },
          {
            "PrivateIpAddress": "10.0.0.5",
            "AutoAssign": true,
            "Primary": false
          }
        ],
        "GroupSet": [
          {
            "GroupName": "@{6F6F58B0-4529-415C-9C0A-D218A7FB641B.resource.GroupName}",
            "GroupId": "@{6F6F58B0-4529-415C-9C0A-D218A7FB641B.resource.GroupId}"
          }
        ],
        "Attachment": {
          "InstanceId": "@{C366FD4E-C68F-4976-BD95-27557CF782E1.resource.InstanceId}",
          "DeviceIndex": "0",
          "AttachmentId": ""
        }
      }
    },
    "C4E7CEA6-EB4B-4119-9598-6B8DC470D5C7": {
      "type": "AWS.ELB",
      "uid": "C4E7CEA6-EB4B-4119-9598-6B8DC470D5C7",
      "name": "load-balancer-0",
      "resource": {
        "AvailabilityZones": [],
        "Subnets": [
          "@{B6C491EA-E696-4532-AA3E-78E4899CCEDA.resource.SubnetId}"
        ],
        "Instances": [
          {
            "InstanceId": "@{C366FD4E-C68F-4976-BD95-27557CF782E1.resource.InstanceId}"
          }
        ],
        "CrossZoneLoadBalancing": true,
        "ConnectionDraining": {
          "Enabled": false,
          "Timeout": null
        },
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "LoadBalancerName": "load-balancer-0",
        "SecurityGroups": [
          "@{41826953-5CF6-40A4-9283-9454F4A6A343.resource.GroupId}"
        ],
        "Scheme": "internal",
        "ListenerDescriptions": [
          {
            "PolicyNames": "",
            "Listener": {
              "LoadBalancerPort": "80",
              "Protocol": "HTTP",
              "InstanceProtocol": "HTTP",
              "InstancePort": "80",
              "SSLCertificateId": ""
            }
          }
        ],
        "HealthCheck": {
          "Interval": "30",
          "Target": "HTTP:80/index.html",
          "Timeout": "5",
          "HealthyThreshold": "9",
          "UnhealthyThreshold": "4"
        },
        "DNSName": "",
        "Policies": {
          "LBCookieStickinessPolicies": [
            {
              "PolicyName": "",
              "CookieExpirationPeriod": ""
            }
          ],
          "AppCookieStickinessPolicies": [
            {
              "PolicyName": "",
              "CookieName": ""
            }
          ],
          "OtherPolicies": []
        },
        "BackendServerDescriptions": [
          {
            "InstantPort": "",
            "PoliciyNames": ""
          }
        ]
      }
    },
    "41826953-5CF6-40A4-9283-9454F4A6A343": {
      "name": "elbsg-load-balancer-0",
      "type": "AWS.EC2.SecurityGroup",
      "uid": "41826953-5CF6-40A4-9283-9454F4A6A343",
      "resource": {
        "Default": false,
        "GroupId": "",
        "GroupName": "elbsg-load-balancer-0",
        "GroupDescription": "Automatically created SG for load-balancer",
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "IpPermissions": [
          {
            "FromPort": "22",
            "ToPort": "22",
            "IpRanges": "0.0.0.0/0",
            "IpProtocol": "tcp"
          }
        ],
        "IpPermissionsEgress": [
          {
            "FromPort": "0",
            "ToPort": "65535",
            "IpRanges": "@{6F6F58B0-4529-415C-9C0A-D218A7FB641B.resource.GroupId}",
            "IpProtocol": "-1"
          }
        ]
      }
    },
    "67C60AAD-517D-4B98-8EE8-FB46D0526C7B": {
      "name": "Internet-gateway",
      "type": "AWS.VPC.InternetGateway",
      "uid": "67C60AAD-517D-4B98-8EE8-FB46D0526C7B",
      "resource": {
        "InternetGatewayId": "",
        "AttachmentSet": [
          {
            "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}"
          }
        ]
      }
    },
    "8390D52A-5FA9-4A0D-AE48-5C44D4700C63": {
      "type": "AWS.EC2.Instance",
      "uid": "8390D52A-5FA9-4A0D-AE48-5C44D4700C63",
      "name": "host-2",
      "index": 0,
      "number": 1,
      "serverGroupUid": "8390D52A-5FA9-4A0D-AE48-5C44D4700C63",
      "serverGroupName": "host-2",
      "state": null,
      "resource": {
        "UserData": {
          "Base64Encoded": false,
          "Data": ""
        },
        "BlockDeviceMapping": [
          {
            "DeviceName": "/dev/sda1",
            "Ebs": {
              "SnapshotId": "snap-ef432332",
              "VolumeSize": 8,
              "VolumeType": "standard"
            }
          }
        ],
        "Placement": {
          "Tenancy": "",
          "AvailabilityZone": "@{AC3BBD64-DECB-485F-8C0A-664058A1D533.resource.ZoneName}"
        },
        "InstanceId": "",
        "ImageId": "ami-178e927e",
        "KeyName": "@{DB21A1D2-3DF3-4E30-8830-8870CB4D2FC9.resource.KeyName}",
        "EbsOptimized": false,
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "SubnetId": "@{B6C491EA-E696-4532-AA3E-78E4899CCEDA.resource.SubnetId}",
        "Monitoring": "disabled",
        "NetworkInterface": [],
        "InstanceType": "m1.small",
        "DisableApiTermination": false,
        "ShutdownBehavior": "terminate",
        "SecurityGroup": [],
        "SecurityGroupId": []
      }
    },
    "78C70AB8-F82A-418E-9FC4-76BFEE16BC93": {
      "index": 0,
      "uid": "78C70AB8-F82A-418E-9FC4-76BFEE16BC93",
      "type": "AWS.VPC.NetworkInterface",
      "name": "host-2-eni0",
      "serverGroupUid": "78C70AB8-F82A-418E-9FC4-76BFEE16BC93",
      "serverGroupName": "eni0",
      "number": 1,
      "resource": {
        "SourceDestCheck": true,
        "Description": "",
        "NetworkInterfaceId": "",
        "AvailabilityZone": "@{AC3BBD64-DECB-485F-8C0A-664058A1D533.resource.ZoneName}",
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "SubnetId": "@{B6C491EA-E696-4532-AA3E-78E4899CCEDA.resource.SubnetId}",
        "AssociatePublicIpAddress": false,
        "PrivateIpAddressSet": [
          {
            "PrivateIpAddress": "10.0.0.6",
            "AutoAssign": true,
            "Primary": true
          }
        ],
        "GroupSet": [
          {
            "GroupName": "@{6F6F58B0-4529-415C-9C0A-D218A7FB641B.resource.GroupName}",
            "GroupId": "@{6F6F58B0-4529-415C-9C0A-D218A7FB641B.resource.GroupId}"
          }
        ],
        "Attachment": {
          "InstanceId": "@{8390D52A-5FA9-4A0D-AE48-5C44D4700C63.resource.InstanceId}",
          "DeviceIndex": "0",
          "AttachmentId": ""
        }
      }
    },
    "80765DBF-C01B-4EC3-92EE-5341319E3892": {
      "index": 0,
      "uid": "80765DBF-C01B-4EC3-92EE-5341319E3892",
      "type": "AWS.VPC.NetworkInterface",
      "name": "host-3-eni0",
      "serverGroupUid": "80765DBF-C01B-4EC3-92EE-5341319E3892",
      "serverGroupName": "eni0",
      "number": 1,
      "resource": {
        "SourceDestCheck": true,
        "Description": "",
        "NetworkInterfaceId": "",
        "AvailabilityZone": "@{AC3BBD64-DECB-485F-8C0A-664058A1D533.resource.ZoneName}",
        "VpcId": "@{2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9.resource.VpcId}",
        "SubnetId": "@{B6C491EA-E696-4532-AA3E-78E4899CCEDA.resource.SubnetId}",
        "AssociatePublicIpAddress": false,
        "PrivateIpAddressSet": [
          {
            "PrivateIpAddress": "10.0.0.7",
            "AutoAssign": true,
            "Primary": true
          }
        ],
        "GroupSet": [
          {
            "GroupName": "@{6F6F58B0-4529-415C-9C0A-D218A7FB641B.resource.GroupName}",
            "GroupId": "@{6F6F58B0-4529-415C-9C0A-D218A7FB641B.resource.GroupId}"
          }
        ],
        "Attachment": {
          "InstanceId": "@{B8F9F506-53E8-4908-8DA8-28D10A2BB93F.resource.InstanceId}",
          "DeviceIndex": "0",
          "AttachmentId": ""
        }
      }
    }
  },
  "layout": {
    "2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9": {
      "coordinate": [
        28,
        7
      ],
      "uid": "2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9",
      "size": [
        60,
        60
      ]
    },
    "F7B14373-F8FD-403B-AA9D-FF4DB0BAB5AF": {
      "coordinate": [
        73,
        9
      ],
      "uid": "F7B14373-F8FD-403B-AA9D-FF4DB0BAB5AF",
      "groupUId": "2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9"
    },
    "AC3BBD64-DECB-485F-8C0A-664058A1D533": {
      "coordinate": [
        49,
        25
      ],
      "uid": "AC3BBD64-DECB-485F-8C0A-664058A1D533",
      "groupUId": "2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9",
      "size": [
        21,
        21
      ]
    },
    "B6C491EA-E696-4532-AA3E-78E4899CCEDA": {
      "coordinate": [
        51,
        27
      ],
      "uid": "B6C491EA-E696-4532-AA3E-78E4899CCEDA",
      "groupUId": "AC3BBD64-DECB-485F-8C0A-664058A1D533",
      "size": [
        17,
        17
      ]
    },
    "C366FD4E-C68F-4976-BD95-27557CF782E1": {
      "coordinate": [
        54,
        32
      ],
      "uid": "C366FD4E-C68F-4976-BD95-27557CF782E1",
      "groupUId": "B6C491EA-E696-4532-AA3E-78E4899CCEDA",
      "osType": "amazon",
      "architecture": "i386",
      "rootDeviceType": "ebs",
      "instanceList": [
        "C366FD4E-C68F-4976-BD95-27557CF782E1"
      ]
    },
    "C4E7CEA6-EB4B-4119-9598-6B8DC470D5C7": {
      "coordinate": [
        35,
        18
      ],
      "uid": "C4E7CEA6-EB4B-4119-9598-6B8DC470D5C7",
      "groupUId": "2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9"
    },
    "67C60AAD-517D-4B98-8EE8-FB46D0526C7B": {
      "coordinate": [
        24,
        33
      ],
      "uid": "67C60AAD-517D-4B98-8EE8-FB46D0526C7B",
      "groupUId": "2AAF2E66-24C2-475E-8ADB-311D8EBAF4E9"
    },
    "8390D52A-5FA9-4A0D-AE48-5C44D4700C63": {
      "coordinate": [
        57,
        28
      ],
      "uid": "8390D52A-5FA9-4A0D-AE48-5C44D4700C63",
      "groupUId": "B6C491EA-E696-4532-AA3E-78E4899CCEDA",
      "osType": "amazon",
      "architecture": "i386",
      "rootDeviceType": "ebs",
      "instanceList": [
        "8390D52A-5FA9-4A0D-AE48-5C44D4700C63"
      ]
    },
    "B8F9F506-53E8-4908-8DA8-28D10A2BB93F": {
      "coordinate": [
        52,
        34
      ],
      "uid": "B8F9F506-53E8-4908-8DA8-28D10A2BB93F",
      "groupUId": "B6C491EA-E696-4532-AA3E-78E4899CCEDA",
      "osType": "amazon",
      "architecture": "i386",
      "rootDeviceType": "ebs",
      "instanceList": [
        "B8F9F506-53E8-4908-8DA8-28D10A2BB93F"
      ]
    },
    "size": [
      240,
      240
    ]
  },
  "property": {
    "stoppable": true,
    "policy": {
      "ha": ""
    },
    "lease": {
      "action": "",
      "length": null,
      "due": null
    },
    "schedule": {
      "stop": {
        "run": null,
        "when": null,
        "during": null
      },
      "backup": {
        "when": null,
        "day": null
      },
      "start": {
        "when": null
      }
    }
  }
}

});