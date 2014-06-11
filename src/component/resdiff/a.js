define ( [], function() {
    return {
     "agent": {
      "enabled": true,
      "module": {
       "repo": "https://github.com/MadeiraCloud/salt.git",
       "tag": "v2014-04-15"
      }
     },
     "username": "dGlt",
     "name": "untitled-6",
     "region": "us-east-1",
     "platform": "ec2-vpc",
     "state": "Enabled",
     "version": "2014-02-17",
     "property": {
      "stoppable": false,
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
     },
     "id": "stack-919c3766",
     "description": "",
     "component": {
      "C80DFF34-4234-4277-9A3D-44F5FF9D3E5C": {
       "name": "DefaultACL",
       "type": "AWS.VPC.NetworkAcl",
       "uid": "C80DFF34-4234-4277-9A3D-44F5FF9D3E5C",
       "resource": {
        "AssociationSet": [
         {
          "NetworkAclAssociationId": "",
          "SubnetId": "@{ED53CDEC-E85C-42D3-829D-4FBE1008343F.resource.SubnetId}"
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
        "VpcId": "@{5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615.resource.VpcId}"
       }
      },
      "5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615": {
       "name": "vpc",
       "type": "AWS.VPC.VPC",
       "uid": "5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615",
       "resource": {
        "EnableDnsSupport": true,
        "InstanceTenancy": "default",
        "EnableDnsHostnames": false,
        "DhcpOptionsId": "",
        "VpcId": "",
        "CidrBlock": "10.0.0.0/16"
       }
      },
      "026F192A-CEE2-4DB1-BB2B-7785AEC25874": {
       "name": "RT-0",
       "type": "AWS.VPC.RouteTable",
       "uid": "026F192A-CEE2-4DB1-BB2B-7785AEC25874",
       "resource": {
        "PropagatingVgwSet": [],
        "RouteTableId": "",
        "VpcId": "@{5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615.resource.VpcId}",
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
      "458227E2-903E-4987-90C8-CC01966F8C1E": {
       "uid": "458227E2-903E-4987-90C8-CC01966F8C1E",
       "name": "us-east-1a",
       "type": "AWS.EC2.AvailabilityZone",
       "resource": {
        "ZoneName": "us-east-1a",
        "RegionName": "us-east-1"
       }
      },
      "ED53CDEC-E85C-42D3-829D-4FBE1008343F": {
       "name": "subnet0",
       "type": "AWS.VPC.Subnet",
       "uid": "ED53CDEC-E85C-42D3-829D-4FBE1008343F",
       "resource": {
        "AvailabilityZone": "@{458227E2-903E-4987-90C8-CC01966F8C1E.resource.ZoneName}",
        "VpcId": "@{5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615.resource.VpcId}",
        "SubnetId": "",
        "CidrBlock": "10.0.0.0/24"
       }
      },
      "F35578F2-5B6F-4245-A82F-626A4F0CB61A": {
       "uid": "F35578F2-5B6F-4245-A82F-626A4F0CB61A",
       "name": "asg0",
       "type": "AWS.AutoScaling.Group",
       "resource": {
        "AvailabilityZones": [
         "@{458227E2-903E-4987-90C8-CC01966F8C1E.resource.ZoneName}"
        ],
        "VPCZoneIdentifier": "@{ED53CDEC-E85C-42D3-829D-4FBE1008343F.resource.SubnetId}",
        "LoadBalancerNames": [],
        "AutoScalingGroupARN": "",
        "DefaultCooldown": 300,
        "MinSize": 1,
        "MaxSize": 2,
        "HealthCheckType": "EC2",
        "HealthCheckGracePeriod": 300,
        "TerminationPolicies": [
         "Default"
        ],
        "AutoScalingGroupName": "asg0",
        "DesiredCapacity": 1,
        "LaunchConfigurationName": "@{A657C87B-3007-470F-9BA0-72B36F6E7202.resource.LaunchConfigurationName}"
       }
      },
      "A657C87B-3007-470F-9BA0-72B36F6E7202": {
       "type": "AWS.AutoScaling.LaunchConfiguration",
       "uid": "A657C87B-3007-470F-9BA0-72B36F6E7202",
       "name": "launch-config-0",
       "state": null,
       "resource": {
        "UserData": "",
        "LaunchConfigurationARN": "",
        "InstanceMonitoring": false,
        "ImageId": "ami-178e927e",
        "KeyName": "@{E104C186-13BF-4DA7-982B-3CD891A7826A.resource.KeyName}",
        "EbsOptimized": false,
        "BlockDeviceMapping": [
         {
          "DeviceName": "/dev/sda1",
          "Ebs": {
           "VolumeSize": 8,
           "VolumeType": "standard",
           "SnapshotId": "snap-ef432332"
          }
         }
        ],
        "SecurityGroups": [
         "@{F8407486-A1ED-41E0-B152-47EA6FF37E36.resource.GroupId}"
        ],
        "LaunchConfigurationName": "launch-config-0",
        "InstanceType": "t1.micro",
        "AssociatePublicIpAddress": false
       }
      },
      "F8407486-A1ED-41E0-B152-47EA6FF37E36": {
       "name": "DefaultSG",
       "type": "AWS.EC2.SecurityGroup",
       "uid": "F8407486-A1ED-41E0-B152-47EA6FF37E36",
       "resource": {
        "Default": true,
        "GroupId": "",
        "GroupName": "DefaultSG",
        "GroupDescription": "default VPC security group",
        "VpcId": "@{5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615.resource.VpcId}",
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
         }
        ]
       }
      },
      "E104C186-13BF-4DA7-982B-3CD891A7826A": {
       "name": "DefaultKP",
       "type": "AWS.EC2.KeyPair",
       "uid": "E104C186-13BF-4DA7-982B-3CD891A7826A",
       "resource": {
        "KeyFingerprint": "33:07:ec:78:70:60:2d:c8:19:69:0b:e7:e2:e0:26:22:30:f5:dd:a0",
        "KeyName": "kp-openshift---app-badc18fa"
       }
      }
     },
     "layout": {
      "5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615": {
       "coordinate": [
        5,
        3
       ],
       "uid": "5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615",
       "size": [
        60,
        60
       ]
      },
      "026F192A-CEE2-4DB1-BB2B-7785AEC25874": {
       "coordinate": [
        50,
        5
       ],
       "uid": "026F192A-CEE2-4DB1-BB2B-7785AEC25874",
       "groupUId": "5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615"
      },
      "458227E2-903E-4987-90C8-CC01966F8C1E": {
       "coordinate": [
        17,
        14
       ],
       "uid": "458227E2-903E-4987-90C8-CC01966F8C1E",
       "groupUId": "5EC71302-FE1F-4DB3-9E1F-A3E47BA1D615",
       "size": [
        21,
        21
       ]
      },
      "ED53CDEC-E85C-42D3-829D-4FBE1008343F": {
       "coordinate": [
        19,
        16
       ],
       "uid": "ED53CDEC-E85C-42D3-829D-4FBE1008343F",
       "groupUId": "458227E2-903E-4987-90C8-CC01966F8C1E",
       "size": [
        17,
        17
       ]
      },
      "F35578F2-5B6F-4245-A82F-626A4F0CB61A": {
       "coordinate": [
        21,
        18
       ],
       "uid": "F35578F2-5B6F-4245-A82F-626A4F0CB61A",
       "groupUId": "ED53CDEC-E85C-42D3-829D-4FBE1008343F",
       "size": [
        13,
        13
       ]
      },
      "A657C87B-3007-470F-9BA0-72B36F6E7202": {
       "coordinate": [
        23,
        21
       ],
       "uid": "A657C87B-3007-470F-9BA0-72B36F6E7202",
       "groupUId": "F35578F2-5B6F-4245-A82F-626A4F0CB61A",
       "osType": "amazon",
       "architecture": "i386",
       "rootDeviceType": "ebs"
      },
      "size": [
       240,
       240
      ]
     }
}

});