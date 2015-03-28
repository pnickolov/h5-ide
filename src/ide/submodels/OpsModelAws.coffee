
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
          "157BD2E2-F118-42F9-B705-63A98411707A": {
              "name": "RT-0",
              "description": "",
              "type": "AWS.VPC.RouteTable",
              "uid": "157BD2E2-F118-42F9-B705-63A98411707A",
              "resource": {
                  "PropagatingVgwSet": [],
                  "RouteTableId": "",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
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
                          "GatewayId": "@{7E732F1C-63ED-47AE-AAD4-958A6BC0D9F6.resource.InternetGatewayId}"
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
          "2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB": {
              "name": "mesos",
              "description": "",
              "type": "AWS.VPC.VPC",
              "uid": "2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB",
              "resource": {
                  "EnableDnsSupport": true,
                  "InstanceTenancy": "default",
                  "EnableDnsHostnames": false,
                  "DhcpOptionsId": "",
                  "VpcId": "",
                  "CidrBlock": "10.0.0.0/16"
              }
          },
          "A642D229-6533-499C-BCDF-DEE06CB16C65": {
              "name": "DefaultACL",
              "type": "AWS.VPC.NetworkAcl",
              "uid": "A642D229-6533-499C-BCDF-DEE06CB16C65",
              "resource": {
                  "AssociationSet": [
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{C02C9B48-51D2-4981-AD49-8A3A6AF59845.resource.SubnetId}"
                      },
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{E66C8CBE-D907-42A5-87BD-A59514BDB3BE.resource.SubnetId}"
                      },
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{490511EA-C1E0-4242-82B6-440430D38497.resource.SubnetId}"
                      },
                      {
                          "NetworkAclAssociationId": "",
                          "SubnetId": "@{7EE3C44B-4F77-477D-91FD-4C7BB6F978D4.resource.SubnetId}"
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
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "Tags": [
                      {
                          "Key": "visops_default",
                          "Value": "true"
                      }
                  ]
              }
          },
          "382C7D37-3D53-42BA-B7D7-F34E1D87378A": {
              "uid": "382C7D37-3D53-42BA-B7D7-F34E1D87378A",
              "name": "us-east-1b",
              "type": "AWS.EC2.AvailabilityZone",
              "resource": {
                  "ZoneName": "us-east-1b",
                  "RegionName": "us-east-1"
              }
          },
          "C02C9B48-51D2-4981-AD49-8A3A6AF59845": {
              "name": "sched-b",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "C02C9B48-51D2-4981-AD49-8A3A6AF59845",
              "resource": {
                  "AvailabilityZone": "@{382C7D37-3D53-42BA-B7D7-F34E1D87378A.resource.ZoneName}",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.3.0/24"
              }
          },
          "4A088968-344E-4FB6-AD33-F9A4848D7C47": {
              "type": "AWS.EC2.Instance",
              "uid": "4A088968-344E-4FB6-AD33-F9A4848D7C47",
              "name": "master-2",
              "description": "",
              "index": 0,
              "number": 1,
              "serverGroupUid": "4A088968-344E-4FB6-AD33-F9A4848D7C47",
              "serverGroupName": "master-2",
              "state": [
                  {
                      "id": "master-2",
                      "module": "linux.mesos.master",
                      "parameter": {
                          "cluster_name": "untitled-26",
                          "master_ip": "@{self.PrivateIpAddress}",
                          "server_id": "master-2",
                          "masters_addresses": [
                              {
                                  "key": "@{4A088968-344E-4FB6-AD33-F9A4848D7C47.PrivateIpAddress}",
                                  "value": "master-2"
                              },
                              {
                                  "key": "@{0199BC30-7F88-4329-A598-DAAF4E68B1B0.PrivateIpAddress}",
                                  "value": "master-0"
                              },
                              {
                                  "key": "@{71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8.PrivateIpAddress}",
                                  "value": "master-1"
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
                      "AvailabilityZone": "@{382C7D37-3D53-42BA-B7D7-F34E1D87378A.resource.ZoneName}"
                  },
                  "InstanceId": "",
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{A7F19316-752C-4EB1-939F-94FFE0A462A2.resource.KeyName}",
                  "EbsOptimized": false,
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "@{C02C9B48-51D2-4981-AD49-8A3A6AF59845.resource.SubnetId}",
                  "Monitoring": "disabled",
                  "NetworkInterface": [],
                  "InstanceType": "t2.micro",
                  "DisableApiTermination": false,
                  "ShutdownBehavior": "terminate",
                  "SecurityGroup": [],
                  "SecurityGroupId": []
              }
          },
          "6143DDAB-B73A-43A6-9158-C25E3D857498": {
              "index": 0,
              "uid": "6143DDAB-B73A-43A6-9158-C25E3D857498",
              "type": "AWS.VPC.NetworkInterface",
              "name": "master-2-eni0",
              "serverGroupUid": "6143DDAB-B73A-43A6-9158-C25E3D857498",
              "serverGroupName": "eni0",
              "number": 1,
              "resource": {
                  "SourceDestCheck": true,
                  "Description": "",
                  "NetworkInterfaceId": "",
                  "AvailabilityZone": "@{382C7D37-3D53-42BA-B7D7-F34E1D87378A.resource.ZoneName}",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "@{C02C9B48-51D2-4981-AD49-8A3A6AF59845.resource.SubnetId}",
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
                          "GroupName": "@{B7FFFF8A-3E12-4022-844B-0B39075D676A.resource.GroupName}",
                          "GroupId": "@{B7FFFF8A-3E12-4022-844B-0B39075D676A.resource.GroupId}"
                      }
                  ],
                  "Attachment": {
                      "InstanceId": "@{4A088968-344E-4FB6-AD33-F9A4848D7C47.resource.InstanceId}",
                      "DeviceIndex": "0",
                      "AttachmentId": ""
                  }
              }
          },
          "A7F19316-752C-4EB1-939F-94FFE0A462A2": {
              "name": "DefaultKP",
              "type": "AWS.EC2.KeyPair",
              "uid": "A7F19316-752C-4EB1-939F-94FFE0A462A2",
              "resource": {
                  "KeyFingerprint": "",
                  "KeyName": "DefaultKP"
              }
          },
          "B7FFFF8A-3E12-4022-844B-0B39075D676A": {
              "name": "DefaultSG",
              "type": "AWS.EC2.SecurityGroup",
              "uid": "B7FFFF8A-3E12-4022-844B-0B39075D676A",
              "resource": {
                  "Default": true,
                  "GroupId": "",
                  "GroupName": "DefaultSG",
                  "GroupDescription": "default VPC security group",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
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
          "E66C8CBE-D907-42A5-87BD-A59514BDB3BE": {
              "name": "web-b",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "E66C8CBE-D907-42A5-87BD-A59514BDB3BE",
              "resource": {
                  "AvailabilityZone": "@{382C7D37-3D53-42BA-B7D7-F34E1D87378A.resource.ZoneName}",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.1.0/24"
              }
          },
          "88EA511C-92B9-448B-9662-6241D417F9E1": {
              "uid": "88EA511C-92B9-448B-9662-6241D417F9E1",
              "name": "us-east-1a",
              "type": "AWS.EC2.AvailabilityZone",
              "resource": {
                  "ZoneName": "us-east-1a",
                  "RegionName": "us-east-1"
              }
          },
          "490511EA-C1E0-4242-82B6-440430D38497": {
              "name": "web-a",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "490511EA-C1E0-4242-82B6-440430D38497",
              "resource": {
                  "AvailabilityZone": "@{88EA511C-92B9-448B-9662-6241D417F9E1.resource.ZoneName}",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.0.0/24"
              }
          },
          "7EE3C44B-4F77-477D-91FD-4C7BB6F978D4": {
              "name": "sched-a",
              "description": "",
              "type": "AWS.VPC.Subnet",
              "uid": "7EE3C44B-4F77-477D-91FD-4C7BB6F978D4",
              "resource": {
                  "AvailabilityZone": "@{88EA511C-92B9-448B-9662-6241D417F9E1.resource.ZoneName}",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "",
                  "CidrBlock": "10.0.2.0/24"
              }
          },
          "0199BC30-7F88-4329-A598-DAAF4E68B1B0": {
              "type": "AWS.EC2.Instance",
              "uid": "0199BC30-7F88-4329-A598-DAAF4E68B1B0",
              "name": "master-0",
              "description": "",
              "index": 0,
              "number": 1,
              "serverGroupUid": "0199BC30-7F88-4329-A598-DAAF4E68B1B0",
              "serverGroupName": "master-0",
              "state": [
                  {
                      "id": "master-0",
                      "module": "linux.mesos.master",
                      "parameter": {
                          "cluster_name": "untitled-26",
                          "master_ip": "@{self.PrivateIpAddress}",
                          "server_id": "master-0",
                          "masters_addresses": [
                              {
                                  "key": "@{4A088968-344E-4FB6-AD33-F9A4848D7C47.PrivateIpAddress}",
                                  "value": "master-2"
                              },
                              {
                                  "key": "@{0199BC30-7F88-4329-A598-DAAF4E68B1B0.PrivateIpAddress}",
                                  "value": "master-0"
                              },
                              {
                                  "key": "@{71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8.PrivateIpAddress}",
                                  "value": "master-1"
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
                      "AvailabilityZone": "@{88EA511C-92B9-448B-9662-6241D417F9E1.resource.ZoneName}"
                  },
                  "InstanceId": "",
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{A7F19316-752C-4EB1-939F-94FFE0A462A2.resource.KeyName}",
                  "EbsOptimized": false,
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "@{7EE3C44B-4F77-477D-91FD-4C7BB6F978D4.resource.SubnetId}",
                  "Monitoring": "disabled",
                  "NetworkInterface": [],
                  "InstanceType": "t2.micro",
                  "DisableApiTermination": false,
                  "ShutdownBehavior": "terminate",
                  "SecurityGroup": [],
                  "SecurityGroupId": []
              }
          },
          "9B23CCFB-6EF9-48F7-B5A7-23FE02D4D94B": {
              "index": 0,
              "uid": "9B23CCFB-6EF9-48F7-B5A7-23FE02D4D94B",
              "type": "AWS.VPC.NetworkInterface",
              "name": "master-0-eni0",
              "serverGroupUid": "9B23CCFB-6EF9-48F7-B5A7-23FE02D4D94B",
              "serverGroupName": "eni0",
              "number": 1,
              "resource": {
                  "SourceDestCheck": true,
                  "Description": "",
                  "NetworkInterfaceId": "",
                  "AvailabilityZone": "@{88EA511C-92B9-448B-9662-6241D417F9E1.resource.ZoneName}",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "@{7EE3C44B-4F77-477D-91FD-4C7BB6F978D4.resource.SubnetId}",
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
                          "GroupName": "@{B7FFFF8A-3E12-4022-844B-0B39075D676A.resource.GroupName}",
                          "GroupId": "@{B7FFFF8A-3E12-4022-844B-0B39075D676A.resource.GroupId}"
                      }
                  ],
                  "Attachment": {
                      "InstanceId": "@{0199BC30-7F88-4329-A598-DAAF4E68B1B0.resource.InstanceId}",
                      "DeviceIndex": "0",
                      "AttachmentId": ""
                  }
              }
          },
          "7E732F1C-63ED-47AE-AAD4-958A6BC0D9F6": {
              "name": "Internet-gateway",
              "type": "AWS.VPC.InternetGateway",
              "uid": "7E732F1C-63ED-47AE-AAD4-958A6BC0D9F6",
              "resource": {
                  "InternetGatewayId": "",
                  "AttachmentSet": [
                      {
                          "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}"
                      }
                  ]
              }
          },
          "CC8D8DBE-8536-4F3A-9EB3-D6657E20B36E": {
              "name": "MesosSG",
              "type": "AWS.EC2.SecurityGroup",
              "uid": "CC8D8DBE-8536-4F3A-9EB3-D6657E20B36E",
              "resource": {
                  "Default": false,
                  "GroupId": "",
                  "GroupName": "MesosSG",
                  "GroupDescription": "Custom Security Group",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
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
                          "IpRanges": "@{CC8D8DBE-8536-4F3A-9EB3-D6657E20B36E.resource.GroupId}",
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
          "71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8": {
              "type": "AWS.EC2.Instance",
              "uid": "71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8",
              "name": "master-1",
              "description": "",
              "index": 0,
              "number": 1,
              "serverGroupUid": "71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8",
              "serverGroupName": "master-1",
              "state": [
                  {
                      "id": "master-1",
                      "module": "linux.mesos.master",
                      "parameter": {
                          "cluster_name": "untitled-26",
                          "master_ip": "@{self.PrivateIpAddress}",
                          "server_id": "master-1",
                          "masters_addresses": [
                              {
                                  "key": "@{4A088968-344E-4FB6-AD33-F9A4848D7C47.PrivateIpAddress}",
                                  "value": "master-2"
                              },
                              {
                                  "key": "@{0199BC30-7F88-4329-A598-DAAF4E68B1B0.PrivateIpAddress}",
                                  "value": "master-0"
                              },
                              {
                                  "key": "@{71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8.PrivateIpAddress}",
                                  "value": "master-1"
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
                      "AvailabilityZone": "@{88EA511C-92B9-448B-9662-6241D417F9E1.resource.ZoneName}"
                  },
                  "InstanceId": "",
                  "ImageId": "ami-9ef278f6",
                  "KeyName": "@{A7F19316-752C-4EB1-939F-94FFE0A462A2.resource.KeyName}",
                  "EbsOptimized": false,
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "@{7EE3C44B-4F77-477D-91FD-4C7BB6F978D4.resource.SubnetId}",
                  "Monitoring": "disabled",
                  "NetworkInterface": [],
                  "InstanceType": "t2.micro",
                  "DisableApiTermination": false,
                  "ShutdownBehavior": "terminate",
                  "SecurityGroup": [],
                  "SecurityGroupId": []
              }
          },
          "6BEEFE93-0224-4450-B828-9726270532EF": {
              "index": 0,
              "uid": "6BEEFE93-0224-4450-B828-9726270532EF",
              "type": "AWS.VPC.NetworkInterface",
              "name": "master-1-eni0",
              "serverGroupUid": "6BEEFE93-0224-4450-B828-9726270532EF",
              "serverGroupName": "eni0",
              "number": 1,
              "resource": {
                  "SourceDestCheck": true,
                  "Description": "",
                  "NetworkInterfaceId": "",
                  "AvailabilityZone": "@{88EA511C-92B9-448B-9662-6241D417F9E1.resource.ZoneName}",
                  "VpcId": "@{2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB.resource.VpcId}",
                  "SubnetId": "@{7EE3C44B-4F77-477D-91FD-4C7BB6F978D4.resource.SubnetId}",
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
                          "GroupName": "@{B7FFFF8A-3E12-4022-844B-0B39075D676A.resource.GroupName}",
                          "GroupId": "@{B7FFFF8A-3E12-4022-844B-0B39075D676A.resource.GroupId}"
                      }
                  ],
                  "Attachment": {
                      "InstanceId": "@{71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8.resource.InstanceId}",
                      "DeviceIndex": "0",
                      "AttachmentId": ""
                  }
              }
          },
          "674999A7-8CBA-4D63-B85B-F8A550D869D9": {
              "uid": "674999A7-8CBA-4D63-B85B-F8A550D869D9",
              "name": "asg0",
              "description": "",
              "type": "AWS.AutoScaling.Group",
              "resource": {
                  "AvailabilityZones": [
                      "@{88EA511C-92B9-448B-9662-6241D417F9E1.resource.ZoneName}"
                  ],
                  "VPCZoneIdentifier": "@{490511EA-C1E0-4242-82B6-440430D38497.resource.SubnetId}",
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
                  "LaunchConfigurationName": "@{632AC5BE-C331-45BA-8338-E6FA0B2447C9.resource.LaunchConfigurationName}"
              }
          },
          "632AC5BE-C331-45BA-8338-E6FA0B2447C9": {
              "type": "AWS.AutoScaling.LaunchConfiguration",
              "uid": "632AC5BE-C331-45BA-8338-E6FA0B2447C9",
              "name": "slave-lc-0",
              "description": "",
              "state": [
                  {
                      "id": "slave-lc-0",
                      "module": "linux.mesos.slave",
                      "parameter": {
                          "attributes": [],
                          "masters_addresses": [
                              {
                                  "key": "@{4A088968-344E-4FB6-AD33-F9A4848D7C47.PrivateIpAddress}",
                                  "value": "master-2"
                              },
                              {
                                  "key": "@{0199BC30-7F88-4329-A598-DAAF4E68B1B0.PrivateIpAddress}",
                                  "value": "master-0"
                              },
                              {
                                  "key": "@{71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8.PrivateIpAddress}",
                                  "value": "master-1"
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
                  "KeyName": "@{A7F19316-752C-4EB1-939F-94FFE0A462A2.resource.KeyName}",
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
                      "@{B7FFFF8A-3E12-4022-844B-0B39075D676A.resource.GroupId}"
                  ],
                  "LaunchConfigurationName": "slave-lc-0",
                  "InstanceType": "t2.micro",
                  "AssociatePublicIpAddress": false
              }
          },
          "9243FEDE-FF98-4947-8F68-8139D5032FEA": {
              "uid": "9243FEDE-FF98-4947-8F68-8139D5032FEA",
              "name": "asg1",
              "description": "",
              "type": "AWS.AutoScaling.Group",
              "resource": {
                  "AvailabilityZones": [
                      "@{382C7D37-3D53-42BA-B7D7-F34E1D87378A.resource.ZoneName}"
                  ],
                  "VPCZoneIdentifier": "@{E66C8CBE-D907-42A5-87BD-A59514BDB3BE.resource.SubnetId}",
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
                  "AutoScalingGroupName": "asg1",
                  "DesiredCapacity": "1",
                  "LaunchConfigurationName": "@{70DBD117-FF47-4D97-B272-2617A371C887.resource.LaunchConfigurationName}"
              }
          },
          "70DBD117-FF47-4D97-B272-2617A371C887": {
              "type": "AWS.AutoScaling.LaunchConfiguration",
              "uid": "70DBD117-FF47-4D97-B272-2617A371C887",
              "name": "slave-lc-1",
              "description": "",
              "state": [
                  {
                      "id": "slave-lc-1",
                      "module": "linux.mesos.slave",
                      "parameter": {
                          "attributes": [],
                          "masters_addresses": [
                              {
                                  "key": "@{4A088968-344E-4FB6-AD33-F9A4848D7C47.PrivateIpAddress}",
                                  "value": "master-2"
                              },
                              {
                                  "key": "@{0199BC30-7F88-4329-A598-DAAF4E68B1B0.PrivateIpAddress}",
                                  "value": "master-0"
                              },
                              {
                                  "key": "@{71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8.PrivateIpAddress}",
                                  "value": "master-1"
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
                  "KeyName": "@{A7F19316-752C-4EB1-939F-94FFE0A462A2.resource.KeyName}",
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
                      "@{B7FFFF8A-3E12-4022-844B-0B39075D676A.resource.GroupId}"
                  ],
                  "LaunchConfigurationName": "slave-lc-1",
                  "InstanceType": "t2.micro",
                  "AssociatePublicIpAddress": false
              }
          }
      }

      layout = {
          "157BD2E2-F118-42F9-B705-63A98411707A": {
              "coordinate": [
                  76,
                  8
              ],
              "uid": "157BD2E2-F118-42F9-B705-63A98411707A",
              "groupUId": "2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB"
          },
          "2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB": {
              "coordinate": [
                  8,
                  7
              ],
              "uid": "2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB",
              "size": [
                  83,
                  64
              ]
          },
          "382C7D37-3D53-42BA-B7D7-F34E1D87378A": {
              "coordinate": [
                  14,
                  43
              ],
              "uid": "382C7D37-3D53-42BA-B7D7-F34E1D87378A",
              "groupUId": "2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB",
              "size": [
                  55,
                  24
              ]
          },
          "C02C9B48-51D2-4981-AD49-8A3A6AF59845": {
              "coordinate": [
                  17,
                  46
              ],
              "uid": "C02C9B48-51D2-4981-AD49-8A3A6AF59845",
              "groupUId": "382C7D37-3D53-42BA-B7D7-F34E1D87378A",
              "size": [
                  28,
                  18
              ]
          },
          "4A088968-344E-4FB6-AD33-F9A4848D7C47": {
              "coordinate": [
                  21,
                  51
              ],
              "uid": "4A088968-344E-4FB6-AD33-F9A4848D7C47",
              "groupUId": "C02C9B48-51D2-4981-AD49-8A3A6AF59845",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "E66C8CBE-D907-42A5-87BD-A59514BDB3BE": {
              "coordinate": [
                  47,
                  46
              ],
              "uid": "E66C8CBE-D907-42A5-87BD-A59514BDB3BE",
              "groupUId": "382C7D37-3D53-42BA-B7D7-F34E1D87378A",
              "size": [
                  19,
                  18
              ]
          },
          "88EA511C-92B9-448B-9662-6241D417F9E1": {
              "coordinate": [
                  14,
                  14
              ],
              "uid": "88EA511C-92B9-448B-9662-6241D417F9E1",
              "groupUId": "2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB",
              "size": [
                  55,
                  25
              ]
          },
          "490511EA-C1E0-4242-82B6-440430D38497": {
              "coordinate": [
                  47,
                  17
              ],
              "uid": "490511EA-C1E0-4242-82B6-440430D38497",
              "groupUId": "88EA511C-92B9-448B-9662-6241D417F9E1",
              "size": [
                  19,
                  19
              ]
          },
          "7EE3C44B-4F77-477D-91FD-4C7BB6F978D4": {
              "coordinate": [
                  17,
                  17
              ],
              "uid": "7EE3C44B-4F77-477D-91FD-4C7BB6F978D4",
              "groupUId": "88EA511C-92B9-448B-9662-6241D417F9E1",
              "size": [
                  27,
                  19
              ]
          },
          "0199BC30-7F88-4329-A598-DAAF4E68B1B0": {
              "coordinate": [
                  21,
                  22
              ],
              "uid": "0199BC30-7F88-4329-A598-DAAF4E68B1B0",
              "groupUId": "7EE3C44B-4F77-477D-91FD-4C7BB6F978D4",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "7E732F1C-63ED-47AE-AAD4-958A6BC0D9F6": {
              "coordinate": [
                  4,
                  8
              ],
              "uid": "7E732F1C-63ED-47AE-AAD4-958A6BC0D9F6",
              "groupUId": "2252668C-0A82-4BFF-8FA3-F2D58DC9FFFB"
          },
          "71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8": {
              "coordinate": [
                  32,
                  22
              ],
              "uid": "71ECF9B2-B8CA-43C3-9CDF-9A0BD6C8CDF8",
              "groupUId": "7EE3C44B-4F77-477D-91FD-4C7BB6F978D4",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "674999A7-8CBA-4D63-B85B-F8A550D869D9": {
              "coordinate": [
                  50,
                  20
              ],
              "uid": "674999A7-8CBA-4D63-B85B-F8A550D869D9",
              "groupUId": "490511EA-C1E0-4242-82B6-440430D38497"
          },
          "632AC5BE-C331-45BA-8338-E6FA0B2447C9": {
              "coordinate": [
                  0,
                  0
              ],
              "uid": "632AC5BE-C331-45BA-8338-E6FA0B2447C9",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
          },
          "9243FEDE-FF98-4947-8F68-8139D5032FEA": {
              "coordinate": [
                  50,
                  49
              ],
              "uid": "9243FEDE-FF98-4947-8F68-8139D5032FEA",
              "groupUId": "E66C8CBE-D907-42A5-87BD-A59514BDB3BE"
          },
          "70DBD117-FF47-4D97-B272-2617A371C887": {
              "coordinate": [
                  0,
                  0
              ],
              "uid": "70DBD117-FF47-4D97-B272-2617A371C887",
              "osType": "ubuntu",
              "architecture": "x86_64",
              "rootDeviceType": "ebs"
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
