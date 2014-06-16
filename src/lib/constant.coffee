

define ['MC', 'i18n!nls/lang.js'], ( MC, lang ) ->

	wrap = ( dict ) ->
		wrappedDict = {}
		_.each dict, ( name, key ) ->
			wrappedDict[ RESTYPE[ key ] ] = name

		wrappedDict


	AWS_RESOURCE_KEY = {
		"AWS.EC2.AvailabilityZone"					: "ZoneName"
		"AWS.EC2.Instance"							: "InstanceId"
		"AWS.EC2.KeyPair"							: "KeyName"
		"AWS.EC2.SecurityGroup"						: "GroupId"
		"AWS.EC2.EIP"								: "PublicIp"
		"AWS.EC2.AMI"								: "ImageId"
		"AWS.EC2.EBS.Volume"						: "VolumeId"
		"AWS.ELB"									: "LoadBalancerName"
		"AWS.VPC.VPC"								: "VpcId"
		"AWS.VPC.Subnet"							: "SubnetId"
		"AWS.VPC.InternetGateway"					: "InternetGatewayId"
		"AWS.VPC.RouteTable"						: "RouteTableId"
		"AWS.VPC.VPNGateway"						: "VpnGatewayId"
		"AWS.VPC.CustomerGateway"					: "CustomerGatewayId"
		"AWS.VPC.NetworkInterface"					: "NetworkInterfaceId"
		"AWS.VPC.DhcpOptions"						: "DhcpOptionsId"
		"AWS.VPC.VPNConnection"						: "VpnConnectionId"
		"AWS.VPC.NetworkAcl"						: "NetworkAclId"
		"AWS.IAM.ServerCertificate"					: ""
		"AWS.AutoScaling.Group"						: "AutoScalingGroupARN"
		"AWS.AutoScaling.LaunchConfiguration"		: "LaunchConfigurationARN"
		"AWS.AutoScaling.NotificationConfiguration"	: ""
		"AWS.AutoScaling.ScalingPolicy"				: "PolicyARN"
		"AWS.AutoScaling.ScheduledActions"			: "ScheduledActionARN"
		"AWS.CloudWatch.CloudWatch"					: "AlarmArn"
		"AWS.SNS.Subscription"						: ""
		"AWS.SNS.Topic"								: ""
	}

	# A short version
	RESTYPE =
		AZ           : "AWS.EC2.AvailabilityZone"
		INSTANCE     : "AWS.EC2.Instance"
		KP           : "AWS.EC2.KeyPair"
		SG           : "AWS.EC2.SecurityGroup"
		EIP          : "AWS.EC2.EIP"
		AMI          : "AWS.EC2.AMI"
		VOL          : "AWS.EC2.EBS.Volume"
		SNAP         : "AWS.EC2.EBS.Snapshot"
		ELB          : "AWS.ELB"
		VPC          : "AWS.VPC.VPC"
		SUBNET       : "AWS.VPC.Subnet"
		IGW          : "AWS.VPC.InternetGateway"
		RT           : "AWS.VPC.RouteTable"
		VGW          : "AWS.VPC.VPNGateway"
		CGW          : "AWS.VPC.CustomerGateway"
		ENI          : "AWS.VPC.NetworkInterface"
		DHCP         : "AWS.VPC.DhcpOptions"
		VPN          : "AWS.VPC.VPNConnection"
		ACL          : "AWS.VPC.NetworkAcl"
		IAM          : "AWS.IAM.ServerCertificate"
		ASG          : 'AWS.AutoScaling.Group'
		LC           : 'AWS.AutoScaling.LaunchConfiguration'
		NC           : 'AWS.AutoScaling.NotificationConfiguration'
		SP           : 'AWS.AutoScaling.ScalingPolicy'
		SA           : 'AWS.AutoScaling.ScheduledActions'
		CW           : 'AWS.CloudWatch.CloudWatch'
		SUBSCRIPTION : 'AWS.SNS.Subscription'
		TOPIC        : 'AWS.SNS.Topic'

	RESNAME =
		AZ           : "Availability Zone"
		INSTANCE     : "Instance"
		KP           : "Key Pair"
		SG           : "Security Group"
		EIP          : "Elastic IP"
		AMI          : "AMI"
		VOL          : "Volume"
		SNAP         : "Snapshot"
		ELB          : "Load Balancer"
		VPC          : "VPC"
		SUBNET       : "Subnet"
		IGW          : "Internet Gateway"
		RT           : "Route Table"
		VGW          : "VPN Gateway"
		CGW          : "Customer Gateway"
		ENI          : "Network Interface"
		DHCP         : "Dhcp Options"
		VPN          : "VPN Connection"
		ACL          : "Network Acl"
		IAM          : "Server Certificate"
		ASG          : 'AutoScaling Group'
		LC           : 'Launch Configuration'
		NC           : 'Notification Configuration'
		SP           : 'Scaling Policy'
		SA           : 'Scheduled Actions'
		CW           : 'Cloud Watch'
		SUBSCRIPTION : 'Subscription'
		TOPIC        : 'Topic'


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
	OPS_STATE =
		OPS_STATE_PENDING   : "Pending"
		OPS_STATE_INPROCESS : "InProcess"
		OPS_STATE_DONE      : "Done"
		OPS_STATE_ROLLBACK  : "Rollback"
		OPS_STATE_FAILED    : "Failed"

	OPS_CODE_NAME =
		"Forge.Stack.Run"        : "launch"
		"Forge.App.Stop"         : "stop"
		"Forge.App.Start"        : "start"
		"Forge.App.Update"       : "update"
		"Forge.App.State.Update" : "update"
		"Forge.App.Terminate"    : "terminate"

	#private, recent items threshold
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


	#public
	AWS_RESOURCE_KEY        : AWS_RESOURCE_KEY

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
	OPS_STATE               : OPS_STATE
	OPS_CODE_NAME           : OPS_CODE_NAME
	DEMO_STACK_NAME_LIST    : DEMO_STACK_NAME_LIST
	TA                      : TA
	OS_TYPE_MAPPING         : OS_TYPE_MAPPING
	REGEXP                  : REGEXP
	RESTYPE                 : RESTYPE
	STATE_REF_DICT          : STATE_REF_DICT
	RESNAME                 : wrap RESNAME
	WRAP                    : wrap

