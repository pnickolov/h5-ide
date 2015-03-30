
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["OpsModel", "ApiRequest", "constant" ], ( OpsModel, ApiRequest, constant )->

  AwsOpsModel = OpsModel.extend {

    type : OpsModel.Type.Amazon

    getMsrId : ()->
      msrId = OpsModel.prototype.getMsrId.call this
      if msrId then return msrId
      if not @__jsonData then return undefined
      for uid, comp of @__jsonData.component
        if comp.type is constant.RESTYPE.VPC
          return comp.resource.VpcId
      undefined

    __defaultJson : ()->
      jsonType = @getStackType()
      if jsonType is "aws"
        @___defaultJson()
      else
        @___mesosJson()

    ___defaultJson : ()->
      json   = OpsModel.prototype.__defaultJson.call this
      vpcId  = MC.guid()
      vpcRef = "@{#{vpcId}.resource.VpcId}"

      layout =
        VPC :
          coordinate : [5,3]
          size       : [60,60]
        RTB :
          coordinate : [50,5]
          groupUId   : vpcId

      component =
        KP :
          type : "AWS.EC2.KeyPair"
          name : "DefaultKP"
          resource : {
            KeyName : "DefaultKP"
            KeyFingerprint : ""
          }
        SG :
          type : "AWS.EC2.SecurityGroup"
          name : "DefaultSG"
          resource :
            IpPermissions: [{
              IpProtocol : "tcp",
              IpRanges   : "0.0.0.0/0",
              FromPort   : "22",
              ToPort     : "22",
            }],
            IpPermissionsEgress : [{
              FromPort: "0",
              IpProtocol: "-1",
              IpRanges: "0.0.0.0/0",
              ToPort: "65535"
            }],
            Default          : true
            GroupId          : ""
            GroupName        : "DefaultSG"
            GroupDescription : 'default VPC security group'
            VpcId            : vpcRef
        ACL :
          type : "AWS.VPC.NetworkAcl"
          name : "DefaultACL"
          resource :
            AssociationSet : []
            Default        : true
            NetworkAclId   : ""
            VpcId          : vpcRef
            EntrySet : [
              {
                RuleAction : "allow"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : true
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 100
              }
              {
                RuleAction : "allow"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : false
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 100
              }
              {
                RuleAction : "deny"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : true
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 32767
              }
              {
                RuleAction : "deny"
                Protocol   : -1
                CidrBlock  : "0.0.0.0/0"
                Egress     : false
                IcmpTypeCode : { Type : "", Code : "" }
                PortRange    : { To   : "", From : "" }
                RuleNumber   : 32767
              }
            ]
        VPC :
          type : "AWS.VPC.VPC"
          name : "vpc"
          resource :
            VpcId              : ""
            CidrBlock          : "10.0.0.0/16"
            DhcpOptionsId      : ""
            EnableDnsHostnames : false
            EnableDnsSupport   : true
            InstanceTenancy    : "default"
        RTB :
          type : "AWS.VPC.RouteTable"
          name : "RT-0"
          resource :
            VpcId : vpcRef
            RouteTableId: ""
            AssociationSet : [{
              Main:"true"
              SubnetId : ""
              RouteTableAssociationId : ""
            }]
            PropagatingVgwSet:[]
            RouteSet : [{
              InstanceId           : ""
              NetworkInterfaceId   : ""
              Origin               : 'CreateRouteTable'
              GatewayId            : 'local'
              DestinationCidrBlock : '10.0.0.0/16'
            }]

      # Generate new GUID for each component
      for id, comp of component
        if id is "VPC"
          comp.uid = vpcId
        else
          comp.uid = MC.guid()
        json.component[ comp.uid ] = comp
        if layout[ id ]
          l = layout[id]
          l.uid = comp.uid
          json.layout[ comp.uid ] = l

      json

    ___mesosJson: ()->
      json   = OpsModel.prototype.__defaultJson.call this

      amiForEachRegion = [
        {"region":"us-east-1","imageId":"ami-9ef278f6"}
        {"region":"us-west-1","imageId":"ami-353f2970"}
        {"region":"eu-west-1","imageId":"ami-1a92266d"}
        {"region":"us-west-2","imageId":"ami-fba3e8cb"}
        {"region":"eu-central-1","imageId":"ami-929caa8f"}
        {"region":"ap-southeast-2","imageId":"ami-5fe28d65"}
        {"region":"ap-northeast-1","imageId":"ami-9d7f479c"}
        {"region":"ap-southeast-1","imageId":"ami-a6a083f4"}
        {"region":"sa-east-1","imageId":"ami-c79e28da"}
      ]

      framework =  if @getStackFramework() then ["marathon"] else []
      imageId = (_.findWhere amiForEachRegion, {region: @get("region")}).imageId
      regionName = @get("region")

      component = {
          "17852306-D408-4535-85F4-FD3479058FF4": {
              "name": "DefaultACL",
              "type": "AWS.VPC.NetworkAcl",
              "uid": "17852306-D408-4535-85F4-FD3479058FF4",
              "resource": {
                  "AssociationSet": [
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{1DB0AB9E-6D51-4197-A0C0-5B6833BF37B4.resource.SubnetId}"
                      },
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{016B2888-0567-4B9E-A274-4B93BB5296DB.resource.SubnetId}"
                      },
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{22FF652F-0CA7-49A4-8838-877392E5E871.resource.SubnetId}"
                      },
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{00E2025F-8540-4C02-A359-0C5F2B70E173.resource.SubnetId}"
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
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "Tags": [
                      {
                          "Key": "visops_default",
                          "Value": "true"
                      }
                  ]
              }
          },
          "CFB5F178-A3AA-4DC7-A68E-E5C8C3CECFBF": {
              "name": "RT-0",
              "description": "",
              "type": "AWS.VPC.RouteTable",
              "uid": "CFB5F178-A3AA-4DC7-A68E-E5C8C3CECFBF",
              "resource": {
                  "PropagatingVgwSet": [],
                  "RouteTableId": "",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
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
                      },
                      {
                          "DestinationCidrBlock": "0.0.0.0/0",
                          "Origin": "",
                          "InstanceId": "",
                          "NetworkInterfaceId": "",
                          "GatewayId": "@{1AF38C59-B2D4-4831-B91B-4B6978098545.resource.InternetGatewayId}"
                      }
                  ],
                  "Tags": [
                      {
                          "Key": "visops_default",
                          "Value": "true"
                      }
                  ]
              }
          },
          "F858FEE0-B445-46AE-A5E8-61ED2DB99F9F": {
              "name": "mesos",
              "description": "",
              "type": "AWS.VPC.VPC",
              "uid": "F858FEE0-B445-46AE-A5E8-61ED2DB99F9F",
              "resource": {
                  "EnableDnsSupport": true,
                  "InstanceTenancy": "default",
                  "EnableDnsHostnames": false,
                  "DhcpOptionsId": "",
                  "VpcId": "",
                  "CidrBlock": "10.0.0.0/16"
              }
          },
          "60E92EE3-8A77-4B1A-A139-5EBDE764379A": {
              "uid": "60E92EE3-8A77-4B1A-A139-5EBDE764379A",
              "name": "us-east-1b",
              "type": "AWS.EC2.AvailabilityZone",
              "resource": {
                  "ZoneName": "us-east-1b",
                  "RegionName": "us-east-1"
              }
          },
          "1DB0AB9E-6D51-4197-A0C0-5B6833BF37B4": {
              "name": "sched-b",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "1DB0AB9E-6D51-4197-A0C0-5B6833BF37B4",
              "resource": {
                  "AvailabilityZone": "@{60E92EE3-8A77-4B1A-A139-5EBDE764379A.resource.ZoneName}",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.3.0/24"
              }
          },
          "14972D10-B0AE-4D64-8F92-78CC50B73B41": {
              "name": "DefaultKP",
              "type": "AWS.EC2.KeyPair",
              "uid": "14972D10-B0AE-4D64-8F92-78CC50B73B41",
              "resource": {
                  "KeyFingerprint": "",
                  "KeyName": "DefaultKP"
              }
          },
          "BB95D158-05C3-4C1F-AA3D-0B75CF7163E6": {
              "name": "DefaultSG",
              "type": "AWS.EC2.SecurityGroup",
              "uid": "BB95D158-05C3-4C1F-AA3D-0B75CF7163E6",
              "resource": {
                  "Default": true,
                  "GroupId": "",
                  "GroupName": "DefaultSG",
                  "GroupDescription": "default VPC security group",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
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
                  ],
                  "Tags": [
                      {
                          "Key": "visops_default",
                          "Value": "true"
                      }
                  ]
              }
          },
          "F781C323-5977-4D18-92F6-87B35B592719": {
              "uid": "F781C323-5977-4D18-92F6-87B35B592719",
              "name": "us-east-1a",
              "type": "AWS.EC2.AvailabilityZone",
              "resource": {
                  "ZoneName": "us-east-1a",
                  "RegionName": "us-east-1"
              }
          },
          "016B2888-0567-4B9E-A274-4B93BB5296DB": {
              "name": "web-a",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "016B2888-0567-4B9E-A274-4B93BB5296DB",
              "resource": {
                  "AvailabilityZone": "@{F781C323-5977-4D18-92F6-87B35B592719.resource.ZoneName}",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.0.0/24"
              }
          },
          "22FF652F-0CA7-49A4-8838-877392E5E871": {
              "name": "sched-a",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "22FF652F-0CA7-49A4-8838-877392E5E871",
              "resource": {
                  "AvailabilityZone": "@{F781C323-5977-4D18-92F6-87B35B592719.resource.ZoneName}",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.2.0/24"
              }
          },
          "00E2025F-8540-4C02-A359-0C5F2B70E173": {
              "name": "web-b",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "00E2025F-8540-4C02-A359-0C5F2B70E173",
              "resource": {
                  "AvailabilityZone": "@{60E92EE3-8A77-4B1A-A139-5EBDE764379A.resource.ZoneName}",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.1.0/24"
              }
          },
          "1AF38C59-B2D4-4831-B91B-4B6978098545": {
              "name": "Internet-gateway",
              "type": "AWS.VPC.InternetGateway",
              "uid": "1AF38C59-B2D4-4831-B91B-4B6978098545",
              "resource": {
                  "InternetGatewayId": "",
                  "AttachmentSet": [
                      {
                          "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}"
                      }
                  ]
              }
          },
          "9EA1F075-7546-4625-AA6E-08BC31DBCE53": {
              "name": "MesosSG",
              "type": "AWS.EC2.SecurityGroup",
              "uid": "9EA1F075-7546-4625-AA6E-08BC31DBCE53",
              "resource": {
                  "Default": false,
                  "GroupId": "",
                  "GroupName": "MesosSG",
                  "GroupDescription": "Custom Security Group",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "IpPermissions": [
                      {
                          "FromPort": "5050",
                          "ToPort": "5050",
                          "IpRanges": "0.0.0.0/0",
                          "IpProtocol": "tcp"
                      },
                      {
                          "FromPort": "8080",
                          "ToPort": "8080",
                          "IpRanges": "0.0.0.0/0",
                          "IpProtocol": "tcp"
                      },
                      {
                          "FromPort": "0",
                          "ToPort": "65535",
                          "IpRanges": "@{9EA1F075-7546-4625-AA6E-08BC31DBCE53.resource.GroupId}",
                          "IpProtocol": "-1"
                      }
                  ],
                  "IpPermissionsEgress": [
                      {
                          "FromPort": "0",
                          "ToPort": "65535",
                          "IpRanges": "0.0.0.0/0",
                          "IpProtocol": "-1"
                      }
                  ],
                  "Tags": [
                      {
                          "Key": "visops_default",
                          "Value": "false"
                      }
                  ]
              }
          },
          "6CE73419-EF80-405E-B4F4-08DF3874E54E": {
              "type": "AWS.EC2.Instance",
              "uid": "6CE73419-EF80-405E-B4F4-08DF3874E54E",
              "name": "master-0",
              "description": "",
              "index": 0,
              "number": 1,
              "serverGroupUid": "6CE73419-EF80-405E-B4F4-08DF3874E54E",
              "serverGroupName": "master-0",
              "state": [
                  {
                      "id": "master-0",
                      "module": "linux.mesos.master",
                      "parameter": {
                          "cluster_name": "untitled-8",
                          "master_ip": "@{self.PrivateIpAddress}",
                          "server_id": "master-0",
                          "masters_addresses": [
                              {
                                  "key": "@{6CE73419-EF80-405E-B4F4-08DF3874E54E.PrivateIpAddress}",
                                  "value": "master-0"
                              },
                              {
                                  "key": "@{D453909A-E1C9-4CD8-8C64-2DD01F76A340.PrivateIpAddress}",
                                  "value": "master-1"
                              },
                              {
                                  "key": "@{5A005006-4CBD-494C-91E3-5448672E89EF.PrivateIpAddress}",
                                  "value": "master-2"
                              }
                          ],
                          "hostname": "master-0",
                          "framework": [
                              "marathon"
                          ]
                      }
                  }
              ],
              "resource": {
                  "UserData": {
                      "Base64Encoded": false,
                      "Data": ""
                  },
                  "BlockDeviceMapping": [
                      {
                          "DeviceName": "/dev/sda1",
                          "Ebs": {
                              "SnapshotId": "snap-00fc3bbc",
                              "VolumeSize": 8,
                              "VolumeType": "gp2"
                          }
                      }
                  ],
                  "Placement": {
                      "Tenancy": "",
                      "AvailabilityZone": "@{F781C323-5977-4D18-92F6-87B35B592719.resource.ZoneName}"
                  },
                  "InstanceId": "",
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{14972D10-B0AE-4D64-8F92-78CC50B73B41.resource.KeyName}",
                  "EbsOptimized": false,
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "@{22FF652F-0CA7-49A4-8838-877392E5E871.resource.SubnetId}",
                  "Monitoring": "disabled",
                  "NetworkInterface": [],
                  "InstanceType": "t2.micro",
                  "DisableApiTermination": false,
                  "ShutdownBehavior": "terminate",
                  "SecurityGroup": [],
                  "SecurityGroupId": []
              }
          },
          "94997E1A-DDA3-49AC-A5EB-6A169473EE2B": {
              "index": 0,
              "uid": "94997E1A-DDA3-49AC-A5EB-6A169473EE2B",
              "type": "AWS.VPC.NetworkInterface",
              "name": "master-0-eni0",
              "serverGroupUid": "94997E1A-DDA3-49AC-A5EB-6A169473EE2B",
              "serverGroupName": "eni0",
              "number": 1,
              "resource": {
                  "SourceDestCheck": true,
                  "Description": "",
                  "NetworkInterfaceId": "",
                  "AvailabilityZone": "@{F781C323-5977-4D18-92F6-87B35B592719.resource.ZoneName}",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "@{22FF652F-0CA7-49A4-8838-877392E5E871.resource.SubnetId}",
                  "AssociatePublicIpAddress": true,
                  "PrivateIpAddressSet": [
                      {
                          "PrivateIpAddress": "10.0.2.4",
                          "AutoAssign": true,
                          "Primary": true
                      }
                  ],
                  "GroupSet": [
                      {
                          "GroupName": "@{BB95D158-05C3-4C1F-AA3D-0B75CF7163E6.resource.GroupName}",
                          "GroupId": "@{BB95D158-05C3-4C1F-AA3D-0B75CF7163E6.resource.GroupId}"
                      }
                  ],
                  "Attachment": {
                      "InstanceId": "@{6CE73419-EF80-405E-B4F4-08DF3874E54E.resource.InstanceId}",
                      "DeviceIndex": "0",
                      "AttachmentId": ""
                  }
              }
          },
          "D453909A-E1C9-4CD8-8C64-2DD01F76A340": {
              "type": "AWS.EC2.Instance",
              "uid": "D453909A-E1C9-4CD8-8C64-2DD01F76A340",
              "name": "master-1",
              "description": "",
              "index": 0,
              "number": 1,
              "serverGroupUid": "D453909A-E1C9-4CD8-8C64-2DD01F76A340",
              "serverGroupName": "master-1",
              "state": [
                  {
                      "id": "master-1",
                      "module": "linux.mesos.master",
                      "parameter": {
                          "cluster_name": "untitled-8",
                          "master_ip": "@{self.PrivateIpAddress}",
                          "server_id": "master-1",
                          "masters_addresses": [
                              {
                                  "key": "@{6CE73419-EF80-405E-B4F4-08DF3874E54E.PrivateIpAddress}",
                                  "value": "master-0"
                              },
                              {
                                  "key": "@{D453909A-E1C9-4CD8-8C64-2DD01F76A340.PrivateIpAddress}",
                                  "value": "master-1"
                              },
                              {
                                  "key": "@{5A005006-4CBD-494C-91E3-5448672E89EF.PrivateIpAddress}",
                                  "value": "master-2"
                              }
                          ],
                          "hostname": "master-1",
                          "framework": [
                              "marathon"
                          ]
                      }
                  }
              ],
              "resource": {
                  "UserData": {
                      "Base64Encoded": false,
                      "Data": ""
                  },
                  "BlockDeviceMapping": [
                      {
                          "DeviceName": "/dev/sda1",
                          "Ebs": {
                              "SnapshotId": "snap-00fc3bbc",
                              "VolumeSize": 8,
                              "VolumeType": "gp2"
                          }
                      }
                  ],
                  "Placement": {
                      "Tenancy": "",
                      "AvailabilityZone": "@{F781C323-5977-4D18-92F6-87B35B592719.resource.ZoneName}"
                  },
                  "InstanceId": "",
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{14972D10-B0AE-4D64-8F92-78CC50B73B41.resource.KeyName}",
                  "EbsOptimized": false,
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "@{22FF652F-0CA7-49A4-8838-877392E5E871.resource.SubnetId}",
                  "Monitoring": "disabled",
                  "NetworkInterface": [],
                  "InstanceType": "t2.micro",
                  "DisableApiTermination": false,
                  "ShutdownBehavior": "terminate",
                  "SecurityGroup": [],
                  "SecurityGroupId": []
              }
          },
          "4C7F4411-AEC8-45A4-B5C1-5DDDC38A01CE": {
              "index": 0,
              "uid": "4C7F4411-AEC8-45A4-B5C1-5DDDC38A01CE",
              "type": "AWS.VPC.NetworkInterface",
              "name": "master-1-eni0",
              "serverGroupUid": "4C7F4411-AEC8-45A4-B5C1-5DDDC38A01CE",
              "serverGroupName": "eni0",
              "number": 1,
              "resource": {
                  "SourceDestCheck": true,
                  "Description": "",
                  "NetworkInterfaceId": "",
                  "AvailabilityZone": "@{F781C323-5977-4D18-92F6-87B35B592719.resource.ZoneName}",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "@{22FF652F-0CA7-49A4-8838-877392E5E871.resource.SubnetId}",
                  "AssociatePublicIpAddress": true,
                  "PrivateIpAddressSet": [
                      {
                          "PrivateIpAddress": "10.0.2.5",
                          "AutoAssign": true,
                          "Primary": true
                      }
                  ],
                  "GroupSet": [
                      {
                          "GroupName": "@{BB95D158-05C3-4C1F-AA3D-0B75CF7163E6.resource.GroupName}",
                          "GroupId": "@{BB95D158-05C3-4C1F-AA3D-0B75CF7163E6.resource.GroupId}"
                      }
                  ],
                  "Attachment": {
                      "InstanceId": "@{D453909A-E1C9-4CD8-8C64-2DD01F76A340.resource.InstanceId}",
                      "DeviceIndex": "0",
                      "AttachmentId": ""
                  }
              }
          },
          "5A005006-4CBD-494C-91E3-5448672E89EF": {
              "type": "AWS.EC2.Instance",
              "uid": "5A005006-4CBD-494C-91E3-5448672E89EF",
              "name": "master-2",
              "description": "",
              "index": 0,
              "number": 1,
              "serverGroupUid": "5A005006-4CBD-494C-91E3-5448672E89EF",
              "serverGroupName": "master-2",
              "state": [
                  {
                      "id": "master-2",
                      "module": "linux.mesos.master",
                      "parameter": {
                          "cluster_name": "untitled-8",
                          "master_ip": "@{self.PrivateIpAddress}",
                          "server_id": "master-2",
                          "masters_addresses": [
                              {
                                  "key": "@{6CE73419-EF80-405E-B4F4-08DF3874E54E.PrivateIpAddress}",
                                  "value": "master-0"
                              },
                              {
                                  "key": "@{D453909A-E1C9-4CD8-8C64-2DD01F76A340.PrivateIpAddress}",
                                  "value": "master-1"
                              },
                              {
                                  "key": "@{5A005006-4CBD-494C-91E3-5448672E89EF.PrivateIpAddress}",
                                  "value": "master-2"
                              }
                          ],
                          "hostname": "master-2",
                          "framework": [
                              "marathon"
                          ]
                      }
                  }
              ],
              "resource": {
                  "UserData": {
                      "Base64Encoded": false,
                      "Data": ""
                  },
                  "BlockDeviceMapping": [
                      {
                          "DeviceName": "/dev/sda1",
                          "Ebs": {
                              "SnapshotId": "snap-00fc3bbc",
                              "VolumeSize": 8,
                              "VolumeType": "gp2"
                          }
                      }
                  ],
                  "Placement": {
                      "Tenancy": "",
                      "AvailabilityZone": "@{60E92EE3-8A77-4B1A-A139-5EBDE764379A.resource.ZoneName}"
                  },
                  "InstanceId": "",
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{14972D10-B0AE-4D64-8F92-78CC50B73B41.resource.KeyName}",
                  "EbsOptimized": false,
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "@{1DB0AB9E-6D51-4197-A0C0-5B6833BF37B4.resource.SubnetId}",
                  "Monitoring": "disabled",
                  "NetworkInterface": [],
                  "InstanceType": "t2.micro",
                  "DisableApiTermination": false,
                  "ShutdownBehavior": "terminate",
                  "SecurityGroup": [],
                  "SecurityGroupId": []
              }
          },
          "45E854C2-BBFF-4DA0-B775-92AE12BAF982": {
              "index": 0,
              "uid": "45E854C2-BBFF-4DA0-B775-92AE12BAF982",
              "type": "AWS.VPC.NetworkInterface",
              "name": "master-2-eni0",
              "serverGroupUid": "45E854C2-BBFF-4DA0-B775-92AE12BAF982",
              "serverGroupName": "eni0",
              "number": 1,
              "resource": {
                  "SourceDestCheck": true,
                  "Description": "",
                  "NetworkInterfaceId": "",
                  "AvailabilityZone": "@{60E92EE3-8A77-4B1A-A139-5EBDE764379A.resource.ZoneName}",
                  "VpcId": "@{F858FEE0-B445-46AE-A5E8-61ED2DB99F9F.resource.VpcId}",
                  "SubnetId": "@{1DB0AB9E-6D51-4197-A0C0-5B6833BF37B4.resource.SubnetId}",
                  "AssociatePublicIpAddress": true,
                  "PrivateIpAddressSet": [
                      {
                          "PrivateIpAddress": "10.0.3.4",
                          "AutoAssign": true,
                          "Primary": true
                      }
                  ],
                  "GroupSet": [
                      {
                          "GroupName": "@{BB95D158-05C3-4C1F-AA3D-0B75CF7163E6.resource.GroupName}",
                          "GroupId": "@{BB95D158-05C3-4C1F-AA3D-0B75CF7163E6.resource.GroupId}"
                      }
                  ],
                  "Attachment": {
                      "InstanceId": "@{5A005006-4CBD-494C-91E3-5448672E89EF.resource.InstanceId}",
                      "DeviceIndex": "0",
                      "AttachmentId": ""
                  }
              }
          },
          "59F2150C-5CF6-4832-9DA0-C55242AF4342": {
              "uid": "59F2150C-5CF6-4832-9DA0-C55242AF4342",
              "name": "asg0",
              "description": "",
              "type": "AWS.AutoScaling.Group",
              "resource": {
                  "AvailabilityZones": [
                      "@{F781C323-5977-4D18-92F6-87B35B592719.resource.ZoneName}",
                      "@{60E92EE3-8A77-4B1A-A139-5EBDE764379A.resource.ZoneName}"
                  ],
                  "VPCZoneIdentifier": "@{016B2888-0567-4B9E-A274-4B93BB5296DB.resource.SubnetId} , @{00E2025F-8540-4C02-A359-0C5F2B70E173.resource.SubnetId}",
                  "LoadBalancerNames": [],
                  "AutoScalingGroupARN": "",
                  "DefaultCooldown": "300",
                  "MinSize": "1",
                  "MaxSize": "2",
                  "HealthCheckType": "EC2",
                  "HealthCheckGracePeriod": "300",
                  "TerminationPolicies": [
                      "Default"
                  ],
                  "AutoScalingGroupName": "asg0",
                  "DesiredCapacity": "1",
                  "LaunchConfigurationName": "@{0BA47633-37FA-4CBC-A5C5-A2104CE488D1.resource.LaunchConfigurationName}"
              }
          },
          "0BA47633-37FA-4CBC-A5C5-A2104CE488D1": {
              "type": "AWS.AutoScaling.LaunchConfiguration",
              "uid": "0BA47633-37FA-4CBC-A5C5-A2104CE488D1",
              "name": "slave-lc-0",
              "description": "",
              "state": [
                  {
                      "id": "slave-lc-0",
                      "module": "linux.mesos.slave",
                      "parameter": {
                          "masters_addresses": [
                              {
                                  "key": "@{6CE73419-EF80-405E-B4F4-08DF3874E54E.PrivateIpAddress}",
                                  "value": "master-0"
                              },
                              {
                                  "key": "@{D453909A-E1C9-4CD8-8C64-2DD01F76A340.PrivateIpAddress}",
                                  "value": "master-1"
                              },
                              {
                                  "key": "@{5A005006-4CBD-494C-91E3-5448672E89EF.PrivateIpAddress}",
                                  "value": "master-2"
                              }
                          ],
                          "attributes": [
                              {
                                  "key": "az",
                                  "value": ""
                              },
                              {
                                  "key": "asg",
                                  "value": ""
                              }
                          ],
                          "slave_ip": "@{self.PrivateIpAddress}"
                      }
                  }
              ],
              "resource": {
                  "UserData": "",
                  "LaunchConfigurationARN": "",
                  "InstanceMonitoring": false,
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{14972D10-B0AE-4D64-8F92-78CC50B73B41.resource.KeyName}",
                  "EbsOptimized": false,
                  "BlockDeviceMapping": [
                      {
                          "DeviceName": "/dev/sda1",
                          "Ebs": {
                              "SnapshotId": "snap-00fc3bbc",
                              "VolumeSize": 8,
                              "VolumeType": "gp2"
                          }
                      }
                  ],
                  "SecurityGroups": [
                      "@{BB95D158-05C3-4C1F-AA3D-0B75CF7163E6.resource.GroupId}"
                  ],
                  "LaunchConfigurationName": "slave-lc-0",
                  "InstanceType": "t2.micro",
                  "AssociatePublicIpAddress": true
              }
          }
      }

      layout = {
          "CFB5F178-A3AA-4DC7-A68E-E5C8C3CECFBF": {
              "coordinate": [
                  76,
                  8
              ],
              "uid": "CFB5F178-A3AA-4DC7-A68E-E5C8C3CECFBF",
              "groupUId": "F858FEE0-B445-46AE-A5E8-61ED2DB99F9F"
          },
          "F858FEE0-B445-46AE-A5E8-61ED2DB99F9F": {
              "coordinate": [
                  8,
                  7
              ],
              "uid": "F858FEE0-B445-46AE-A5E8-61ED2DB99F9F",
              "size": [
                  83,
                  64
              ]
          },
          "60E92EE3-8A77-4B1A-A139-5EBDE764379A": {
              "coordinate": [
                  14,
                  43
              ],
              "uid": "60E92EE3-8A77-4B1A-A139-5EBDE764379A",
              "groupUId": "F858FEE0-B445-46AE-A5E8-61ED2DB99F9F",
              "size": [
                  55,
                  24
              ]
          },
          "1DB0AB9E-6D51-4197-A0C0-5B6833BF37B4": {
              "coordinate": [
                  17,
                  46
              ],
              "uid": "1DB0AB9E-6D51-4197-A0C0-5B6833BF37B4",
              "groupUId": "60E92EE3-8A77-4B1A-A139-5EBDE764379A",
              "size": [
                  28,
                  18
              ]
          },
          "F781C323-5977-4D18-92F6-87B35B592719": {
              "coordinate": [
                  14,
                  14
              ],
              "uid": "F781C323-5977-4D18-92F6-87B35B592719",
              "groupUId": "F858FEE0-B445-46AE-A5E8-61ED2DB99F9F",
              "size": [
                  55,
                  25
              ]
          },
          "016B2888-0567-4B9E-A274-4B93BB5296DB": {
              "coordinate": [
                  47,
                  17
              ],
              "uid": "016B2888-0567-4B9E-A274-4B93BB5296DB",
              "groupUId": "F781C323-5977-4D18-92F6-87B35B592719",
              "size": [
                  19,
                  19
              ]
          },
          "22FF652F-0CA7-49A4-8838-877392E5E871": {
              "coordinate": [
                  17,
                  17
              ],
              "uid": "22FF652F-0CA7-49A4-8838-877392E5E871",
              "groupUId": "F781C323-5977-4D18-92F6-87B35B592719",
              "size": [
                  27,
                  19
              ]
          },
          "00E2025F-8540-4C02-A359-0C5F2B70E173": {
              "coordinate": [
                  47,
                  46
              ],
              "uid": "00E2025F-8540-4C02-A359-0C5F2B70E173",
              "groupUId": "60E92EE3-8A77-4B1A-A139-5EBDE764379A",
              "size": [
                  19,
                  18
              ]
          },
          "1AF38C59-B2D4-4831-B91B-4B6978098545": {
              "coordinate": [
                  4,
                  8
              ],
              "uid": "1AF38C59-B2D4-4831-B91B-4B6978098545",
              "groupUId": "F858FEE0-B445-46AE-A5E8-61ED2DB99F9F"
          },
          "6CE73419-EF80-405E-B4F4-08DF3874E54E": {
              "coordinate": [
                  21,
                  22
              ],
              "uid": "6CE73419-EF80-405E-B4F4-08DF3874E54E",
              "groupUId": "22FF652F-0CA7-49A4-8838-877392E5E871",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "D453909A-E1C9-4CD8-8C64-2DD01F76A340": {
              "coordinate": [
                  32,
                  22
              ],
              "uid": "D453909A-E1C9-4CD8-8C64-2DD01F76A340",
              "groupUId": "22FF652F-0CA7-49A4-8838-877392E5E871",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "5A005006-4CBD-494C-91E3-5448672E89EF": {
              "coordinate": [
                  21,
                  51
              ],
              "uid": "5A005006-4CBD-494C-91E3-5448672E89EF",
              "groupUId": "1DB0AB9E-6D51-4197-A0C0-5B6833BF37B4",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "59F2150C-5CF6-4832-9DA0-C55242AF4342": {
              "coordinate": [
                  50,
                  20
              ],
              "uid": "59F2150C-5CF6-4832-9DA0-C55242AF4342",
              "groupUId": "016B2888-0567-4B9E-A274-4B93BB5296DB"
          },
          "0BA47633-37FA-4CBC-A5C5-A2104CE488D1": {
              "coordinate": [
                  0,
                  0
              ],
              "uid": "0BA47633-37FA-4CBC-A5C5-A2104CE488D1",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "23E55FC0-6752-4E42-94BA-DD5B710DED2E": {
              "coordinate": [
                  50,
                  49
              ],
              "uid": "23E55FC0-6752-4E42-94BA-DD5B710DED2E",
              "groupUId": "00E2025F-8540-4C02-A359-0C5F2B70E173",
              "type": "ExpandedAsg",
              "originalId": "59F2150C-5CF6-4832-9DA0-C55242AF4342"
          },
          "size": [
              240,
              240
          ]
      }

      componentKeys = _.keys component
      layoutKeys = _.keys layout

      keys = _.without (_.union componentKeys, layoutKeys), "size"

      layoutJson = JSON.stringify(layout)
      componentJson = JSON.stringify(component)

      # replace with random guid.
      _.each keys, (key)->
        guid = MC.guid()
        componentJson = componentJson.replace(new RegExp(key, "g"), guid)
        layoutJson = layoutJson.replace(new RegExp(key, "g"), guid)

      # replace region-id in subnet
      _.each _.pluck(amiForEachRegion, "region"), (region)->
        componentJson = componentJson.replace(new RegExp(region, "g"), regionName)

      # replace to dist imageId
      componentJson = componentJson.replace(/ami-\w{8}/g, imageId)

      component = JSON.parse(componentJson)
      layout = JSON.parse(layoutJson)

      # set framework option
      _.each component, (comp)->
        if comp.type in [constant.RESTYPE.INSTANCE, constant.RESTYPE.LC]
          _.each comp.state, (st)->
            if st.module in ["linux.mesos.master", "linux.mesos.slave"]
              st.parameter.framework = framework

      json.component = component
      json.layout = layout

      console.log json
      json

  }, {
    supportedProviders : ["aws::global", "aws::china"]
  }

  AwsOpsModel
