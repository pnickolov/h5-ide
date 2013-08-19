MC.canvas = MC.canvas || {};

(function () {

var constant_data = {

	GRID_WIDTH: 10,
	GRID_HEIGHT: 10,

	COMPONENT_WIDTH: 100,
	COMPONENT_HEIGHT: 100,
	// COMPONENT_WIDTH_GRID: 10,
	// COMPONENT_HEIGHT_GRID: 10,

	COMPONENT_SIZE:
	{
		'AWS.ELB': [10, 10],
		'AWS.EC2.Instance': [10, 10],
		'AWS.EC2.EBS.Volume': [10, 10],
		'AWS.VPC.NetworkInterface': [10, 10],
		'AWS.VPC.CustomerGateway': [17, 10],
		'AWS.VPC.RouteTable': [8, 8],
		'AWS.VPC.InternetGateway': [8, 8],
		'AWS.VPC.VPNGateway': [8, 8],
		'AWS.AutoScaling.LaunchConfiguration': [10, 10]
	},

	GROUP_DEFAULT_SIZE:
	{
		'AWS.VPC.VPC': [60, 60], //[width, height]
		'AWS.EC2.AvailabilityZone': [22, 22],
		'AWS.VPC.Subnet': [18, 18],
		'AWS.AutoScaling.Group' : [14, 14]
	},

	GROUP_PADDING: 2,

	IMAGE:
	{
		//volume icon of instance
		INSTANCE_VOLUME_ATTACHED_ACTIVE: MC.IMG_URL + 'ide/icon/instance-volume-attached-active.png',
		INSTANCE_VOLUME_ATTACHED_NORMAL: MC.IMG_URL + 'ide/icon/instance-volume-attached-normal.png',
		INSTANCE_VOLUME_NOT_ATTACHED: MC.IMG_URL + 'ide/icon/instance-volume-not-attached.png',
		//eip icon of instance/eni
		EIP_ON: MC.IMG_URL + 'ide/icon/eip-on.png',
		EIP_OFF: MC.IMG_URL + 'ide/icon/eip-off.png',
		//elb icon
		ELB_INTERNAL_CANVAS: MC.IMG_URL + 'ide/icon/elb-internal-canvas.png',
		ELB_INTERNET_CANVAS: MC.IMG_URL + 'ide/icon/elb-internet-canvas.png',

		ENI_CANVAS_ATTACHED: MC.IMG_URL + 'ide/icon/eni-canvas-attached.png',
		ENI_CANVAS_UNATTACHED: MC.IMG_URL + 'ide/icon/eni-canvas-unattached.png',

		RT_CANVAS_MAIN: MC.IMG_URL + 'ide/icon/rt-main-canvas.png',
		RT_CANVAS_NOT_MAIN: MC.IMG_URL + 'ide/icon/rt-canvas.png'
	},

	//constant for _route()
	MINDIST: 20,
	TOL: 0.1,
	TOLxTOL: 0.01,
	TOGGLE_DIST: 5,

	//min padding for group
	GROUP_MIN_PADDING: 120,

	//stroke width for group ( .group-az .group-subnet .group-vpc in canvas.css )
	STOKE_WIDTH_AZ: 2,
	STOKE_WIDTH_SUBNET: 2,
	STOKE_WIDTH_VPC: 4,

	//strok width of line
	//LINE_STROKE_WIDTH: 2,

	//constant for MC.canvas.add
	PATH_D_PORT: "M 8 8 l -6 -6 l -2 0 l 0 12 l 2 0 l 6 -6 z", //triangle
	PATH_D_PORT2: "M 10 8 l -6 -6 l -6 6 l 6 6 l 6 -6 z", //diamond

	PATH_ASG_TITLE: "M 0 20 l 0 -15 a 5 5 0 0 1 5 -5 l 130 0 a 5 5 0 0 1 5 5 l 0 15 z",


	PORT_PADDING: 4, //port padding (to point of junction)
	CORNER_RADIUS: 8, //cornerRadius of fold line

	//**for port, direction is position**//
	PORT_RIGHT_ANGLE: 0, // right
	PORT_UP_ANGLE: 90, //top
	PORT_LEFT_ANGLE: 180, //left
	PORT_DOWN_ANGLE: 270, //bottom

	PORT_RIGHT_ROTATE: "", //port rotate
	PORT_UP_ROTATE: ", rotate(90,0,9)",
	PORT_LEFT_ROTATE: ", rotate(180,0,9)",
	PORT_DOWN_ROTATE: ", rotate(270,0,9)",

	COLOR_BLUE: '#6DAEFE',
	COLOR_GREEN: '#12CD4F',
	COLOR_GRAY: '#d8d7d6',
	COLOR_PURPLE: '#bf7aa5',

	LINE_COLOR:
	{
		sg: '#6DAEFE',
		attachment: '#12CD4F',
		association: '#d8d7d6',
		vpn: '#bf7aa5'
	},

	GROUP_LABEL_OFFSET: -6,

	GROUP_LABEL_COORDINATE:
	{
		'AWS.VPC.VPC': [6, 16],
		'AWS.EC2.AvailabilityZone': [4, 14],
		'AWS.VPC.Subnet': [4, 14],
		'AWS.AutoScaling.Group': [4, 14]
	},

	GROUP_WEIGHT:
	{
		'AWS.VPC.VPC': ['AWS.EC2.AvailabilityZone', 'AWS.VPC.Subnet', 'AWS.AutoScaling.Group'],
		'AWS.EC2.AvailabilityZone': ['AWS.VPC.Subnet', 'AWS.AutoScaling.Group'],
		'AWS.VPC.Subnet': ['AWS.AutoScaling.Group'],
		'AWS.AutoScaling.Group': []
	},

	GROUP_PARENT:
	{
		'AWS.VPC.VPC': '',
		'AWS.EC2.AvailabilityZone': 'AWS.VPC.VPC',
		'AWS.VPC.Subnet': 'AWS.EC2.AvailabilityZone',
		'AWS.AutoScaling.Group' : 'AWS.VPC.Subnet'
	},

	PLATFORM_TYPE:
	{
		EC2_CLASSIC: 'ec2-classic', //no vpc
		CUSTOM_VPC: 'custom-vpc', //has vpc
		DEFAULT_VPC: 'default-vpc', //no vpc
		EC2_VPC: 'ec2-vpc' //has vpc
	},

	// If array, order by Subnet -> AZ -> Canvas.
	MATCH_PLACEMENT:
	{
		'ec2-classic':
		{
			'AWS.ELB': ['Canvas'],
			'AWS.EC2.AvailabilityZone': ['Canvas'],
			'AWS.EC2.Instance': ['AWS.EC2.AvailabilityZone','AWS.AutoScaling.Group'],
			'AWS.EC2.EBS.Volume': ['AWS.EC2.AvailabilityZone'],
			'AWS.AutoScaling.Group' : ['AWS.EC2.AvailabilityZone']
		},
		'default-vpc':
		{
			'AWS.ELB': ['Canvas'],
			'AWS.EC2.AvailabilityZone': ['Canvas'],
			'AWS.EC2.Instance': ['AWS.EC2.AvailabilityZone','AWS.AutoScaling.Group'],
			'AWS.EC2.EBS.Volume': ['AWS.EC2.AvailabilityZone'],
			'AWS.VPC.NetworkInterface': ['AWS.EC2.AvailabilityZone'],
			'AWS.AutoScaling.Group' : ['AWS.EC2.AvailabilityZone']
		},
		'custom-vpc':
		{
			'AWS.ELB': ['AWS.VPC.VPC'],
			'AWS.EC2.Instance': ['AWS.VPC.Subnet','AWS.AutoScaling.Group'],
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
		'ec2-vpc':
		{
			'AWS.ELB': ['AWS.VPC.VPC'],
			'AWS.EC2.Instance': ['AWS.VPC.Subnet','AWS.AutoScaling.Group'],
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
		}
	},

	CONNECTION_OPTION:
	{
		"AWS.EC2.Instance": {
			"AWS.AutoScaling.LaunchConfiguration": {
				"type": "sg",
				"from": "instance-sg",
				"to": "launchconfig-sg",
				"direction": {
					"from": "horizontal",
					"to": "horizontal"
				},
				"relation": "multiple"
			},
			"AWS.EC2.Instance": {
				"type": "sg",
				"from": "instance-sg",
				"to": "instance-sg",
				"direction": {
					"from": "horizontal",
					"to": "horizontal"
				},
				"relation": "multiple"
			},
			"AWS.ELB": [
				{
					"type": "elb-sg",
					"from": "instance-sg",
					"to": "elb-sg-out",
					"direction": {
						"from": "horizontal"
					},
					"relation": "multiple"
				},
				{
					"type": "sg",
					"from": "instance-sg",
					"to": "elb-sg-in",
					"direction": {
						"from": "horizontal"
					},
					"relation": "multiple"
				}
			],
			"AWS.VPC.NetworkInterface": [
				{
					"type": "attachment",
					"from": "instance-attach",
					"to": "eni-attach",
					"relation": "multiple"
				},
				{
					"type": "sg",
					"from": "instance-sg",
					"to": "eni-sg",
					"direction": {
						"from": "horizontal",
						"to": "horizontal"
					},
					"relation": "multiple"
				}
			],
			"AWS.VPC.RouteTable": [
				{
					"type": "rtb-target",
					"from": "instance-rtb",
					"to": "rtb-tgt-left",
					"relation": "multiple",
					"dash_line": true
				},
				{
					"type": "sg",
					"from": "instance-rtb",
					"to": "rtb-tgt-right",
					"relation": "unique",
					"dash_line": true
				}
			]
		},
		"AWS.ELB": {
			"AWS.EC2.Instance": [
				{
					"type": "elb-sg",
					"from": "elb-sg-out",
					"to": "instance-sg",
					"direction": {
						"to": "horizontal"
					},
					"relation": "multiple"
				},
				{
					"type": "sg",
					"from": "elb-sg-in",
					"to": "instance-sg",
					"direction": {
						"to": "horizontal"
					},
					"relation": "multiple"
				}
			],
			"AWS.VPC.NetworkInterface": [
				{
					"type": "elb-sg",
					"from": "elb-sg-out",
					"to": "eni-sg",
					"direction": {
						"to": "horizontal"
					},
					"relation": "multiple"
				},
				{
					"type": "sg",
					"from": "elb-sg-in",
					"to": "eni-sg",
					"direction": {
						"to": "horizontal"
					},
					"relation": "multiple"
				}
			],
			"AWS.AutoScaling.LaunchConfiguration": [
				{
					"type": "elb-sg",
					"from": "elb-sg-out",
					"to": "launchconfig-sg",
					"direction": {
						"to": "horizontal"
					},
					"relation": "multiple"
				},
				{
					"type": "sg",
					"from": "elb-sg-in",
					"to": "launchconfig-sg",
					"direction": {
						"to": "horizontal"
					},
					"relation": "multiple"
				}
			],
			"AWS.VPC.Subnet": {
				"type": "association",
				"from": "elb-assoc",
				"to": "subnet-assoc-in",
				"relation": "multiple"
			}
		},
		"AWS.VPC.NetworkInterface": {
			"AWS.ELB": [
				{
					"type": "elb-sg",
					"from": "elb-sg-in",
					"to": "eni-sg",
					"direction": {
						"to": "horizontal"
					},
					"relation": "multiple"
				}
			],
			"AWS.EC2.Instance": [
				{
					"type": "sg",
					"from": "eni-sg",
					"to": "instance-sg",
					"direction": {
						"from": "horizontal",
						"to": "horizontal"
					},
					"relation": "multiple"
				},
				{
					"type": "attachment",
					"from": "eni-attach",
					"to": "instance-attach",
					"relation": "unique"
				}
			],
			"AWS.VPC.NetworkInterface": [
				{
					"type": "sg",
					"from": "eni-sg",
					"to": "eni-sg",
					"direction": {
						"from": "horizontal",
						"to": "horizontal"
					},
					"relation": "multiple"
				}
			],
			"AWS.VPC.RouteTable": [
				{
					"type": "sg",
					"from": "eni-rtb",
					"to": "rtb-tgt-left",
					"relation": "multiple",
					"dash_line": true
				},
				{
					"type": "sg",
					"from": "eni-rtb",
					"to": "rtb-tgt-right",
					"relation": "multiple",
					"dash_line": true
				}
			]
		},
		"AWS.VPC.RouteTable": {
			"AWS.VPC.Subnet": {
				"type": "association",
				"from": "rtb-src",
				"to": "subnet-assoc-out",
				"direction": {
					"from": "vertical"
				},
				"relation": "multiple"
			},
			"AWS.EC2.Instance": [
				{
					"type": "rtb-target",
					"from": "rtb-tgt-left",
					"to": "instance-rtb",
					"relation": "multiple",
					"dash_line": true
				},
				{
					"type": "rtb-target",
					"from": "rtb-tgt-right",
					"to": "instance-rtb",
					"relation": "multiple",
					"dash_line": true
				}
			],
			"AWS.VPC.NetworkInterface": [
				{
					"type": "rtb-target",
					"from": "rtb-tgt-left",
					"to": "eni-rtb",
					"relation": "multiple",
					"dash_line": true
				},
				{
					"type": "rtb-target",
					"from": "rtb-tgt-right",
					"to": "eni-rtb",
					"relation": "multiple",
					"dash_line": true
				}
			],
			"AWS.VPC.InternetGateway": {
				"type": "rtb-target",
				"from": "rtb-tgt-left",
				"to": "igw-tgt",
				"relation": "multiple",
				"dash_line": true
			},
			"AWS.VPC.VPNGateway": {
				"type": "rtb-target",
				"from": "rtb-tgt-right",
				"to": "vgw-tgt",
				"relation": "multiple",
				"dash_line": true
			}
		},
		"AWS.VPC.InternetGateway": {
			"AWS.VPC.RouteTable": {
				"type": "rtb-target",
				"from": "igw-tgt",
				"to": "rtb-tgt-left",
				"dash_line": true
			}
		},
		"AWS.VPC.VPNGateway": {
			"AWS.VPC.RouteTable": {
				"type": "rtb-target",
				"from": "vgw-tgt",
				"to": "rtb-tgt-right",
				"dash_line": true
			},
			"AWS.VPC.CustomerGateway": {
				"type": "vpn",
				"from": "vgw-vpn",
				"to": "cgw-vpn"
			}
		},
		"AWS.VPC.CustomerGateway": {
			"AWS.VPC.VPNGateway": {
				"type": "vpn",
				"from": "cgw-vpn",
				"to": "vgw-vpn",
				"relation": "unique"
			}
		},
		"AWS.VPC.Subnet": {
			"AWS.VPC.RouteTable": {
				"type": "association",
				"from": "subnet-assoc-out",
				"to": "rtb-src",
				"direction": {
					"to": "vertical"
				},
				"relation": "multiple"
			},
			"AWS.ELB": {
				"type": "association",
				"from": "subnet-assoc-in",
				"to": "elb-assoc",
				"relation": "unique"
			}
		},
		"AWS.AutoScaling.LaunchConfiguration": {
			"AWS.AutoScaling.LaunchConfiguration": {
				"type": "sg",
				"from": "launchconfig-sg",
				"to": "launchconfig-sg",
				"direction": {
					"from": "horizontal",
					"to": "horizontal"
				},
				"relation": "multiple"
			},
			"AWS.EC2.Instance": {
				"type": "sg",
				"from": "launchconfig-sg",
				"to": "instance-sg",
				"direction": {
					"from": "horizontal",
					"to": "horizontal"
				},
				"relation": "multiple"
			},
			"AWS.VPC.NetworkInterface": {
				"type": "sg",
				"from": "launchconfig-sg",
				"to": "eni-sg",
				"direction": {
					"from": "horizontal",
					"to": "horizontal"
				},
				"relation": "multiple"
			},
			"AWS.ELB": [
				{
					"type": "elb-sg",
					"from": "launchconfig-sg",
					"to": "elb-sg-out",
					"direction": {
						"from": "horizontal"
					},
					"relation": "multiple"
				},
				{
					"type": "sg",
					"from": "launchconfig-sg",
					"to": "elb-sg-in",
					"direction": {
						"from": "horizontal"
					},
					"relation": "multiple"
				}
			]
		}
	},

	//local variable for stack
	STACK_PROPERTY:
	{
		sg_list: [],
		kp_list: [],
		original_json: '',
		SCALE_RATIO: 1,
		selected_node: []
		//resource_list: [] //aws resource list by Describe* return
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
		"version": "5.0",
		"tag": "",
		"usage": "",
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

	//***** AWS.EC2.AvailabilityZone *****/
	AZ_JSON:
	{
		layout:
		{
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
			"type": "AWS.EC2.Instance",
			"coordinate": [0, 0],
			"osType": "", //amazon|centos|debian|fedora|gentoo|linux-other|opensuse|redhat|suse|ubuntu|win
			"architecture": "", //i386|x86_64
			"rootDeviceType": "", //ebs|instance-store
			"groupUId": "",
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.EC2.Instance",
			"name": "",
			"state": "",
			"platform": "32",
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
				"EbsOptimized": "false"
			}
		}
	},

	//***** AWS.EC2.KeyPair *****/
	KP_JSON:
	{
		data:
		{
			"uid": "",
			"type": "AWS.EC2.KeyPair",
			"name": "DefaultKP",
			"resource":
			{
				"KeyFingerprint": "",
				"KeyName": "DefaultKP" //eg: @5BC26143-0BBD-D00B-1540-14C0AF95294A.name
			}
		}
	},

	//***** AWS.EC2.SecurityGroup *****/
	SG_JSON:
	{
		data:
		{
			"uid": "",
			"type": "AWS.EC2.SecurityGroup",
			"name": "DefaultSG",
			"resource":
			{
				"IpPermissions": [
				{
					"IpProtocol": "tcp",
					"IpRanges": "0.0.0.0/0",
					"FromPort": "22",
					"ToPort": "22",
					"Groups": [
					{
						"GroupId": "",
						"UserId": "",
						"GroupName": ""
					}]
				}],
				"IpPermissionsEgress": [

				],
				"GroupId": "",
				"Default": "true",
				"VpcId": "", //eg: @3EE0DED4-4D29-12C4-4A98-14C0BBC81A6A.resource.VpcId
				"GroupName": "DefaultSG",
				"OwnerId": "",
				"GroupDescription": "vpc default security group"
			}

		}
	},

	//***** AWS.EC2.EIP *****/
	EIP_JSON:
	{
		data:
		{
			"uid": "",
			"type": "AWS.EC2.EIP",
			"name": "",
			"resource":
			{
				"InstanceId": "", //eg: @D29B0169-476F-52AF-30AB-75B7DF43877E.resource.InstanceId
				"PrivateIpAddress": "",
				"NetworkInterfaceId": "",
				"NetworkInterfaceOwnerId": "",
				"AllowReassociation": "",
				"Domain": "standard",
				"AssociationId": "",
				"PublicIp": "",
				"AllocationId": ""
			}
		}
	},

	//***** AWS.EC2.EBS.Volume *****/
	VOLUME_JSON:
	{
		layout:
		{
			"type": "AWS.EC2.EBS.Volume",
			"coordinate": [0, 0],
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.EC2.EBS.Volume",
			"name": "/dev/sdf",
			"resource":
			{
				"VolumeId": "",
				"CreateTime": "",
				"AvailabilityZone": "", //eg: ap-northeast-1b
				"Size": "1", //unit GB
				"Status": "",
				"SnapshotId": "",
				"Iops": "",
				"AttachmentSet":
				{
					"VolumeId": "", //eg: @785ABCF2-5226-82AC-A564-14C4618E8737.resource.VolumeId
					"Status": "",
					"AttachTime": "",
					"InstanceId": "", //eg: @D673A590-1897-12F8-D1F3-14C116707F9A.resource.InstanceId
					"DeleteOnTermination": "true",
					"Device": "/dev/sdf"
				},
				"VolumeType": "standard"
			}
		}
	},

	//***** AWS.ELB *****/
	ELB_JSON:
	{
		layout:
		{
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
				"AvailabilityZones": []
			}
		}
	},


	//***** AWS.VPC.VPC *****/
	VPC_JSON:
	{
		layout:
		{
			"type": "AWS.VPC.VPC",
			"coordinate": [0, 0],
			"size": [0, 0],
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.VPC",
			"name": "vpc1",
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
				"RouteSet": [],
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
			"type": "AWS.VPC.NetworkInterface",
			"coordinate": [0, 0],
			"groupUId": "",
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.NetworkInterface",
			"name": "eni1",
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

	//***** AWS.VPC.DhcpOptions *****/
	DHCP_JSON:
	{
		layout:
		{
			"type": "AWS.VPC.DhcpOptions",
			"coordinate": [0, 0],
			"groupUId": "",
			"connection": []
		},
		data:
		{
			"uid": "",
			"type": "AWS.VPC.DhcpOptions",
			"name": "default",
			"resource":
			{
				"VpcId": "", //eg: @3EE0DED4-4D29-12C4-4A98-14C0BBC81A6A.resource.VpcId
				"DhcpOptionsId": "",
				"DhcpConfigurationSet": [
				{
					"Key": "domain-name",
					"ValueSet": [
					{
						"Value": "test"
					}]
				},
				{
					"Key": "domain-name-servers",
					"ValueSet": [
					{
						"Value": "" //eg: 192.168.2.2
					}]
				},
				{
					"Key": "netbios-node-type",
					"ValueSet": [
					{
						"Value": "1"
					}]
				}]
			}
		}
	},

	//***** AWS.VPC.VPNConnection *****/
	VPN_JSON:
	{
		data:
		{
			"uid": "",
			"type": "AWS.VPC.VPNConnection",
			"name": "VPN",
			"resource":
			{
				"CustomerGatewayConfiguration": "",
				"Routes": [
					// {
					//	"DestinationCidrBlock": "",
					//	"State": "",
					//	"Source": ""
					// }
				],
				"State": "",
				"VgwTelemetry":
				{
					"StatusMessage": "",
					"LastStatusChange": "",
					"OutsideIpAddress": "",
					"Status": "",
					"AcceptRouteCount": ""
				},
				"Type": "ipsec.1",
				"VpnGatewayId": "", //eg:@93F63A85-E522-123A-444F-14CFDD991C77.resource.VpnGatewayId
				"Options":
				{
					"StaticRoutesOnly": "true"
				},
				"CustomerGatewayId": "", //eg: @395BC5F6-3489-E660-C5DF-14CFE4690335.resource.CustomerGatewayId
				"VpnConnectionId": ""
			}
		}
	},

	//***** AWS.VPC.NetworkAcl *****/
	ACL_JSON:
	{
		data:
		{
			"uid": "",
			"type": "AWS.VPC.NetworkAcl",
			"name": "DefaultACL",
			"resource":
			{
				"RouteTableId": "",
				"NetworkAclId": "",
				"VpcId": "", //eg: @3EE0DED4-4D29-12C4-4A98-14C0BBC81A6A.resource.VpcId
				"Default": "false",
				"EntrySet": [
				{
					"RuleAction": "allow",
					"Protocol": "-1",
					"CidrBlock": "0.0.0.0/0",
					"Egress": "true",
					"IcmpTypeCode":
					{
						"Type": "",
						"Code": ""
					},
					"PortRange":
					{
						"To": "",
						"From": ""
					},
					"RuleNumber": "100"
				},
				{
					"RuleAction": "deny",
					"Protocol": "-1",
					"CidrBlock": "0.0.0.0/0",
					"Egress": "true",
					"IcmpTypeCode":
					{
						"Type": "",
						"Code": ""
					},
					"PortRange":
					{
						"To": "",
						"From": ""
					},
					"RuleNumber": "32767"
				},
				{
					"RuleAction": "allow",
					"Protocol": "-1",
					"CidrBlock": "0.0.0.0/0",
					"Egress": "false",
					"IcmpTypeCode":
					{
						"Type": "",
						"Code": ""
					},
					"PortRange":
					{
						"To": "",
						"From": ""
					},
					"RuleNumber": "100"
				},
				{
					"RuleAction": "deny",
					"Protocol": "-1",
					"CidrBlock": "0.0.0.0/0",
					"Egress": "false",
					"IcmpTypeCode":
					{
						"Type": "",
						"Code": ""
					},
					"PortRange":
					{
						"To": "",
						"From": ""
					},
					"RuleNumber": "32767"
				}],
				"AssociationSet": []
			}
		}
	},

	//***** AWS.IAM.ServerCertificate *****/
	SRVCERT_JSON:
	{
		data:
		{
			"uid": "",
			"type": "AWS.IAM.ServerCertificate",
			"name": "iam-name",
			"resource":
			{
				"PrivateKey": "private-key",
				"ServerCertificateMetadata":
				{
					"UploadDate": "",
					"ServerCertificateName": "iam-name",
					"ServerCertificateId": "",
					"Arn": "",
					"Path": ""
				},
				"CertificateBody": "public-key",
				"CertificateChain": ""
			}
		}
	},


	/********************************************
	** AutoScaling **
	********************************************/

	//*****AWS.AutoScaling.Group*****/
	ASG_JSON: {
		layout: {
			"type": "AWS.AutoScaling.Group",
			"coordinate": [
				0,
				0
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
				'DefaultCooldown': '',
				'DesiredCapacity': '',
				'EnabledMetrics': [
					{
						'Granularity': '',
						'Metric': ''
					}
				],
				'HealthCheckGracePeriod': '',
				'HealthCheckType': '',
				'Instances': [

				],
				'LaunchConfigurationName': '',
				'LoadBalancerNames': [

				],
				'MaxSize': '',
				'MinSize': '',
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
	},

	/*****volumeinAutoScalingGroup*****/
	ASL_VOL_JSON: {
		"DeviceName": "",
		"Ebs": {
			// "SnapshotId": "",
			"VolumeSize": 0
		}
	},

	/*****AWS.AutoScaling.NotificationConfiguration*****/
	ASL_NC_JSON: {
		data: {
			'type': 'AWS.AutoScaling.NotificationConfiguration',
			'name': '',
			'uid': '',
			'resource': {
				'AutoScalingGroupName': '',
				'NotificationType': [

				],
				'TopicARN': ''
			}
		}
	},
	/*****AWS.AutoScaling.ScalingPolicy*****/
	ASL_SP_JSON: {
		data: {
			'type': 'AWS.AutoScaling.ScalingPolicy',
			'name': '',
			'uid': '',
			'resource': {
				'AdjustmentType': "",
				'Alarms': [
					{
						'AlarmARN': '',
						'AlarmName': ''
					}
				],
				'AutoScalingGroupName': '',
				'Cooldown': '',
				'MinAdjustmentStep': '',
				'PolicyARN': '',
				'PolicyName': '',
				'ScalingAdjustment': ''
			}
		}
	},

	/*****AWS.AutoScaling.ScheduledActions*****/
	ASL_SA_JSON: {
		data: {
			'type': 'AWS.AutoScaling.ScheduledActions',
			'name': '',
			'uid': '',
			'resource': {
				'AutoScalingGroupName': '',
				'DesiredCapacity': '',
				'EndTime': '',
				'MaxSize': '',
				'MinSize': '',
				'Recurrence': '',
				'ScheduledActionName': '',
				'StartTime': ''
			}
		}
	},

	/*****AWS.CloudWatch.CloudWatch*****/
	CLW_JSON: {
		data: {
			'type': 'AWS.CloudWatch.CloudWatch',
			'name': '',
			'uid': '',
			'resource': {
				'ActionEnabled': '',
				'AlarmActions': [

				],
				'AlarmArn': '',
				'AlarmConfigurationUpdatedTimestamp': '',
				'AlarmDescription': '',
				'AlarmName': '',
				'ComparisonOperator': '',
				'Dimensions': [
					{
						'name': '',
						'value': ''
					}
				],
				'EvaluationPeriods': '',
				'InsufficientDataActions': [

				],
				'MetricName': '',
				'Namespace': '',
				'OKAction': [

				],
				'Period': '',
				'StateReason': '',
				'StateReasonData': '',
				'StateUpdateTimestamp': '',
				'StateValue': '',
				'Statistic': 'Average',
				'Threshold': '',
				'Unit': ''
			}
		}
	},

	/*****AWS.SNS.Subscription*****/
	SNS_SUB_JSON: {
		data: {
			'type': 'AWS.SNS.Subscription',
			'name': '',
			'uid': '',
			'resource': {
				'Endpoint': '',
				'TopicArn': '',
				'Protocol': '',
				'DeliveryPolicy': '',
				'SubscriptionArn': ''
			}
		}
	},

	/*****AWS.SNS.Topic*****/
	SNS_TOPIC_JSON: {
		data: {
			'type': 'AWS.SNS.Topic',
			'name': '',
			'uid': '',
			'resource': {
				'Name': '',
				'TopicArn': '',
				'Policy': '',
				'DisplayName': '',
				'DeliveryPolicy': ''
			}
		}
	}


};

$.each(constant_data, function (key, value)
{
	MC.canvas[ key ] = value;
});

})();
