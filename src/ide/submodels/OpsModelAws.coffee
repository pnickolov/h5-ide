
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
      jsonType = @getJsonType()
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

      framework =  if @getJsonFramework() then ["marathon"] else []
      imageId = (_.findWhere amiForEachRegion, {region: @get("region")}).imageId
      regionName = @get("region")

      component = {
          "0F5EAE8A-8871-400F-8891-8066DC01AD00": {
              "name": "mesos",
              "description": "",
              "type": "AWS.VPC.VPC",
              "uid": "0F5EAE8A-8871-400F-8891-8066DC01AD00",
              "resource": {
                  "EnableDnsSupport": true,
                  "InstanceTenancy": "default",
                  "EnableDnsHostnames": false,
                  "DhcpOptionsId": "",
                  "VpcId": "",
                  "CidrBlock": "10.0.0.0/16"
              }
          },
          "BE1CB744-62FF-4C33-B89A-DF7FFAA3C98B": {
              "name": "DefaultACL",
              "type": "AWS.VPC.NetworkAcl",
              "uid": "BE1CB744-62FF-4C33-B89A-DF7FFAA3C98B",
              "resource": {
                  "AssociationSet": [
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{B23045A4-F5B1-4FBF-B712-C75B05F97E46.resource.SubnetId}"
                      },
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{52EF8818-9CD0-42FA-8028-6E79B1DB1567.resource.SubnetId}"
                      },
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{6522F64E-9CC0-48B7-8EF4-97AB83B39D96.resource.SubnetId}"
                      },
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{E8853BB7-FFD9-4F98-B175-A573A93F3F99.resource.SubnetId}"
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
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "Tags": [
                      {
                          "Key": "visops_default",
                          "Value": "true"
                      }
                  ]
              }
          },
          "A70042EC-F165-41DC-BB56-3D38ECD6845A": {
              "name": "RT-0",
              "description": "",
              "type": "AWS.VPC.RouteTable",
              "uid": "A70042EC-F165-41DC-BB56-3D38ECD6845A",
              "resource": {
                  "PropagatingVgwSet": [],
                  "RouteTableId": "",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
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
                          "GatewayId": "@{FB4F5E92-191D-4CA1-B9F8-C6CF7E81A419.resource.InternetGatewayId}"
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
          "F5197F0A-CB81-4769-8BEB-E9BFA6E6A857": {
              "uid": "F5197F0A-CB81-4769-8BEB-E9BFA6E6A857",
              "name": "us-east-1a",
              "type": "AWS.EC2.AvailabilityZone",
              "resource": {
                  "ZoneName": "us-east-1a",
                  "RegionName": "us-east-1"
              }
          },
          "B23045A4-F5B1-4FBF-B712-C75B05F97E46": {
              "name": "web-a",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "B23045A4-F5B1-4FBF-B712-C75B05F97E46",
              "resource": {
                  "AvailabilityZone": "@{F5197F0A-CB81-4769-8BEB-E9BFA6E6A857.resource.ZoneName}",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.0.0/24"
              }
          },
          "D2983D13-5DE7-4A8A-9A12-3BCB00FBB461": {
              "uid": "D2983D13-5DE7-4A8A-9A12-3BCB00FBB461",
              "name": "us-east-1b",
              "type": "AWS.EC2.AvailabilityZone",
              "resource": {
                  "ZoneName": "us-east-1b",
                  "RegionName": "us-east-1"
              }
          },
          "52EF8818-9CD0-42FA-8028-6E79B1DB1567": {
              "name": "sched-a",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "52EF8818-9CD0-42FA-8028-6E79B1DB1567",
              "resource": {
                  "AvailabilityZone": "@{F5197F0A-CB81-4769-8BEB-E9BFA6E6A857.resource.ZoneName}",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.2.0/24"
              }
          },
          "B7B7F6F0-45EA-4E36-8086-1C44DB802DFB": {
              "type": "AWS.EC2.Instance",
              "uid": "B7B7F6F0-45EA-4E36-8086-1C44DB802DFB",
              "name": "master-1",
              "description": "",
              "index": 0,
              "number": 1,
              "serverGroupUid": "B7B7F6F0-45EA-4E36-8086-1C44DB802DFB",
              "serverGroupName": "master-1",
              "state": [
                  {
                      "id": "master-1",
                      "module": "linux.mesos.master",
                      "parameter": {
                          "cluster_name": "untitled-0",
                          "master_ip": "@{self.PrivateIpAddress}",
                          "server_id": "master-1",
                          "masters_addresses": [
                              {
                                  "key": "@{B7B7F6F0-45EA-4E36-8086-1C44DB802DFB.PrivateIpAddress}",
                                  "value": "master-1"
                              },
                              {
                                  "key": "@{09F88228-07BA-471C-B8AB-F180C0053CC1.PrivateIpAddress}",
                                  "value": "master-2"
                              },
                              {
                                  "key": "@{B78DBB62-83CD-4C54-816D-6DE786DD157B.PrivateIpAddress}",
                                  "value": "master-0"
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
                      "AvailabilityZone": "@{F5197F0A-CB81-4769-8BEB-E9BFA6E6A857.resource.ZoneName}"
                  },
                  "InstanceId": "",
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{CD79496F-68E6-41F5-A587-C1016266CF39.resource.KeyName}",
                  "EbsOptimized": false,
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "@{52EF8818-9CD0-42FA-8028-6E79B1DB1567.resource.SubnetId}",
                  "Monitoring": "disabled",
                  "NetworkInterface": [],
                  "InstanceType": "t2.micro",
                  "DisableApiTermination": false,
                  "ShutdownBehavior": "terminate",
                  "SecurityGroup": [],
                  "SecurityGroupId": []
              }
          },
          "C3FFECAA-8EF3-4C1C-80B7-E8B94DD06874": {
              "index": 0,
              "uid": "C3FFECAA-8EF3-4C1C-80B7-E8B94DD06874",
              "type": "AWS.VPC.NetworkInterface",
              "name": "master-1-eni0",
              "serverGroupUid": "C3FFECAA-8EF3-4C1C-80B7-E8B94DD06874",
              "serverGroupName": "eni0",
              "number": 1,
              "resource": {
                  "SourceDestCheck": true,
                  "Description": "",
                  "NetworkInterfaceId": "",
                  "AvailabilityZone": "@{F5197F0A-CB81-4769-8BEB-E9BFA6E6A857.resource.ZoneName}",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "@{52EF8818-9CD0-42FA-8028-6E79B1DB1567.resource.SubnetId}",
                  "AssociatePublicIpAddress": false,
                  "PrivateIpAddressSet": [
                      {
                          "PrivateIpAddress": "10.0.2.5",
                          "AutoAssign": true,
                          "Primary": true
                      }
                  ],
                  "GroupSet": [
                      {
                          "GroupName": "@{A1C6F6DA-74B0-4DDD-8462-30313AEAE2C4.resource.GroupName}",
                          "GroupId": "@{A1C6F6DA-74B0-4DDD-8462-30313AEAE2C4.resource.GroupId}"
                      }
                  ],
                  "Attachment": {
                      "InstanceId": "@{B7B7F6F0-45EA-4E36-8086-1C44DB802DFB.resource.InstanceId}",
                      "DeviceIndex": "0",
                      "AttachmentId": ""
                  }
              }
          },
          "42A2C018-2E50-4673-B8B5-406401804018": {
              "uid": "42A2C018-2E50-4673-B8B5-406401804018",
              "type": "AWS.EC2.EIP",
              "name": "master-1-eni0-eip0",
              "index": 0,
              "resource": {
                  "Domain": "vpc",
                  "InstanceId": "",
                  "AllocationId": "",
                  "NetworkInterfaceId": "@{C3FFECAA-8EF3-4C1C-80B7-E8B94DD06874.resource.NetworkInterfaceId}",
                  "PrivateIpAddress": "@{C3FFECAA-8EF3-4C1C-80B7-E8B94DD06874.resource.PrivateIpAddressSet.0.PrivateIpAddress}",
                  "PublicIp": ""
              }
          },
          "CD79496F-68E6-41F5-A587-C1016266CF39": {
              "name": "DefaultKP",
              "type": "AWS.EC2.KeyPair",
              "uid": "CD79496F-68E6-41F5-A587-C1016266CF39",
              "resource": {
                  "KeyFingerprint": "",
                  "KeyName": "DefaultKP"
              }
          },
          "997088E4-E076-4105-A4C6-3CFA9C470A64": {
              "name": "MesosSG",
              "type": "AWS.EC2.SecurityGroup",
              "uid": "997088E4-E076-4105-A4C6-3CFA9C470A64",
              "resource": {
                  "Default": false,
                  "GroupId": "",
                  "GroupName": "MesosSG",
                  "GroupDescription": "Custom Security Group",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
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
                          "IpRanges": "@{997088E4-E076-4105-A4C6-3CFA9C470A64.resource.GroupId}",
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
          "6522F64E-9CC0-48B7-8EF4-97AB83B39D96": {
              "name": "sched-b",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "6522F64E-9CC0-48B7-8EF4-97AB83B39D96",
              "resource": {
                  "AvailabilityZone": "@{D2983D13-5DE7-4A8A-9A12-3BCB00FBB461.resource.ZoneName}",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.3.0/24"
              }
          },
          "09F88228-07BA-471C-B8AB-F180C0053CC1": {
              "type": "AWS.EC2.Instance",
              "uid": "09F88228-07BA-471C-B8AB-F180C0053CC1",
              "name": "master-2",
              "description": "",
              "index": 0,
              "number": 1,
              "serverGroupUid": "09F88228-07BA-471C-B8AB-F180C0053CC1",
              "serverGroupName": "master-2",
              "state": [
                  {
                      "id": "master-2",
                      "module": "linux.mesos.master",
                      "parameter": {
                          "cluster_name": "untitled-0",
                          "master_ip": "@{self.PrivateIpAddress}",
                          "server_id": "master-2",
                          "masters_addresses": [
                              {
                                  "key": "@{B7B7F6F0-45EA-4E36-8086-1C44DB802DFB.PrivateIpAddress}",
                                  "value": "master-1"
                              },
                              {
                                  "key": "@{09F88228-07BA-471C-B8AB-F180C0053CC1.PrivateIpAddress}",
                                  "value": "master-2"
                              },
                              {
                                  "key": "@{B78DBB62-83CD-4C54-816D-6DE786DD157B.PrivateIpAddress}",
                                  "value": "master-0"
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
                      "AvailabilityZone": "@{D2983D13-5DE7-4A8A-9A12-3BCB00FBB461.resource.ZoneName}"
                  },
                  "InstanceId": "",
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{CD79496F-68E6-41F5-A587-C1016266CF39.resource.KeyName}",
                  "EbsOptimized": false,
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "@{6522F64E-9CC0-48B7-8EF4-97AB83B39D96.resource.SubnetId}",
                  "Monitoring": "disabled",
                  "NetworkInterface": [],
                  "InstanceType": "t2.micro",
                  "DisableApiTermination": false,
                  "ShutdownBehavior": "terminate",
                  "SecurityGroup": [],
                  "SecurityGroupId": []
              }
          },
          "032524B2-696A-42A7-AF81-BF9C2591A250": {
              "index": 0,
              "uid": "032524B2-696A-42A7-AF81-BF9C2591A250",
              "type": "AWS.VPC.NetworkInterface",
              "name": "master-2-eni0",
              "serverGroupUid": "032524B2-696A-42A7-AF81-BF9C2591A250",
              "serverGroupName": "eni0",
              "number": 1,
              "resource": {
                  "SourceDestCheck": true,
                  "Description": "",
                  "NetworkInterfaceId": "",
                  "AvailabilityZone": "@{D2983D13-5DE7-4A8A-9A12-3BCB00FBB461.resource.ZoneName}",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "@{6522F64E-9CC0-48B7-8EF4-97AB83B39D96.resource.SubnetId}",
                  "AssociatePublicIpAddress": false,
                  "PrivateIpAddressSet": [
                      {
                          "PrivateIpAddress": "10.0.3.4",
                          "AutoAssign": true,
                          "Primary": true
                      }
                  ],
                  "GroupSet": [
                      {
                          "GroupName": "@{A1C6F6DA-74B0-4DDD-8462-30313AEAE2C4.resource.GroupName}",
                          "GroupId": "@{A1C6F6DA-74B0-4DDD-8462-30313AEAE2C4.resource.GroupId}"
                      }
                  ],
                  "Attachment": {
                      "InstanceId": "@{09F88228-07BA-471C-B8AB-F180C0053CC1.resource.InstanceId}",
                      "DeviceIndex": "0",
                      "AttachmentId": ""
                  }
              }
          },
          "6A0F8A7C-3CBB-464C-9563-18FFA711F12D": {
              "uid": "6A0F8A7C-3CBB-464C-9563-18FFA711F12D",
              "type": "AWS.EC2.EIP",
              "name": "master-2-eni0-eip0",
              "index": 0,
              "resource": {
                  "Domain": "vpc",
                  "InstanceId": "",
                  "AllocationId": "",
                  "NetworkInterfaceId": "@{032524B2-696A-42A7-AF81-BF9C2591A250.resource.NetworkInterfaceId}",
                  "PrivateIpAddress": "@{032524B2-696A-42A7-AF81-BF9C2591A250.resource.PrivateIpAddressSet.0.PrivateIpAddress}",
                  "PublicIp": ""
              }
          },
          "A1C6F6DA-74B0-4DDD-8462-30313AEAE2C4": {
              "name": "DefaultSG",
              "type": "AWS.EC2.SecurityGroup",
              "uid": "A1C6F6DA-74B0-4DDD-8462-30313AEAE2C4",
              "resource": {
                  "Default": true,
                  "GroupId": "",
                  "GroupName": "DefaultSG",
                  "GroupDescription": "default VPC security group",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
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
          "E8853BB7-FFD9-4F98-B175-A573A93F3F99": {
              "name": "web-b",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "E8853BB7-FFD9-4F98-B175-A573A93F3F99",
              "resource": {
                  "AvailabilityZone": "@{D2983D13-5DE7-4A8A-9A12-3BCB00FBB461.resource.ZoneName}",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.1.0/24"
              }
          },
          "FB4F5E92-191D-4CA1-B9F8-C6CF7E81A419": {
              "name": "Internet-gateway",
              "type": "AWS.VPC.InternetGateway",
              "uid": "FB4F5E92-191D-4CA1-B9F8-C6CF7E81A419",
              "resource": {
                  "InternetGatewayId": "",
                  "AttachmentSet": [
                      {
                          "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}"
                      }
                  ]
              }
          },
          "B78DBB62-83CD-4C54-816D-6DE786DD157B": {
              "type": "AWS.EC2.Instance",
              "uid": "B78DBB62-83CD-4C54-816D-6DE786DD157B",
              "name": "master-0",
              "description": "",
              "index": 0,
              "number": 1,
              "serverGroupUid": "B78DBB62-83CD-4C54-816D-6DE786DD157B",
              "serverGroupName": "master-0",
              "state": [
                  {
                      "id": "master-0",
                      "module": "linux.mesos.master",
                      "parameter": {
                          "cluster_name": "untitled-0",
                          "master_ip": "@{self.PrivateIpAddress}",
                          "server_id": "master-0",
                          "masters_addresses": [
                              {
                                  "key": "@{B7B7F6F0-45EA-4E36-8086-1C44DB802DFB.PrivateIpAddress}",
                                  "value": "master-1"
                              },
                              {
                                  "key": "@{09F88228-07BA-471C-B8AB-F180C0053CC1.PrivateIpAddress}",
                                  "value": "master-2"
                              },
                              {
                                  "key": "@{B78DBB62-83CD-4C54-816D-6DE786DD157B.PrivateIpAddress}",
                                  "value": "master-0"
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
                      "AvailabilityZone": "@{F5197F0A-CB81-4769-8BEB-E9BFA6E6A857.resource.ZoneName}"
                  },
                  "InstanceId": "",
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{CD79496F-68E6-41F5-A587-C1016266CF39.resource.KeyName}",
                  "EbsOptimized": false,
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "@{52EF8818-9CD0-42FA-8028-6E79B1DB1567.resource.SubnetId}",
                  "Monitoring": "disabled",
                  "NetworkInterface": [],
                  "InstanceType": "t2.micro",
                  "DisableApiTermination": false,
                  "ShutdownBehavior": "terminate",
                  "SecurityGroup": [],
                  "SecurityGroupId": []
              }
          },
          "91E54436-3E59-4E02-8621-0F81DBA97875": {
              "index": 0,
              "uid": "91E54436-3E59-4E02-8621-0F81DBA97875",
              "type": "AWS.VPC.NetworkInterface",
              "name": "master-0-eni0",
              "serverGroupUid": "91E54436-3E59-4E02-8621-0F81DBA97875",
              "serverGroupName": "eni0",
              "number": 1,
              "resource": {
                  "SourceDestCheck": true,
                  "Description": "",
                  "NetworkInterfaceId": "",
                  "AvailabilityZone": "@{F5197F0A-CB81-4769-8BEB-E9BFA6E6A857.resource.ZoneName}",
                  "VpcId": "@{0F5EAE8A-8871-400F-8891-8066DC01AD00.resource.VpcId}",
                  "SubnetId": "@{52EF8818-9CD0-42FA-8028-6E79B1DB1567.resource.SubnetId}",
                  "AssociatePublicIpAddress": false,
                  "PrivateIpAddressSet": [
                      {
                          "PrivateIpAddress": "10.0.2.4",
                          "AutoAssign": true,
                          "Primary": true
                      }
                  ],
                  "GroupSet": [
                      {
                          "GroupName": "@{A1C6F6DA-74B0-4DDD-8462-30313AEAE2C4.resource.GroupName}",
                          "GroupId": "@{A1C6F6DA-74B0-4DDD-8462-30313AEAE2C4.resource.GroupId}"
                      }
                  ],
                  "Attachment": {
                      "InstanceId": "@{B78DBB62-83CD-4C54-816D-6DE786DD157B.resource.InstanceId}",
                      "DeviceIndex": "0",
                      "AttachmentId": ""
                  }
              }
          },
          "B020835C-E106-4AB8-900D-53C64C0DDEA8": {
              "uid": "B020835C-E106-4AB8-900D-53C64C0DDEA8",
              "type": "AWS.EC2.EIP",
              "name": "master-0-eni0-eip0",
              "index": 0,
              "resource": {
                  "Domain": "vpc",
                  "InstanceId": "",
                  "AllocationId": "",
                  "NetworkInterfaceId": "@{91E54436-3E59-4E02-8621-0F81DBA97875.resource.NetworkInterfaceId}",
                  "PrivateIpAddress": "@{91E54436-3E59-4E02-8621-0F81DBA97875.resource.PrivateIpAddressSet.0.PrivateIpAddress}",
                  "PublicIp": ""
              }
          },
          "45EEF854-9388-42BF-9241-AF8AE250EA74": {
              "uid": "45EEF854-9388-42BF-9241-AF8AE250EA74",
              "name": "asg0",
              "description": "",
              "type": "AWS.AutoScaling.Group",
              "resource": {
                  "AvailabilityZones": [
                      "@{F5197F0A-CB81-4769-8BEB-E9BFA6E6A857.resource.ZoneName}",
                      "@{D2983D13-5DE7-4A8A-9A12-3BCB00FBB461.resource.ZoneName}"
                  ],
                  "VPCZoneIdentifier": "@{B23045A4-F5B1-4FBF-B712-C75B05F97E46.resource.SubnetId} , @{E8853BB7-FFD9-4F98-B175-A573A93F3F99.resource.SubnetId}",
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
                  "LaunchConfigurationName": "@{07EFEFD3-9B1A-43B9-B608-1EA90A2E54C1.resource.LaunchConfigurationName}"
              }
          },
          "07EFEFD3-9B1A-43B9-B608-1EA90A2E54C1": {
              "type": "AWS.AutoScaling.LaunchConfiguration",
              "uid": "07EFEFD3-9B1A-43B9-B608-1EA90A2E54C1",
              "name": "slave-lc-0",
              "description": "",
              "state": [
                  {
                      "id": "slave-lc-0",
                      "module": "linux.mesos.slave",
                      "parameter": {
                          "masters_addresses": [
                              {
                                  "key": "@{B7B7F6F0-45EA-4E36-8086-1C44DB802DFB.PrivateIpAddress}",
                                  "value": "master-1"
                              },
                              {
                                  "key": "@{09F88228-07BA-471C-B8AB-F180C0053CC1.PrivateIpAddress}",
                                  "value": "master-2"
                              },
                              {
                                  "key": "@{B78DBB62-83CD-4C54-816D-6DE786DD157B.PrivateIpAddress}",
                                  "value": "master-0"
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
                  "KeyName": "@{CD79496F-68E6-41F5-A587-C1016266CF39.resource.KeyName}",
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
                      "@{A1C6F6DA-74B0-4DDD-8462-30313AEAE2C4.resource.GroupId}"
                  ],
                  "LaunchConfigurationName": "slave-lc-0",
                  "InstanceType": "t2.micro",
                  "AssociatePublicIpAddress": true
              }
          }
      }

      layout = {
          "0F5EAE8A-8871-400F-8891-8066DC01AD00": {
              "coordinate": [
                  8,
                  7
              ],
              "uid": "0F5EAE8A-8871-400F-8891-8066DC01AD00",
              "size": [
                  83,
                  64
              ]
          },
          "A70042EC-F165-41DC-BB56-3D38ECD6845A": {
              "coordinate": [
                  76,
                  8
              ],
              "uid": "A70042EC-F165-41DC-BB56-3D38ECD6845A",
              "groupUId": "0F5EAE8A-8871-400F-8891-8066DC01AD00"
          },
          "F5197F0A-CB81-4769-8BEB-E9BFA6E6A857": {
              "coordinate": [
                  14,
                  14
              ],
              "uid": "F5197F0A-CB81-4769-8BEB-E9BFA6E6A857",
              "groupUId": "0F5EAE8A-8871-400F-8891-8066DC01AD00",
              "size": [
                  55,
                  25
              ]
          },
          "B23045A4-F5B1-4FBF-B712-C75B05F97E46": {
              "coordinate": [
                  47,
                  17
              ],
              "uid": "B23045A4-F5B1-4FBF-B712-C75B05F97E46",
              "groupUId": "F5197F0A-CB81-4769-8BEB-E9BFA6E6A857",
              "size": [
                  19,
                  19
              ]
          },
          "D2983D13-5DE7-4A8A-9A12-3BCB00FBB461": {
              "coordinate": [
                  14,
                  43
              ],
              "uid": "D2983D13-5DE7-4A8A-9A12-3BCB00FBB461",
              "groupUId": "0F5EAE8A-8871-400F-8891-8066DC01AD00",
              "size": [
                  55,
                  24
              ]
          },
          "52EF8818-9CD0-42FA-8028-6E79B1DB1567": {
              "coordinate": [
                  17,
                  17
              ],
              "uid": "52EF8818-9CD0-42FA-8028-6E79B1DB1567",
              "groupUId": "F5197F0A-CB81-4769-8BEB-E9BFA6E6A857",
              "size": [
                  27,
                  19
              ]
          },
          "B7B7F6F0-45EA-4E36-8086-1C44DB802DFB": {
              "coordinate": [
                  32,
                  22
              ],
              "uid": "B7B7F6F0-45EA-4E36-8086-1C44DB802DFB",
              "groupUId": "52EF8818-9CD0-42FA-8028-6E79B1DB1567",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "6522F64E-9CC0-48B7-8EF4-97AB83B39D96": {
              "coordinate": [
                  17,
                  46
              ],
              "uid": "6522F64E-9CC0-48B7-8EF4-97AB83B39D96",
              "groupUId": "D2983D13-5DE7-4A8A-9A12-3BCB00FBB461",
              "size": [
                  28,
                  18
              ]
          },
          "09F88228-07BA-471C-B8AB-F180C0053CC1": {
              "coordinate": [
                  21,
                  51
              ],
              "uid": "09F88228-07BA-471C-B8AB-F180C0053CC1",
              "groupUId": "6522F64E-9CC0-48B7-8EF4-97AB83B39D96",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "E8853BB7-FFD9-4F98-B175-A573A93F3F99": {
              "coordinate": [
                  47,
                  46
              ],
              "uid": "E8853BB7-FFD9-4F98-B175-A573A93F3F99",
              "groupUId": "D2983D13-5DE7-4A8A-9A12-3BCB00FBB461",
              "size": [
                  19,
                  18
              ]
          },
          "FB4F5E92-191D-4CA1-B9F8-C6CF7E81A419": {
              "coordinate": [
                  4,
                  8
              ],
              "uid": "FB4F5E92-191D-4CA1-B9F8-C6CF7E81A419",
              "groupUId": "0F5EAE8A-8871-400F-8891-8066DC01AD00"
          },
          "B78DBB62-83CD-4C54-816D-6DE786DD157B": {
              "coordinate": [
                  21,
                  22
              ],
              "uid": "B78DBB62-83CD-4C54-816D-6DE786DD157B",
              "groupUId": "52EF8818-9CD0-42FA-8028-6E79B1DB1567",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "45EEF854-9388-42BF-9241-AF8AE250EA74": {
              "coordinate": [
                  50,
                  20
              ],
              "uid": "45EEF854-9388-42BF-9241-AF8AE250EA74",
              "groupUId": "B23045A4-F5B1-4FBF-B712-C75B05F97E46"
          },
          "07EFEFD3-9B1A-43B9-B608-1EA90A2E54C1": {
              "coordinate": [
                  0,
                  0
              ],
              "uid": "07EFEFD3-9B1A-43B9-B608-1EA90A2E54C1",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "F2DD8725-DF3D-4944-966A-A64B952FAA92": {
              "coordinate": [
                  50,
                  49
              ],
              "uid": "F2DD8725-DF3D-4944-966A-A64B952FAA92",
              "groupUId": "E8853BB7-FFD9-4F98-B175-A573A93F3F99",
              "type": "ExpandedAsg",
              "originalId": "45EEF854-9388-42BF-9241-AF8AE250EA74"
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
        if comp.type is constant.RESTYPE.INSTANCE
          _.each comp.state, (st)->
            if st.module is "linux.mesos.master"
              st.parameter.framework = framework

      json.component = component
      json.layout = layout

      console.log json
      json

  }, {
    supportedProviders : ["aws::global", "aws::china"]
  }

  AwsOpsModel
