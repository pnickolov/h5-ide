

define ['MC', 'i18n!nls/lang.js'], ( MC, lang ) ->

	AWS_RESOURCE_KEY = {
		"AWS.EC2.AvailabilityZone"            : "ZoneName"
		"AWS.EC2.Instance"                : "InstanceId"
		"AWS.EC2.KeyPair"               : "KeyFingerprint"
		"AWS.EC2.SecurityGroup"             : "GroupId"
		"AWS.EC2.EIP"                 : "PublicIp"
		"AWS.EC2.AMI"                 : "ImageId"
		"AWS.EC2.EBS.Volume"              : "VolumeId"
		"AWS.ELB"                   : "LoadBalancerName"
		"AWS.VPC.VPC"                 : "VpcId"
		"AWS.VPC.Subnet"                : "SubnetId"
		"AWS.VPC.InternetGateway"           : "InternetGatewayId"
		"AWS.VPC.RouteTable"              : "RouteTableId"
		"AWS.VPC.VPNGateway"              : "VpnGatewayId"
		"AWS.VPC.CustomerGateway"           : "CustomerGatewayId"
		"AWS.VPC.NetworkInterface"            : "NetworkInterfaceId"
		"AWS.VPC.DhcpOptions"             : "DhcpOptionsId"
		"AWS.VPC.VPNConnection"             : "VpnConnectionId"
		"AWS.VPC.NetworkAcl"              : "NetworkAclId"
		"AWS.IAM.ServerCertificate"           : ""
		"AWS.AutoScaling.Group"             : "AutoScalingGroupARN"
		"AWS.AutoScaling.LaunchConfiguration"     : "LaunchConfigurationARN"
		"AWS.AutoScaling.NotificationConfiguration"   : ""
		"AWS.AutoScaling.ScalingPolicy"         : "PolicyARN"
		"AWS.AutoScaling.ScheduledActions"        : "ScheduledActionARN"
		"AWS.CloudWatch.CloudWatch"           : "AlarmArn"
		"AWS.SNS.Subscription"              : ""
		"AWS.SNS.Topic"                 : ""
	}

	# A short version
	RESTYPE =
		AZ            						: "AWS.EC2.AvailabilityZone"
		INSTANCE                    		: "AWS.EC2.Instance"
		KP                     				: "AWS.EC2.KeyPair"
		SG               					: "AWS.EC2.SecurityGroup"
		EIP                         		: "AWS.EC2.EIP"
		AMI                         		: "AWS.EC2.AMI"
		VOL                      			: "AWS.EC2.EBS.Volume"
		SNAP                    			: "AWS.EC2.EBS.Snapshot"
		ELB                             	: "AWS.ELB"
		VPC                         		: "AWS.VPC.VPC"
		SUBNET                      		: "AWS.VPC.Subnet"
		IGW             					: "AWS.VPC.InternetGateway"
		RT                  				: "AWS.VPC.RouteTable"
		VGW                  				: "AWS.VPC.VPNGateway"
		CGW             					: "AWS.VPC.CustomerGateway"
		ENI            						: "AWS.VPC.NetworkInterface"
		DHCP                 				: "AWS.VPC.DhcpOptions"
		VPN               					: "AWS.VPC.VPNConnection"
		ACL                  				: "AWS.VPC.NetworkAcl"
		IAM           						: "AWS.IAM.ServerCertificate"
		ASG                       			: 'AWS.AutoScaling.Group'
		LC         							: 'AWS.AutoScaling.LaunchConfiguration'
		NC   								: 'AWS.AutoScaling.NotificationConfiguration'
		SP               					: 'AWS.AutoScaling.ScalingPolicy'
		SA            						: 'AWS.AutoScaling.ScheduledActions'
		CW                   				: 'AWS.CloudWatch.CloudWatch'
		SUBSCRIPTION                        : 'AWS.SNS.Subscription'
		TOPIC                               : 'AWS.SNS.Topic'


	#private
	AWS_RESOURCE_SHORT_TYPE = {
		AWS_EC2_AvailabilityZone  : "az"
		AWS_EC2_Instance          : "instance"
		AWS_EC2_KeyPair           : "kp"
		AWS_EC2_SecurityGroup     : "sg"
		AWS_EC2_EIP               : "eip"
		AWS_EC2_AMI               : "ami"
		AWS_EBS_Volume            : "vol"
		AWS_EBS_Snapshot          : "snap"
		AWS_ELB                   : "elb"
		AWS_VPC_VPC               : "vpc"
		AWS_VPC_Subnet            : "subnet"
		AWS_VPC_InternetGateway   : "igw"
		AWS_VPC_RouteTable        : "rtb"
		AWS_VPC_VPNGateway        : "vgw"
		AWS_VPC_CustomerGateway   : "cgw"
		AWS_VPC_NetworkInterface  : "eni"
		AWS_VPC_DhcpOptions       : "dhcp"
		AWS_VPC_VPNConnection     : "vpn"
		AWS_VPC_NetworkAcl        : "acl"
		AWS_IAM_ServerCertificate : "iam"
		#
		AWS_AutoScaling_Group                     : 'asg'
		AWS_AutoScaling_LaunchConfiguration       : 'asl_lc'
		AWS_AutoScaling_NotificationConfiguration : 'asl_nc'
		AWS_AutoScaling_ScalingPolicy             : 'asl_sp'
		AWS_AutoScaling_ScheduledActions          : 'asl_sa'
		AWS_CloudWatch_CloudWatch                 : 'clw'
		AWS_SNS_Subscription                      : 'sns_sub'
		AWS_SNS_Topic                             : 'sns_top'
	}

	INSTANCE_TYPE = {
		't1.micro' : ["T1 Micro", "ECU Up to 2", "Core 1", "Memory 613MB"]
		'm1.small' : ["M1 Small", "ECU 1","Core 1", "Memory 1.7GB"]
		'm1.medium': ["M1 Medium", "ECU 2", "Core 1", "Memory 3.7GB"]
		'm1.large' : ["M1 Large", "ECU 4","Core 2", "Memory 7.5GB"]
		'm1.xlarge': ["M1 Extra Large", "ECU 8", "Core 4", "Memory 15GB"]
		'm3.xlarge': ["M3 Extra Large", "ECU 13","Core 4","Memory 15GB"]
		'm3.2xlarge' : ["M3 Double Extra Large", "ECU 26","Core 8","Memory 30GB"]
		'm2.xlarge' : ["M2 High-Memory Extra Large", "ECU 6.5","Core 2","Memory 17.1GB"]
		'm2.2xlarge' : ["M2 High-Memory Double Extra Large", "ECU 13","Core 4","Memory 34.2GB"]
		'm2.4xlarge' : ["M2 High-Memory Quadruple Extra Large", "ECU 26","Core 8","Memory 68.4GB"]
		'c1.medium' : ["C1 High-CPU Medium", "ECU 5","Core 2","Memory 1.7GB"]
		'c1.xlarge' : ["C1 High-CPU Extra Large", "ECU 20","Core 8","Memory 7GB"]
		'hi1.4xlarge' : ["High I/O Quadruple Extra Large", "ECU 35","Core 16","Memory 60.5GB"]
		'hs1.8xlarge' : ["High Storage Eight Extra Large", "ECU 35","Core 16","Memory 117GB"]
	}

	INSTANCE_STATES = {
		'pending'      : 0
		'running'      : 16
		'shuttingdown' : 32
		'terminated'   : 48
		'stopping'     : 64
		'stopped'      : 80
	}


	#private
	MESSAGE_E = {
		MESSAGE_E_SESSION  : "This session has expired, please log in again"
		MESSAGE_E_EXTERNAL : "Sorry, there seems to be a problem with AWS"
		MESSAGE_E_ERROR    : "Sorry, we're experiencing techincal difficulty"
		MESSAGE_E_UNKNOWN  : "Something is wrong. Please contact support@visualops.io"
		MESSAGE_E_PARAM    : "Parameter error!"
	}


	#private
	REGION_KEYS = [ 'us-east-1', 'us-west-1', 'us-west-2', 'eu-west-1', 'ap-southeast-1', 'ap-southeast-2', 'ap-northeast-1', 'sa-east-1' ]

	#private
	REGION_LABEL =
		'us-east-1'      : lang.ide[ 'IDE_LBL_REGION_NAME_us-east-1']
		'us-west-1'      : lang.ide[ 'IDE_LBL_REGION_NAME_us-west-1']
		'us-west-2'      : lang.ide[ 'IDE_LBL_REGION_NAME_us-west-2']
		'eu-west-1'      : lang.ide[ 'IDE_LBL_REGION_NAME_eu-west-1']
		'ap-southeast-2' : lang.ide[ 'IDE_LBL_REGION_NAME_ap-southeast-2']
		'ap-northeast-1' : lang.ide[ 'IDE_LBL_REGION_NAME_ap-northeast-1']
		'ap-southeast-1' : lang.ide[ 'IDE_LBL_REGION_NAME_ap-southeast-1']
		'sa-east-1'      : lang.ide[ 'IDE_LBL_REGION_NAME_sa-east-1']

	REGION_SHORT_LABEL =
		'us-east-1'      : lang.ide[ 'IDE_LBL_REGION_NAME_SHORT_us-east-1']
		'us-west-1'      : lang.ide[ 'IDE_LBL_REGION_NAME_SHORT_us-west-1']
		'us-west-2'      : lang.ide[ 'IDE_LBL_REGION_NAME_SHORT_us-west-2']
		'eu-west-1'      : lang.ide[ 'IDE_LBL_REGION_NAME_SHORT_eu-west-1']
		'ap-southeast-1' : lang.ide[ 'IDE_LBL_REGION_NAME_SHORT_ap-southeast-1']
		'ap-southeast-2' : lang.ide[ 'IDE_LBL_REGION_NAME_SHORT_ap-southeast-2']
		'ap-northeast-1' : lang.ide[ 'IDE_LBL_REGION_NAME_SHORT_ap-northeast-1']
		'sa-east-1'      : lang.ide[ 'IDE_LBL_REGION_NAME_SHORT_sa-east-1']

	#private
	RETURN_CODE = {
		E_OK           : 0
		E_NONE         : 1
		E_INVALID      : 2
		E_FULL         : 3
		E_EXIST        : 4
		E_EXTERNAL     : 5
		E_FAILED       : 6
		E_BUSY         : 7
		E_NORSC        : 8
		E_NOPERM       : 9
		E_NOSTOP       : 10
		E_NOSTART      : 11
		E_ERROR        : 12
		E_LEFTOVER     : 13
		E_TIMEOUT      : 14
		E_UNKNOWN      : 15
		E_CONN         : 16
		E_EXPIRED      : 17
		E_PARAM        : 18
		E_SESSION      : 19
		E_END          : 20
		E_BLOCKED_USER : 21
	}

	#private
	# SERVICE_ERROR_MESSAGE = {}
	# SERVICE_ERROR_MESSAGE[ 1 ]  = 'Service Message' + 1
	# SERVICE_ERROR_MESSAGE[ 2 ]  = 'Service Message' + 2
	# SERVICE_ERROR_MESSAGE[ 3 ]  = 'Service Message' + 3
	# SERVICE_ERROR_MESSAGE[ 4 ]  = 'Service Message' + 4
	# SERVICE_ERROR_MESSAGE[ 5 ]  = 'Service Message' + 5
	# SERVICE_ERROR_MESSAGE[ 6 ]  = 'Service Message' + 6
	# SERVICE_ERROR_MESSAGE[ 7 ]  = 'Service Message' + 7
	# SERVICE_ERROR_MESSAGE[ 8 ]  = 'Service Message' + 8
	# SERVICE_ERROR_MESSAGE[ 9 ]  = 'Service Message' + 9
	# SERVICE_ERROR_MESSAGE[ 10 ]  = 'Service Message' + 10
	# SERVICE_ERROR_MESSAGE[ 11 ]  = 'Service Message' + 11
	# SERVICE_ERROR_MESSAGE[ 12 ]  = 'Service Message' + 12
	# SERVICE_ERROR_MESSAGE[ 13 ]  = 'Service Message' + 13
	# SERVICE_ERROR_MESSAGE[ 14 ]  = 'Service Message' + 14
	# SERVICE_ERROR_MESSAGE[ 15 ]  = 'Service Message' + 15
	# SERVICE_ERROR_MESSAGE[ 16 ]  = 'Service Message' + 16
	# SERVICE_ERROR_MESSAGE[ 17 ]  = 'Service Message' + 17
	# SERVICE_ERROR_MESSAGE[ 18 ]  = 'Service Message' + 18
	# SERVICE_ERROR_MESSAGE[ 19 ]  = 'Service Message' + 19
	# SERVICE_ERROR_MESSAGE[ 20 ]  = 'Service Message' + 20
	# SERVICE_ERROR_MESSAGE[ 21 ]  = 'Service Message' + 21

	#private
	APP_STATE = {
		APP_STATE_RUNNING   : "Running"
		APP_STATE_STOPPED   : "Stopped"
		APP_STATE_REBOOTING   : "Rebooting"
		APP_STATE_CLONING   : "Cloning"
		APP_STATE_SAVETOSTACK : "Saving"
		APP_STATE_TERMINATING : "Terminating"
		APP_STATE_UPDATING    : "Updating"
		APP_STATE_SHUTTING_DOWN : "Shutting down"
		APP_STATE_STOPPING    : "Stopping"
		APP_STATE_STARTING    : "Starting"
		APP_STATE_TERMINATED  : "Terminated"
		APP_STATE_INITIALIZING  : "Initializing"
	}

	#private
	OPS_STATE = {
		OPS_STATE_PENDING   : "Pending"
		OPS_STATE_INPROCESS   : "InProcess"
		OPS_STATE_DONE      : "Done"
		OPS_STATE_ROLLBACK    : "Rollback"
		OPS_STATE_FAILED    : "Failed"
	}

	OPS_CODE_NAME =
		"Forge.Stack.Run"     : "launch"
		"Forge.App.Stop"      : "stop"
		"Forge.App.Start"     : "start"
		"Forge.App.Update"    : "update"
		"Forge.App.Terminate" : "terminate"

	AWS_RESOURCE = {
		AZ                  :   'AWS.EC2.AvailabilityZone'
		AMI                 :   'AWS.EC2.AMI'
		VOLUME              :   'AWS.EC2.EBS.Volume'
		SNAPSHOT            :   'AWS.EC2.EBS.Snapshot'
		EIP                 :   'AWS.EC2.EIP'
		INSTANCE            :   'AWS.EC2.Instance'
		KP                  :   'AWS.EC2.KeyPair'
		SG                  :   'AWS.EC2.SecurityGroup'

		ELB                 :   'AWS.ELB'

		ACL                 :   'AWS.VPC.NetworkAcl'
		CGW                 :   'AWS.VPC.CustomerGateway'
		DHCP                :   'AWS.VPC.DhcpOptions'
		ENI                 :   'AWS.VPC.NetworkInterface'
		IGW                 :   'AWS.VPC.InternetGateway'
		RT                  :   'AWS.VPC.RouteTable'
		SUBNET              :   'AWS.VPC.Subnet'
		VPC                 :   'AWS.VPC.VPC'
		VPN                 :   'AWS.VPC.VPNConnection'
		VGW                 :   'AWS.VPC.VPNGateway'

		ASG                 :   'AWS.AutoScaling.Group'
		ASL_ACT             :   'AWS.AutoScaling.Activities' #none component
		ASL_INS             :   'AWS.AutoScaling.Instance' #none component
		ASL_LC              :   'AWS.AutoScaling.LaunchConfiguration'
		ASL_NC              :   'AWS.AutoScaling.NotificationConfiguration'
		ASL_SP              :   'AWS.AutoScaling.ScalingPolicy'
		ASL_SA              :   'AWS.AutoScaling.ScheduledActions'
		CLW                 :   'AWS.CloudWatch.CloudWatch'
		SNS_SUB         :   'AWS.SNS.Subscription'
		SNS_TOPIC           :   'AWS.SNS.Topic'
	}


	#private, recent items threshold
	RECENT_NUM    = 5
	RECENT_DAYS   = 30

	RDP_TMPL = "\n
screen mode id:i:2\n
use multimon:i:0\n
desktopwidth:i:1024\n
desktopheight:i:768\n
session bpp:i:32\n
winposstr:s:0,3,0,0,1024,768\n
compression:i:1\n
keyboardhook:i:2\n
audiocapturemode:i:0\n
videoplaybackmode:i:1\n
connection type:i:2\n
displayconnectionbar:i:1\n
disable wallpaper:i:1\n
allow font smoothing:i:0\n
allow desktop composition:i:0\n
disable full window drag:i:1\n
disable menu anims:i:1\n
disable themes:i:0\n
disable cursor setting:i:0\n
bitmapcachepersistenable:i:1\n
full address:s:%s\n
audiomode:i:0\n
redirectprinters:i:1\n
redirectcomports:i:0\n
redirectsmartcards:i:1\n
redirectclipboard:i:1\n
redirectposdevices:i:0\n
redirectdirectx:i:1\n
autoreconnection enabled:i:1\n
authentication level:i:2\n
prompt for credentials:i:0\n
negotiate security layer:i:1\n
remoteapplicationmode:i:0\n
alternate shell:s:\n
shell working directory:s:\n
gatewayhostname:s:\n
gatewayusagemethod:i:4\n
gatewaycredentialssource:i:4\n
gatewayprofileusagemethod:i:0\n
promptcredentialonce:i:1\n
use redirection server name:i:0\n"


	DEMO_STACK_NAME_LIST = [ 'vpc-with-private-subnet-and-vpn', 'vpc-with-public-and-private-subnets-and-vpn', 'vpc-with-public-subnet-only', 'vpc-with-public-and-private-subnets' ]

	TA =
		ERROR: 'ERROR',
		WARNING: 'WARNING',
		NOTICE: 'NOTICE'

	LINUX   = ['centos', 'redhat',  'rhel', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensuse', 'suse', 'sles', 'amazon', 'amaz', 'linux-other']
	WINDOWS = ['windows', 'win']

	OS_TYPE_MAPPING = {
		'linux-other': 'linux'
		'redhat': 'rhel'
		'suse': 'sles'
		'windows': 'mswin'
	}

	REGEXP =
		'stateEditorReference'		: /@\{([A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12})\.\w+\}/g
		'stateEditorOriginReference': /@\{(([\w-]+)\.(([\w-]+(\[\d+\])?)|state.[\w-]+))\}/g
		'uid'						: /[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}/g


	# A map that used by the state editor.
	# It shows which attribute of components can be referenced.
	STATE_REF_DICT =
		_id : "property"
		AWS_VPC_CustomerGateway :
			__array   : false
			IpAddress : false
			Type      : false
			BgpAsn    : false
		AWS_EC2_Instance :
			__array          : false
			PublicIp         : true
			MacAddress       : true
			PrivateIpAddress : true
		AWS_AutoScaling_Group :
			__array           : true
			PublicIp          : true
			MacAddress        : true
			AvailabilityZones : true
			PrivateIpAddress  : true
		AWS_VPC_Subnet :
			__array                 : false
			AvailableIpAddressCount : false
			AvailabilityZone        : false
			CidrBlock               : false
		AWS_VPC_NetworkInterface :
			__array          : true
			PublicIp         : true
			MacAddress       : true
			PrivateIpAddress : true
		AWS_ELB :
			__array : false
			DNSName : false
			CanonicalHostedZoneName : false
			CanonicalHostedZoneNameID : false
			AvailabilityZones : true
		AWS_VPC_VPC :
			__array   : false
			CidrBlock : false
		AWS_EC2_InstanceGroup :
			__array          : false
			PublicIp         : true
			MacAddress       : true
			PrivateIpAddress : true


	VPC_JSON_INIT_LAYOUT =
		VPC :
			coordinate : [5,3]
			size       : [60,60]
		RTB :
			coordinate : [50,5]

	VPC_JSON_INIT_COMP =
		KP :
			type : "AWS.EC2.KeyPair"
			name : "DefaultKP"
			resource : { KeyName : "DefaultKP" }
		SG :
			type : "AWS.EC2.SecurityGroup"
			name : "DefaultSG"
			resource :
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
		ACL :
			type : "AWS.VPC.NetworkAcl"
			name : "DefaultACL"
			resource :
				AssociationSet: []
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
			resource : {}
		RTB :
			type     : "AWS.VPC.RouteTable"
			resource :
				PropagatingVgwSet : [],
				RouteSet          : [{
						State                : 'active',
						Origin               : 'CreateRouteTable',
						GatewayId            : 'local',
						DestinationCidrBlock : '10.0.0.0/16'
				}],
				AssociationSet : [{Main:"true"}]


	#public
	AWS_RESOURCE_KEY        : AWS_RESOURCE_KEY

	INSTANCE_TYPE           : INSTANCE_TYPE
	INSTANCE_STATES         : INSTANCE_STATES

	AWS_RESOURCE_SHORT_TYPE : AWS_RESOURCE_SHORT_TYPE
	REGION_KEYS             : REGION_KEYS
	REGION_SHORT_LABEL      : REGION_SHORT_LABEL
	REGION_LABEL            : REGION_LABEL
	RETURN_CODE             : RETURN_CODE
	LINUX                   : LINUX
	WINDOWS                 : WINDOWS
	#SERVICE_ERROR_MESSAGE  : SERVICE_ERROR_MESSAGE
	MESSAGE_E               : MESSAGE_E
	APP_STATE               : APP_STATE
	OPS_STATE               : OPS_STATE
	OPS_CODE_NAME           : OPS_CODE_NAME
	RECENT_NUM              : RECENT_NUM
	RECENT_DAYS             : RECENT_DAYS
	AWS_RESOURCE            : AWS_RESOURCE
	RDP_TMPL                : RDP_TMPL
	DEMO_STACK_NAME_LIST    : DEMO_STACK_NAME_LIST
	TA                      : TA
	OS_TYPE_MAPPING         : OS_TYPE_MAPPING
	REGEXP                  : REGEXP
	RESTYPE                 : RESTYPE

	VPC_JSON_INIT_COMP   : VPC_JSON_INIT_COMP
	VPC_JSON_INIT_LAYOUT : VPC_JSON_INIT_LAYOUT

