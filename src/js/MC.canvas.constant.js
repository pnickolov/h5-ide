define([ 'i18n!nls/lang.js', "MC.canvas" ], function( lang ){

var constant_data = {

	GRID_WIDTH: 10,
	GRID_HEIGHT: 10,

	COMPONENT_SIZE:
	{
		'AWS.ELB': [9, 9],
		'AWS.EC2.Instance': [9, 9],
		'AWS.EC2.EBS.Volume': [10, 10],
		'AWS.VPC.NetworkInterface': [9, 9],
		'AWS.VPC.CustomerGateway': [17, 10],
		'AWS.VPC.RouteTable': [8, 8],
		'AWS.VPC.InternetGateway': [8, 8],
		'AWS.VPC.VPNGateway': [8, 8],
		'AWS.AutoScaling.LaunchConfiguration': [9, 9],
		'AWS.AutoScaling.Group': [13, 13]
	},

	GROUP_DEFAULT_SIZE:
	{
		'AWS.VPC.VPC': [60, 60], //[width, height]
		'AWS.EC2.AvailabilityZone': [21, 21],
		'AWS.VPC.Subnet': [17, 17],
		'AWS.AutoScaling.Group' : [13, 13]
	},

	GROUP_PADDING: 2,

	IMAGE:
	{
		//volume icon of instance
		INSTANCE_VOLUME_ATTACHED_ACTIVE: MC.IMG_URL + 'ide/icon/instance-volume-attached-active.png',
		INSTANCE_VOLUME_ATTACHED_NORMAL: MC.IMG_URL + 'ide/icon/instance-volume-attached-normal.png',
		INSTANCE_VOLUME_NOT_ATTACHED: MC.IMG_URL + 'ide/icon/instance-volume-not-attached.png',
	},

	//min padding for group
	GROUP_MIN_PADDING: 120,

	PORT_PADDING: 4, //port padding (to point of junction)
	CORNER_RADIUS: 8, //cornerRadius of fold line

	GROUP_WEIGHT:
	{
		'AWS.VPC.VPC': ['AWS.EC2.AvailabilityZone', 'AWS.VPC.Subnet', 'AWS.AutoScaling.Group'],
		'AWS.EC2.AvailabilityZone': ['AWS.VPC.Subnet', 'AWS.AutoScaling.Group'],
		'AWS.VPC.Subnet': ['AWS.AutoScaling.Group'],
		'AWS.AutoScaling.Group': []
	},

	// If array, order by ASG -> Subnet -> AZ -> Canvas.
	MATCH_PLACEMENT:
	{
		'AWS.ELB': ['AWS.VPC.VPC'],
		'AWS.EC2.Instance': ['AWS.AutoScaling.Group', 'AWS.VPC.Subnet'],
		'AWS.EC2.EBS.Volume': ['AWS.VPC.Subnet'],
		'AWS.VPC.NetworkInterface': ['AWS.VPC.Subnet'],
		'AWS.VPC.CustomerGateway': ['Canvas'],
		'AWS.VPC.RouteTable': ['AWS.VPC.VPC'],
		'AWS.VPC.InternetGateway': ['AWS.VPC.VPC'],
		'AWS.VPC.VPNGateway': ['AWS.VPC.VPC'],
		'AWS.EC2.AvailabilityZone': ['AWS.VPC.VPC'],
		'AWS.VPC.Subnet': ['AWS.EC2.AvailabilityZone'],
		'AWS.VPC.VPC': ['Canvas'],
		'AWS.AutoScaling.Group' : ['AWS.VPC.Subnet']
	},

	//json data for stack
	STACK_JSON:
	{
		"id": "",
		"name": "",
		"description": "",
		"region": "",
		"platform": "ec2-vpc", //ec2-classic|ec2-vpc, default-vpc|custom-vpc
		"state": "Enabled",
		"username": "",
		"owner": "",
		"version": "2013-09-04",
		"tag": "",
		"usage": "",
		//"has_instance_store_ami": "", //true|false
		"component":
		{},
		"layout":
		{
			"size": [240, 240],
			"component":
			{
				"group":
				{},
				"node":
				{}
			},
			"connection":
			{}
		},
		"history":
		{
			"time":
			{
				"created": 0,
				"updatd": 0
			}
		},
		"property":
		{
			"stoppable": "true",
			"schedule":
			{
				"stop":
				{
					"run": null,
					"when": null,
					"during": null
				},
				"backup":
				{
					"day": null,
					"when": null
				},
				"start":
				{
					"when": null
				}
			},
			"policy":
			{
				"ha": ""
			},
			"lease":
			{
				"length": null,
				"action": "",
				"due": null
			}
		}
	},

	DESIGN_INIT_LAYOUT_VPC:
	{
		size  : [240,240],
		component : {
			group : {
				VPC : {
					coordinate : [5,3],
					size       : [60,60]
				}
			},
			node : {
				RTB : {
					coordinate : [50,5]
				}
			}
		}

	},

	DESIGN_INIT_DATA_VPC:
	{
		KP : {
			type : "AWS.EC2.KeyPair",
			name : "DefaultKP",
			resource : { KeyName : "" }
		},
		SG : {
			type : "AWS.EC2.SecurityGroup",
			name : "DefaultSG",
			resource : {
				IpPermissions: [{
					IpProtocol : "tcp",
					IpRanges   : "0.0.0.0/0",
					FromPort   : "22",
					ToPort     : "22",
					Groups     : [{"GroupId":"","UserId":"","GroupName":""}]
				}],
				IpPermissionsEgress : [{
					FromPort: "0",
					IpProtocol: "-1",
					IpRanges: "0.0.0.0/0",
					ToPort: "65535"
				}],
				Default             : "true",
				GroupName           : "DefaultSG",
				GroupDescription    : 'Default Security Group'
			}
		},
		ACL : {
			"type": "AWS.VPC.NetworkAcl",
			"name": "DefaultACL",
			"resource": {
				"RouteTableId": "",
				"NetworkAclId": "",
				"VpcId": "",
				"Default": "true",
				"EntrySet": [
					{
						"RuleAction": "allow",
						"Protocol": "-1",
						"CidrBlock": "0.0.0.0/0",
						"Egress": true,
						"IcmpTypeCode": {
							"Type": "",
							"Code": ""
						},
						"PortRange": {
							"To": "",
							"From": ""
						},
						"RuleNumber": "100"
					},
					{
						"RuleAction": "deny",
						"Protocol": "-1",
						"CidrBlock": "0.0.0.0/0",
						"Egress": true,
						"IcmpTypeCode": {
							"Type": "",
							"Code": ""
						},
						"PortRange": {
							"To": "",
							"From": ""
						},
						"RuleNumber": "32767"
					},
					{
						"RuleAction": "allow",
						"Protocol": "-1",
						"CidrBlock": "0.0.0.0/0",
						"Egress": false,
						"IcmpTypeCode": {
							"Type": "",
							"Code": ""
						},
						"PortRange": {
							"To": "",
							"From": ""
						},
						"RuleNumber": "100"
					},
					{
						"RuleAction": "deny",
						"Protocol": "-1",
						"CidrBlock": "0.0.0.0/0",
						"Egress": false,
						"IcmpTypeCode": {
							"Type": "",
							"Code": ""
						},
						"PortRange": {
							"To": "",
							"From": ""
						},
						"RuleNumber": "32767"
					}
				],
				"AssociationSet": []
			}
		},
		VPC : {
			type : "AWS.VPC.VPC",
			name : "vpc",
			resource : {}
		},
		RTB : {
			type     : "AWS.VPC.RouteTable",
			resource : {
				PropagatingVgwSet : [],
				RouteSet          : [{
						State                : 'active',
						Origin               : 'CreateRouteTable',
						GatewayId            : 'local',
						DestinationCidrBlock : '10.0.0.0/16'
				}],
				AssociationSet : [{Main:"true"}]
			}
		}
	},

	//***** AWS.EC2.AvailabilityZone *****/
	AZ_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.EC2.AvailabilityZone",
			"coordinate": [0, 0],
			"size": [480, 240],
			"name": "", //eg: us-east-1a
			"groupUId": ""
		}
	},

	//***** AWS.EC2.Instance *****/
	INSTANCE_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.EC2.Instance",
			"coordinate": [0, 0],
			"osType": "", //amazon|centos|debian|fedora|gentoo|linux-other|opensuse|redhat|suse|ubuntu|win
			"architecture": "", //i386|x86_64
			"rootDeviceType": "", //ebs|instance-store
			"virtualizationType" : "", //hvm|paravirtual
			"groupUId": "",
			"connection": [],
			"instanceList": [], //store uid of each instance in server group
			"volumeList" : {},
			"eipList" : null,
			'eniList' : []
		},
		data:
		{
			"uid": "",
			"type": "AWS.EC2.Instance",
			"name": "", 			//if number >1 then it's server group name
			"serverGroupUid": "", 	//uid of servergroup(index is 0)
			"serverGroupName": "",  //name of servergroup
			"number": 1,			//if number >1 then it's server group
			"index": 0, 			//index in server group
			"state": "",
			//"platform": "32",
			"software":
			{},
			"resource":
			{
				"RamdiskId": "",
				"InstanceId": "",
				"DisableApiTermination": "false",
				"ShutdownBehavior": "terminate",
				"SecurityGroupId": [],
				"SecurityGroup": [],
				"UserData":
				{
					"Base64Encoded": "false",
					"Data": ""
				},
				"ImageId": "",
				"Placement":
				{
					"Tenancy": "",
					"AvailabilityZone": "", //eg: ap-northeast-1b
					"GroupName": ""
				},
				"PrivateIpAddress": "",
				"BlockDeviceMapping": [],
				"KernelId": "",
				"SubnetId": "",
				"KeyName": "",
				"VpcId": "",
				"InstanceType": "",
				"Monitoring": "disabled",
				"EbsOptimized": "false",
				"NetworkInterface":[]
			}
		}
	},

	//***** AWS.ELB *****/
	ELB_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.ELB",
			"coordinate": [0, 0],
			"groupUId": "",
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.ELB",
			"name": "",
			"resource":
			{
				"HealthCheck":
				{
					"Timeout": "5",
					"Target": "HTTP:80/index.html",
					"HealthyThreshold": "9",
					"UnhealthyThreshold": "4",
					"Interval": "30"
				},
				"Policies":
				{
					"AppCookieStickinessPolicies": [
					{
						"CookieName": "",
						"PolicyName": ""
					}],
					"OtherPolicies": [],
					"LBCookieStickinessPolicies": [
					{
						"CookieExpirationPeriod": "",
						"PolicyName": ""
					}]
				},
				"BackendServerDescriptions": [
				{
					"InstantPort": "",
					"PoliciyNames": ""
				}],
				"SecurityGroups": [],
				"CreatedTime": "",
				"CanonicalHostedZoneNameID": "",
				"ListenerDescriptions": [
				{
					"PolicyNames": "",
					"Listener":
					{
						"LoadBalancerPort": "80",
						"InstanceProtocol": "HTTP",
						"Protocol": "HTTP",
						"SSLCertificateId": "",
						"InstancePort": "80"
					}
				}],
				"DNSName": "",
				"Scheme": "", //internal | internet-facing
				"CanonicalHostedZoneName": "",
				"Instances": [],
				"SourceSecurityGroup":
				{
					"OwnerAlias": "",
					"GroupName": ""
				},
				"Subnets": [],
				"VpcId": "",
				"LoadBalancerName": "",
				"AvailabilityZones": [],
				"CrossZoneLoadBalancing": "false"
			}
		}
	},


	//***** AWS.VPC.VPC *****/
	VPC_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.VPC.VPC",
			"coordinate": [0, 0],
			"size": [0, 0],
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.VPC",
			"name": "vpc",
			"resource":
			{
				"EnableDnsHostnames": "false",
				"DhcpOptionsId": "",
				"CidrBlock": "10.0.0.0/16",
				"State": "",
				"InstanceTenancy": "default",
				"VpcId": "",
				"IsDefault": "false",
				"EnableDnsSupport": "true"
			}
		}
	},

	//***** AWS.VPC.Subnet *****/
	SUBNET_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.VPC.Subnet",
			"coordinate": [0, 0],
			"size": [0, 0],
			"groupUId": "",
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.Subnet",
			"name": "subnet1",
			"resource":
			{
				"AvailabilityZone": "", //seg: ap-northeast-1b
				"CidrBlock": "10.0.0.0/24",
				"SubnetId": "",
				"VpcId": "", //@3EE0DED4-4D29-12C4-4A98-14C0BBC81A6A.resource.VpcId
				"AvailableIpAddressCount": "",
				"State": ""
			}
		}
	},

	//***** AWS.VPC.InternetGateway *****/
	IGW_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.VPC.InternetGateway",
			"coordinate": [0, 0],
			"groupUId": "",
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.InternetGateway",
			"name": "IGW",
			"resource":
			{
				"InternetGatewayId": "",
				"AttachmentSet": [
				{
					"VpcId": "", //@3EE0DED4-4D29-12C4-4A98-14C0BBC81A6A.resource.VpcId
					"State": "available"
				}]
			}
		}
	},

	//***** AWS.VPC.RouteTable *****/
	ROUTETABLE_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.VPC.RouteTable",
			"coordinate": [0, 0],
			"groupUId": "",
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.RouteTable",
			"name": "",
			"resource":
			{
				"VpcId": "",
				"PropagatingVgwSet": [],
				"RouteSet": [
					{
						'State' : 'active',
						'Origin': 'CreateRouteTable',
						'InstanceId':'',
						'InstanceOwnerId':'',
						'GatewayId' : 'local',
						'NetworkInterfaceId' : '',
						'DestinationCidrBlock' : '10.0.0.0/16'
					}
				],
				"RouteTableId": "",
				"AssociationSet": [
					//{
					//	"Main": "true",
					//	"RouteTableId": "",
					//	"SubnetId": "",
					//	"RouteTableAssociationId": ""
					//}
				]
			}
		}
	},


	//***** AWS.VPC.VPNGateway *****/
	VGW_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.VPC.VPNGateway",
			"coordinate": [0, 0],
			"groupUId": "",
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.VPNGateway",
			"name": "VGW",
			"resource":
			{
				"Attachments": [
				{
					"VpcId": "", //eg: @3EE0DED4-4D29-12C4-4A98-14C0BBC81A6A.resource.VpcId
					"State": "attached"
				}],
				"Type": "ipsec.1",
				"AvailabilityZone": "",
				"VpnGatewayId": "",
				"State": "available"
			}
		}
	},

	//***** AWS.VPC.CustomerGateway *****/
	CGW_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.VPC.CustomerGateway",
			"networkName": "",
			"coordinate": [0, 0],
			"groupUId": "",
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.CustomerGateway",
			"name": "CustomerNetwork1",
			"resource":
			{
				"Type": "ipsec.1",
				"BgpAsn": "",
				"CustomerGatewayId": "",
				"State": "available",
				"IpAddress": ""
			}
		}
	},

	//***** AWS.VPC.NetworkInterface *****/
	ENI_JSON:
	{
		layout:
		{
			'uid' : '',
			"type": "AWS.VPC.NetworkInterface",
			"coordinate": [0, 0],
			"groupUId": "",
			"connection": [],
			"eniList": [],
			"eipList" : {}
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.NetworkInterface",
			"name": "eni1", //if number >1 then it's server group name
			"serverGroupUid": "", 	//uid of servergroup(index is 0)
			"serverGroupName": "",  //name of servergroup
			"number": 1,			//if number >1 then it's server group
			"index": 0, 			//index in server group
			"resource":
			{
				"PrivateIpAddressSet": [
				{
					"Association":
					{
						"AssociationID": "",
						"PublicDnsName": "",
						"AllocationID": "",
						"InstanceId": "",
						"IpOwnerId": "",
						"PublicIp": ""
					},
					"PrivateIpAddress": "10.0.0.1",
					"AutoAssign": "true",
					"Primary": "true"
				}],
				"Status": "",
				"GroupSet": [
				//{
				//	"GroupId": "", //eg: @B70030F1-0107-B526-8022-14C0BBD50CC1.resource.GroupId
				//	"GroupName": "" //eg: @B70030F1-0107-B526-8022-14C0BBD50CC1.resource.GroupName
				//}
				],
				"PrivateDnsName": "",
				"SourceDestCheck": "true",
				"RequestId": "",
				"MacAddress": "",
				"OwnerId": "",
				"RequestManaged": "",
				"SecondPriIpCount": "",
				"Attachment":
				{
					"InstanceId": "", //eg: @D673A590-1897-12F8-D1F3-14C116707F9A.resource.InstanceId
					"AttachmentId": "",
					"DeviceIndex": "1",
					"AttachTime": ""
				},
				"AvailabilityZone": "", //eg: ap-northeast-1b
				"SubnetId": "", //eg: @E2236992-27D1-97CA-4B03-14C0C485E033.resource.SubnetId
				"Description": "",
				"VpcId": "", //eg: @3EE0DED4-4D29-12C4-4A98-14C0BBC81A6A.resource.VpcId
				"PrivateIpAddress": "",
				"NetworkInterfaceId": ""
			}
		}
	},

	/********************************************
	** AutoScaling **
	********************************************/

	//*****AWS.AutoScaling.Group*****/
	ASG_JSON: {
		layout: {
			'uid' : '',
			"type": "AWS.AutoScaling.Group",
			"coordinate": [
				0,
				0
			],
			"size" : [
				13,
				13
			],
			"groupUId": "",
			"originalId": "",
			"connection": [

			]
		},
		data: {
			'type': 'AWS.AutoScaling.Group',
			'name': '',
			'uid': '',
			'resource': {
				'AutoScalingGroupARN': '',
				'AutoScalingGroupName': '',
				'AvailabilityZones': [

				],
				'CreatedTime': '',
				'DefaultCooldown': "300",
				'DesiredCapacity': "",
				'EnabledMetrics': [
					{
						'Granularity': '',
						'Metric': ''
					}
				],
				'HealthCheckGracePeriod': "300",
				'HealthCheckType': "EC2",
				'Instances': [

				],
				'LaunchConfigurationName': '',
				'LoadBalancerNames': [

				],
				'MaxSize': "2",
				'MinSize': "1",
				'PlacementGroup': '',
				'Status': '',
				'SuspendedProcesses': [
					{
						'ProcessName': '',
						'SuspensionReason': ''
					}
				],
				'Tags': '',
				'TerminationPolicies': [
					'Default'
				],
				'VPCZoneIdentifier': '',
				'InstanceId': '',
				'ShouldDecrementDesiredCapacity': ''
			}
		}
	},

	/*****AWS.AutoScaling.LaunchConfiguration*****/
	ASL_LC_JSON: {
		layout:
		{
			'uid' : '',
			'type': 'AWS.AutoScaling.LaunchConfiguration',
			'coordinate': [0, 0],
			'osType': '', //amazon|centos|debian|fedora|gentoo|linux-other|opensuse|redhat|suse|ubuntu|win
			'architecture': '', //i386|x86_64
			'rootDeviceType': '', //ebs|instance-store
			'groupUId': '',
			"originalId": "",
			'connection': []
		},
		data: {
			'name': '',
			'uid': '',
			'type': 'AWS.AutoScaling.LaunchConfiguration',
			'resource': {
				'BlockDeviceMapping': [

				],
				'CreatedTime': '',
				'EbsOptimized': '',
				'IamInstanceProfile': '',
				'ImageId': '',
				'InstanceMonitoring': '',
				'InstanceType': '',
				'KernelId': '',
				'KeyName': '',
				'LaunchConfigurationARN': '',
				'LaunchConfigurationName': '',
				'RamdiskId': '',
				'SecurityGroups': [

				],
				'SpotPrice': '',
				'UserData': ''
			}
		}
	}

};

for ( var i in constant_data ) {
	MC.canvas[i] = constant_data[i];
}
});
