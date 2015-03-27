
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

      framework =  if @get("framework") then ["marathon"] else []
      imageId = (_.findWhere amiForEachRegion, {region: @get("region")}).imageId
      regionName = @get("region")

      component = {
        "A4C89BFC-34DE-429B-BBFB-E515C91606F5": {
          "name": "RT-0",
          "description": "",
          "type": "AWS.VPC.RouteTable",
          "uid": "A4C89BFC-34DE-429B-BBFB-E515C91606F5",
          "resource": {
            "PropagatingVgwSet": [],
            "RouteTableId": "",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "AssociationSet": [{
              "Main": "true",
              "RouteTableAssociationId": "",
              "SubnetId": ""
            }],
            "RouteSet": [{
              "Origin": "CreateRouteTable",
              "DestinationCidrBlock": "10.0.0.0/16",
              "InstanceId": "",
              "NetworkInterfaceId": "",
              "GatewayId": "local"
            }, {
              "DestinationCidrBlock": "0.0.0.0/0",
              "Origin": "",
              "InstanceId": "",
              "NetworkInterfaceId": "",
              "GatewayId": "@{C4C4DBFE-78BE-4280-A115-25CF91287402.resource.InternetGatewayId}"
            }],
            "Tags": [{
              "Key": "visops_default",
              "Value": "true"
            }]
          }
        },
        "962B6392-5D8C-4CB9-9F0F-EB3FE253BBCA": {
          "name": "DefaultACL",
          "type": "AWS.VPC.NetworkAcl",
          "uid": "962B6392-5D8C-4CB9-9F0F-EB3FE253BBCA",
          "resource": {
            "AssociationSet": [{
              "NetworkAclAssociationId": "",
              "SubnetId": "@{3BC4CB02-59E9-445D-82A4-64B83862DBAE.resource.SubnetId}"
            }, {
              "NetworkAclAssociationId": "",
              "SubnetId": "@{CB6AF63A-91BE-42DF-B0DA-03AF4270A766.resource.SubnetId}"
            }, {
              "NetworkAclAssociationId": "",
              "SubnetId": "@{A67A1584-9771-4438-9A70-F62A767297D4.resource.SubnetId}"
            }, {
              "NetworkAclAssociationId": "",
              "SubnetId": "@{0E12C110-DBE7-4FAD-8B13-DFD7CB566ACE.resource.SubnetId}"
            }],
            "Default": true,
            "EntrySet": [{
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
            }, {
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
            }, {
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
            }, {
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
            }],
            "NetworkAclId": "",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "Tags": [{
              "Key": "visops_default",
              "Value": "true"
            }]
          }
        },
        "71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A": {
          "name": "mesos",
          "description": "",
          "type": "AWS.VPC.VPC",
          "uid": "71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A",
          "resource": {
            "EnableDnsSupport": true,
            "InstanceTenancy": "default",
            "EnableDnsHostnames": false,
            "DhcpOptionsId": "",
            "VpcId": "",
            "CidrBlock": "10.0.0.0/16"
          }
        },
        "856A9E6F-F6A5-4651-824A-8A01F9DE290A": {
          "uid": "856A9E6F-F6A5-4651-824A-8A01F9DE290A",
          "name": "us-east-1a",
          "type": "AWS.EC2.AvailabilityZone",
          "resource": {
            "ZoneName": "us-east-1a",
            "RegionName": "us-east-1"
          }
        },
        "3BC4CB02-59E9-445D-82A4-64B83862DBAE": {
          "name": "sched-a",
          "description": "",
          "type": "AWS.VPC.Subnet",
          "uid": "3BC4CB02-59E9-445D-82A4-64B83862DBAE",
          "resource": {
            "AvailabilityZone": "@{856A9E6F-F6A5-4651-824A-8A01F9DE290A.resource.ZoneName}",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "",
            "CidrBlock": "10.0.2.0/24"
          }
        },
        "88FEA146-74E1-4DE0-BB80-D42927FC4224": {
          "uid": "88FEA146-74E1-4DE0-BB80-D42927FC4224",
          "name": "us-east-1b",
          "type": "AWS.EC2.AvailabilityZone",
          "resource": {
            "ZoneName": "us-east-1b",
            "RegionName": "us-east-1"
          }
        },
        "CB6AF63A-91BE-42DF-B0DA-03AF4270A766": {
          "name": "sched-b",
          "description": "",
          "type": "AWS.VPC.Subnet",
          "uid": "CB6AF63A-91BE-42DF-B0DA-03AF4270A766",
          "resource": {
            "AvailabilityZone": "@{88FEA146-74E1-4DE0-BB80-D42927FC4224.resource.ZoneName}",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "",
            "CidrBlock": "10.0.3.0/24"
          }
        },
        "ACD8B4D3-55B0-47BB-81FB-411773EF4A61": {
          "name": "DefaultKP",
          "type": "AWS.EC2.KeyPair",
          "uid": "ACD8B4D3-55B0-47BB-81FB-411773EF4A61",
          "resource": {
            "KeyFingerprint": "",
            "KeyName": "DefaultKP"
          }
        },
        "5CB5F439-BB9B-4C0F-8B57-F2404F6B2FAA": {
          "name": "DefaultSG",
          "type": "AWS.EC2.SecurityGroup",
          "uid": "5CB5F439-BB9B-4C0F-8B57-F2404F6B2FAA",
          "resource": {
            "Default": true,
            "GroupId": "",
            "GroupName": "DefaultSG",
            "GroupDescription": "default VPC security group",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "IpPermissions": [{
              "FromPort": "22",
              "ToPort": "22",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "tcp"
            }],
            "IpPermissionsEgress": [{
              "FromPort": "0",
              "ToPort": "65535",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "-1"
            }],
            "Tags": [{
              "Key": "visops_default",
              "Value": "true"
            }]
          }
        },
        "A67A1584-9771-4438-9A70-F62A767297D4": {
          "name": "web-a",
          "description": "",
          "type": "AWS.VPC.Subnet",
          "uid": "A67A1584-9771-4438-9A70-F62A767297D4",
          "resource": {
            "AvailabilityZone": "@{856A9E6F-F6A5-4651-824A-8A01F9DE290A.resource.ZoneName}",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "",
            "CidrBlock": "10.0.0.0/24"
          }
        },
        "0E12C110-DBE7-4FAD-8B13-DFD7CB566ACE": {
          "name": "web-b",
          "description": "",
          "type": "AWS.VPC.Subnet",
          "uid": "0E12C110-DBE7-4FAD-8B13-DFD7CB566ACE",
          "resource": {
            "AvailabilityZone": "@{88FEA146-74E1-4DE0-BB80-D42927FC4224.resource.ZoneName}",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "",
            "CidrBlock": "10.0.1.0/24"
          }
        },
        "C4C4DBFE-78BE-4280-A115-25CF91287402": {
          "name": "Internet-gateway",
          "type": "AWS.VPC.InternetGateway",
          "uid": "C4C4DBFE-78BE-4280-A115-25CF91287402",
          "resource": {
            "InternetGatewayId": "",
            "AttachmentSet": [{
              "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}"
            }]
          }
        },
        "A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F": {
          "type": "AWS.EC2.Instance",
          "uid": "A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F",
          "name": "master-0",
          "description": "",
          "index": 0,
          "number": 1,
          "serverGroupUid": "A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F",
          "serverGroupName": "master-0",
          "state": [{
            "id": "state-29380423-56B9-4E4E-AE4C-F0B07899CD6C",
            "module": "linux.mesos.master",
            "parameter": {
              "cluster_name": "mesos",
              "framework": framework,
              "masters_addresses": [{
                "key": "master0",
                "value": "@{A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F.PrivateIpAddress}"
              }, {
                "key": "master1",
                "value": "@{AFC0FB44-B553-4ABA-AECE-8286BFCB8769.PrivateIpAddress}"
              }, {
                "key": "master2",
                "value": "@{FE99C60C-6D2D-4054-A5D8-6852AC536D8A.PrivateIpAddress}"
              }],
              "server_id": "mesos",
              "slave_ip": "@{self.PrivateIpAddress}",
              "hostname": "mesos"
            }
          }],
          "resource": {
            "UserData": {
              "Base64Encoded": false,
              "Data": ""
            },
            "BlockDeviceMapping": [{
              "DeviceName": "/dev/sda1",
              "Ebs": {
                "SnapshotId": "snap-00fc3bbc",
                "VolumeSize": 8,
                "VolumeType": "gp2"
              }
            }],
            "Placement": {
              "Tenancy": "",
              "AvailabilityZone": "@{856A9E6F-F6A5-4651-824A-8A01F9DE290A.resource.ZoneName}"
            },
            "InstanceId": "",
            "ImageId": "ami-9ef278f6",
            "KeyName": "@{ACD8B4D3-55B0-47BB-81FB-411773EF4A61.resource.KeyName}",
            "EbsOptimized": false,
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "@{3BC4CB02-59E9-445D-82A4-64B83862DBAE.resource.SubnetId}",
            "Monitoring": "disabled",
            "NetworkInterface": [],
            "InstanceType": "t2.micro",
            "DisableApiTermination": false,
            "ShutdownBehavior": "terminate",
            "SecurityGroup": [],
            "SecurityGroupId": []
          }
        },
        "3CFD5F69-24AA-4E63-AB7D-1E29975E5892": {
          "index": 0,
          "uid": "3CFD5F69-24AA-4E63-AB7D-1E29975E5892",
          "type": "AWS.VPC.NetworkInterface",
          "name": "master-0-eni0",
          "serverGroupUid": "3CFD5F69-24AA-4E63-AB7D-1E29975E5892",
          "serverGroupName": "eni0",
          "number": 1,
          "resource": {
            "SourceDestCheck": true,
            "Description": "",
            "NetworkInterfaceId": "",
            "AvailabilityZone": "@{856A9E6F-F6A5-4651-824A-8A01F9DE290A.resource.ZoneName}",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "@{3BC4CB02-59E9-445D-82A4-64B83862DBAE.resource.SubnetId}",
            "AssociatePublicIpAddress": false,
            "PrivateIpAddressSet": [{
              "PrivateIpAddress": "10.0.2.4",
              "AutoAssign": true,
              "Primary": true
            }],
            "GroupSet": [{
              "GroupName": "@{5CB5F439-BB9B-4C0F-8B57-F2404F6B2FAA.resource.GroupName}",
              "GroupId": "@{5CB5F439-BB9B-4C0F-8B57-F2404F6B2FAA.resource.GroupId}"
            }],
            "Attachment": {
              "InstanceId": "@{A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F.resource.InstanceId}",
              "DeviceIndex": "0",
              "AttachmentId": ""
            }
          }
        },
        "AFC0FB44-B553-4ABA-AECE-8286BFCB8769": {
          "type": "AWS.EC2.Instance",
          "uid": "AFC0FB44-B553-4ABA-AECE-8286BFCB8769",
          "name": "master-1",
          "description": "",
          "index": 0,
          "number": 1,
          "serverGroupUid": "AFC0FB44-B553-4ABA-AECE-8286BFCB8769",
          "serverGroupName": "master-1",
          "state": [{
            "id": "state-BBFD5001-374F-4DF3-8528-C769529C1DBE",
            "module": "linux.mesos.master",
            "parameter": {
              "cluster_name": "mesos",
              "framework": framework,
              "masters_addresses": [{
                "key": "master0",
                "value": "@{A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F.PrivateIpAddress}"
              }, {
                "key": "master1",
                "value": "@{AFC0FB44-B553-4ABA-AECE-8286BFCB8769.PrivateIpAddress}"
              }, {
                "key": "master2",
                "value": "@{FE99C60C-6D2D-4054-A5D8-6852AC536D8A.PrivateIpAddress}"
              }],
              "server_id": "mesos",
              "slave_ip": "@{self.PrivateIpAddress}",
              "hostname": "mesos"
            }
          }],
          "resource": {
            "UserData": {
              "Base64Encoded": false,
              "Data": ""
            },
            "BlockDeviceMapping": [{
              "DeviceName": "/dev/sda1",
              "Ebs": {
                "SnapshotId": "snap-00fc3bbc",
                "VolumeSize": 8,
                "VolumeType": "gp2"
              }
            }],
            "Placement": {
              "Tenancy": "",
              "AvailabilityZone": "@{856A9E6F-F6A5-4651-824A-8A01F9DE290A.resource.ZoneName}"
            },
            "InstanceId": "",
            "ImageId": "ami-9ef278f6",
            "KeyName": "@{ACD8B4D3-55B0-47BB-81FB-411773EF4A61.resource.KeyName}",
            "EbsOptimized": false,
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "@{3BC4CB02-59E9-445D-82A4-64B83862DBAE.resource.SubnetId}",
            "Monitoring": "disabled",
            "NetworkInterface": [],
            "InstanceType": "t2.micro",
            "DisableApiTermination": false,
            "ShutdownBehavior": "terminate",
            "SecurityGroup": [],
            "SecurityGroupId": []
          }
        },
        "61063031-42C3-4285-A464-BD1D048AFECA": {
          "index": 0,
          "uid": "61063031-42C3-4285-A464-BD1D048AFECA",
          "type": "AWS.VPC.NetworkInterface",
          "name": "master-1-eni0",
          "serverGroupUid": "61063031-42C3-4285-A464-BD1D048AFECA",
          "serverGroupName": "eni0",
          "number": 1,
          "resource": {
            "SourceDestCheck": true,
            "Description": "",
            "NetworkInterfaceId": "",
            "AvailabilityZone": "@{856A9E6F-F6A5-4651-824A-8A01F9DE290A.resource.ZoneName}",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "@{3BC4CB02-59E9-445D-82A4-64B83862DBAE.resource.SubnetId}",
            "AssociatePublicIpAddress": false,
            "PrivateIpAddressSet": [{
              "PrivateIpAddress": "10.0.2.5",
              "AutoAssign": true,
              "Primary": true
            }],
            "GroupSet": [{
              "GroupName": "@{5CB5F439-BB9B-4C0F-8B57-F2404F6B2FAA.resource.GroupName}",
              "GroupId": "@{5CB5F439-BB9B-4C0F-8B57-F2404F6B2FAA.resource.GroupId}"
            }],
            "Attachment": {
              "InstanceId": "@{AFC0FB44-B553-4ABA-AECE-8286BFCB8769.resource.InstanceId}",
              "DeviceIndex": "0",
              "AttachmentId": ""
            }
          }
        },
        "FE99C60C-6D2D-4054-A5D8-6852AC536D8A": {
          "type": "AWS.EC2.Instance",
          "uid": "FE99C60C-6D2D-4054-A5D8-6852AC536D8A",
          "name": "master-2",
          "description": "",
          "index": 0,
          "number": 1,
          "serverGroupUid": "FE99C60C-6D2D-4054-A5D8-6852AC536D8A",
          "serverGroupName": "master-2",
          "state": [{
            "id": "state-42E8612D-51C0-4EF0-8FAF-D127F984C3E3",
            "module": "linux.mesos.master",
            "parameter": {
              "cluster_name": "mesos",
              "framework": framework,
              "masters_addresses": [{
                "key": "master0",
                "value": "@{A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F.PrivateIpAddress}"
              }, {
                "key": "master1",
                "value": "@{AFC0FB44-B553-4ABA-AECE-8286BFCB8769.PrivateIpAddress}"
              }, {
                "key": "master2",
                "value": "@{FE99C60C-6D2D-4054-A5D8-6852AC536D8A.PrivateIpAddress}"
              }],
              "server_id": "mesos",
              "slave_ip": "@{self.PrivateIpAddress}",
              "hostname": "mesos"
            }
          }],
          "resource": {
            "UserData": {
              "Base64Encoded": false,
              "Data": ""
            },
            "BlockDeviceMapping": [{
              "DeviceName": "/dev/sda1",
              "Ebs": {
                "SnapshotId": "snap-00fc3bbc",
                "VolumeSize": 8,
                "VolumeType": "gp2"
              }
            }],
            "Placement": {
              "Tenancy": "",
              "AvailabilityZone": "@{88FEA146-74E1-4DE0-BB80-D42927FC4224.resource.ZoneName}"
            },
            "InstanceId": "",
            "ImageId": "ami-9ef278f6",
            "KeyName": "@{ACD8B4D3-55B0-47BB-81FB-411773EF4A61.resource.KeyName}",
            "EbsOptimized": false,
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "@{CB6AF63A-91BE-42DF-B0DA-03AF4270A766.resource.SubnetId}",
            "Monitoring": "disabled",
            "NetworkInterface": [],
            "InstanceType": "t2.micro",
            "DisableApiTermination": false,
            "ShutdownBehavior": "terminate",
            "SecurityGroup": [],
            "SecurityGroupId": []
          }
        },
        "597A0B71-6C4C-47C7-BD74-F9542C301B06": {
          "index": 0,
          "uid": "597A0B71-6C4C-47C7-BD74-F9542C301B06",
          "type": "AWS.VPC.NetworkInterface",
          "name": "master-2-eni0",
          "serverGroupUid": "597A0B71-6C4C-47C7-BD74-F9542C301B06",
          "serverGroupName": "eni0",
          "number": 1,
          "resource": {
            "SourceDestCheck": true,
            "Description": "",
            "NetworkInterfaceId": "",
            "AvailabilityZone": "@{88FEA146-74E1-4DE0-BB80-D42927FC4224.resource.ZoneName}",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "SubnetId": "@{CB6AF63A-91BE-42DF-B0DA-03AF4270A766.resource.SubnetId}",
            "AssociatePublicIpAddress": false,
            "PrivateIpAddressSet": [{
              "PrivateIpAddress": "10.0.3.4",
              "AutoAssign": true,
              "Primary": true
            }],
            "GroupSet": [{
              "GroupName": "@{5CB5F439-BB9B-4C0F-8B57-F2404F6B2FAA.resource.GroupName}",
              "GroupId": "@{5CB5F439-BB9B-4C0F-8B57-F2404F6B2FAA.resource.GroupId}"
            }],
            "Attachment": {
              "InstanceId": "@{FE99C60C-6D2D-4054-A5D8-6852AC536D8A.resource.InstanceId}",
              "DeviceIndex": "0",
              "AttachmentId": ""
            }
          }
        },
        "FE4333AD-6243-4F63-AE2D-D180912D3BBF": {
          "uid": "FE4333AD-6243-4F63-AE2D-D180912D3BBF",
          "name": "slave-asg-0",
          "description": "",
          "type": "AWS.AutoScaling.Group",
          "resource": {
            "AvailabilityZones": ["@{856A9E6F-F6A5-4651-824A-8A01F9DE290A.resource.ZoneName}", "@{88FEA146-74E1-4DE0-BB80-D42927FC4224.resource.ZoneName}"],
            "VPCZoneIdentifier": "@{A67A1584-9771-4438-9A70-F62A767297D4.resource.SubnetId} , @{0E12C110-DBE7-4FAD-8B13-DFD7CB566ACE.resource.SubnetId}",
            "LoadBalancerNames": [],
            "AutoScalingGroupARN": "",
            "DefaultCooldown": "300",
            "MinSize": "1",
            "MaxSize": "2",
            "HealthCheckType": "EC2",
            "HealthCheckGracePeriod": "300",
            "TerminationPolicies": ["Default"],
            "AutoScalingGroupName": "slave-asg-0",
            "DesiredCapacity": "1",
            "LaunchConfigurationName": "@{487929F1-E7FA-4C5C-ABFA-47CC1D7175E2.resource.LaunchConfigurationName}"
          }
        },
        "487929F1-E7FA-4C5C-ABFA-47CC1D7175E2": {
          "type": "AWS.AutoScaling.LaunchConfiguration",
          "uid": "487929F1-E7FA-4C5C-ABFA-47CC1D7175E2",
          "name": "slave-lc-0",
          "description": "",
          "state": [{
            "id": "state-99A1D7AA-B702-438A-AE99-33C6061E2B63",
            "module": "linux.mesos.slave",
            "parameter": {
              "attributes": [{
                "key": "subnet",
                "value": "web-a"
              }],
              "masters_addresses": [{
                "key": "master0",
                "value": "@{A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F.PrivateIpAddress}"
              }],
              "slave_ip": "@{self.PrivateIpAddress}"
            }
          }],
          "resource": {
            "UserData": "",
            "LaunchConfigurationARN": "",
            "InstanceMonitoring": false,
            "ImageId": "ami-9ef278f6",
            "KeyName": "@{ACD8B4D3-55B0-47BB-81FB-411773EF4A61.resource.KeyName}",
            "EbsOptimized": false,
            "BlockDeviceMapping": [{
              "DeviceName": "/dev/sda1",
              "Ebs": {
                "SnapshotId": "snap-00fc3bbc",
                "VolumeSize": 8,
                "VolumeType": "gp2"
              }
            }],
            "SecurityGroups": ["@{5CB5F439-BB9B-4C0F-8B57-F2404F6B2FAA.resource.GroupId}"],
            "LaunchConfigurationName": "slave-lc-0",
            "InstanceType": "t2.micro",
            "AssociatePublicIpAddress": false
          }
        },
        "6DE80488-D704-45F2-9F1A-B0BFF32B34AA": {
          "name": "MesosSG",
          "type": "AWS.EC2.SecurityGroup",
          "uid": "6DE80488-D704-45F2-9F1A-B0BFF32B34AA",
          "resource": {
            "Default": false,
            "GroupId": "",
            "GroupName": "MesosSG",
            "GroupDescription": "Custom Security Group",
            "VpcId": "@{71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A.resource.VpcId}",
            "IpPermissions": [{
              "FromPort": "5050",
              "ToPort": "5050",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "8080",
              "ToPort": "8080",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "tcp"
            }, {
              "FromPort": "0",
              "ToPort": "65535",
              "IpRanges": "@{6DE80488-D704-45F2-9F1A-B0BFF32B34AA.resource.GroupId}",
              "IpProtocol": "-1"
            }],
            "IpPermissionsEgress": [{
              "FromPort": "0",
              "ToPort": "65535",
              "IpRanges": "0.0.0.0/0",
              "IpProtocol": "-1"
            }],
            "Tags": [{
              "Key": "visops_default",
              "Value": "false"
            }]
          }
        }
      }

      layout = {
        "A4C89BFC-34DE-429B-BBFB-E515C91606F5": {
          "coordinate": [
            76, 8],
          "uid": "A4C89BFC-34DE-429B-BBFB-E515C91606F5",
          "groupUId": "71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A"
        },
        "71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A": {
          "coordinate": [
            8, 7],
          "uid": "71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A",
          "size": [
            83, 64]
        },
        "856A9E6F-F6A5-4651-824A-8A01F9DE290A": {
          "coordinate": [
            14, 14],
          "uid": "856A9E6F-F6A5-4651-824A-8A01F9DE290A",
          "groupUId": "71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A",
          "size": [
            55, 25]
        },
        "3BC4CB02-59E9-445D-82A4-64B83862DBAE": {
          "coordinate": [
            17, 17],
          "uid": "3BC4CB02-59E9-445D-82A4-64B83862DBAE",
          "groupUId": "856A9E6F-F6A5-4651-824A-8A01F9DE290A",
          "size": [
            27, 19]
        },
        "88FEA146-74E1-4DE0-BB80-D42927FC4224": {
          "coordinate": [
            14, 43],
          "uid": "88FEA146-74E1-4DE0-BB80-D42927FC4224",
          "groupUId": "71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A",
          "size": [
            55, 24]
        },
        "CB6AF63A-91BE-42DF-B0DA-03AF4270A766": {
          "coordinate": [
            17, 46],
          "uid": "CB6AF63A-91BE-42DF-B0DA-03AF4270A766",
          "groupUId": "88FEA146-74E1-4DE0-BB80-D42927FC4224",
          "size": [
            28, 18]
        },
        "A67A1584-9771-4438-9A70-F62A767297D4": {
          "coordinate": [
            47, 17],
          "uid": "A67A1584-9771-4438-9A70-F62A767297D4",
          "groupUId": "856A9E6F-F6A5-4651-824A-8A01F9DE290A",
          "size": [
            19, 19]
        },
        "0E12C110-DBE7-4FAD-8B13-DFD7CB566ACE": {
          "coordinate": [
            47, 46],
          "uid": "0E12C110-DBE7-4FAD-8B13-DFD7CB566ACE",
          "groupUId": "88FEA146-74E1-4DE0-BB80-D42927FC4224",
          "size": [
            19, 18]
        },
        "C4C4DBFE-78BE-4280-A115-25CF91287402": {
          "coordinate": [
            4, 8],
          "uid": "C4C4DBFE-78BE-4280-A115-25CF91287402",
          "groupUId": "71CFFB0D-EDC1-4EE3-8A65-DEF05097C16A"
        },
        "A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F": {
          "coordinate": [
            20, 22],
          "uid": "A402FA2B-28F5-45F1-BBFE-CD0DD142AE7F",
          "groupUId": "3BC4CB02-59E9-445D-82A4-64B83862DBAE",
          "osType": "ubuntu",
          "architecture": "x86_64",
          "rootDeviceType": "ebs"
        },
        "AFC0FB44-B553-4ABA-AECE-8286BFCB8769": {
          "coordinate": [
            32, 22],
          "uid": "AFC0FB44-B553-4ABA-AECE-8286BFCB8769",
          "groupUId": "3BC4CB02-59E9-445D-82A4-64B83862DBAE",
          "osType": "ubuntu",
          "architecture": "x86_64",
          "rootDeviceType": "ebs"
        },
        "FE99C60C-6D2D-4054-A5D8-6852AC536D8A": {
          "coordinate": [
            20, 51],
          "uid": "FE99C60C-6D2D-4054-A5D8-6852AC536D8A",
          "groupUId": "CB6AF63A-91BE-42DF-B0DA-03AF4270A766",
          "osType": "ubuntu",
          "architecture": "x86_64",
          "rootDeviceType": "ebs"
        },
        "FE4333AD-6243-4F63-AE2D-D180912D3BBF": {
          "coordinate": [
            50, 20],
          "uid": "FE4333AD-6243-4F63-AE2D-D180912D3BBF",
          "groupUId": "A67A1584-9771-4438-9A70-F62A767297D4"
        },
        "487929F1-E7FA-4C5C-ABFA-47CC1D7175E2": {
          "coordinate": [
            0, 0],
          "uid": "487929F1-E7FA-4C5C-ABFA-47CC1D7175E2",
          "osType": "ubuntu",
          "architecture": "x86_64",
          "rootDeviceType": "ebs"
        },
        "21F02789-E06B-41DB-BC98-9C830FCEF64B": {
          "coordinate": [
            50, 49],
          "uid": "21F02789-E06B-41DB-BC98-9C830FCEF64B",
          "groupUId": "0E12C110-DBE7-4FAD-8B13-DFD7CB566ACE",
          "type": "ExpandedAsg",
          "originalId": "FE4333AD-6243-4F63-AE2D-D180912D3BBF"
        },
        "size": [
          240, 240]
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

      json.component = component
      json.layout = layout

      console.log json
      json

  }, {
    supportedProviders : ["aws::global", "aws::china"]
  }

  AwsOpsModel
