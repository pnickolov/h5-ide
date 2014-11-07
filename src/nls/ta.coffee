# Reference: https://trello.com/c/KaOjDSm7/303-orginize-lang-source-coffee

module.exports =
  TA:

   ##### Trust Advisor

    # VPC
    WARNING_NOT_VPC_CAN_CONNECT_OUTSIDE:
      en: "No instance in VPC has Elastic IP or auto-assigned public IP, which means this VPC can only connect to outside via VPN."
      # en: "No instance in VPC has Elastic IP, which means this VPC can only connect to outside via VPN."
      zh: ""

    # Subnet
    ERROR_CIDR_ERROR_CONNECT_TO_ELB:
      en: "Subnet <span class='validation-tag tag-subnet'>%s</span> is attached with a Load Balancer. Its mask must be smaller than /27."
      zh: ""

    # Instance
    NOTICE_INSTANCE_NOT_EBS_OPTIMIZED_FOR_ATTACHED_PROVISIONED_VOLUME:
      en: "Instance <span class='validation-tag tag-instance'>%s</span> has an attached Provisioned IOPS volume but is not EBS-Optimized."
      zh: ""
    WARNING_INSTANCE_SG_RULE_EXCEED_FIT_NUM:
      en: "Instance <span class='validation-tag tag-instance'>%s</span> has more than %s security group rules, If a Instance has a large number of security group rules, performance can be degraded."
      zh: ""
    ERROR_INSTANCE_NAT_CHECKED_SOURCE_DEST:
      en: "To allow routing to work properly, instance <span class='validation-tag tag-instance'>%s</span> should disabled Source/Destination Checking in \"Network Interface Details\""
      zh: ""

    ERROR_INSTANCE_REF_OLD_KEYPAIR:
      en: "%s has associated with an nonexistent key pair <span class='validation-tag'>%s</span>. Make sure to use an existing key pair or creating a new one."
      zh: ""

    NOTICE_KEYPAIR_LONE_LIVE:
      en: "Make sure you have access to all private key files associated with instances or launch configurations. Without them, you won't be able to log into your instances."
      zh: ""


    # ENI
    ERROR_ENI_NOT_ATTACH_TO_INSTANCE:
      en: "Network Interface <span class='validation-tag tag-eni'>%s</span> is not attached to any Instance."
      zh: ""

    # ELB
    ERROR_VPC_HAVE_INTERNET_ELB_AND_NO_HAVE_IGW:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> is internet-facing but VPC no have an Internet Gateway."
      zh: ""

    ERROR_ELB_INTERNET_SHOULD_ATTACH_TO_PUBLIC_SB:
      en: "Internet-facing Load Balancer <span class='validation-tag tag-elb'>%s</span> should attach to a public subnet."
      zh: ""

    ERROR_ELB_NO_ATTACH_INSTANCE_OR_ASG:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> has no instance or auto scaling group added to it."
      zh: ""

    WARNING_ELB_NO_ATTACH_TO_MULTI_AZ:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> is attached to only 1 availability zone. Attach load balancer to multiple availability zones can improve fault tolerance."
      zh: ""

    NOTICE_ELB_REDIRECT_PORT_443_TO_443:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> redirects <span class='validation-tag tag-port'>443</span> to <span class='validation-tag tag-port'>443</span>. Suggest to use load balancer to decrypt and redirect to port <span class='validation-tag tag-port'>80</span>."
      zh: ""

    ERROR_ELB_HAVE_REPEAT_LISTENER_ITEM:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> has duplicate load balancer ports."
      zh: ""

    ERROR_ELB_HAVE_NO_SSL_CERT:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> is using HTTPS/SSL protocol for Load Balancer Listener. Please add server certificate."
      zh: ""

    ERROR_ELB_RULE_NOT_INBOUND_TO_ELB_LISTENER:
      en: "Load balancer <span class='validation-tag tag-elb'>%s</span> should allow inbound traffic towards its Load Balancer Protocol: %s."
      zh: ""

    WARNING_ELB_RULE_NOT_INBOUND_TO_ELB_PING_PORT:
      en: "Load balancer <span class='validation-tag tag-elb'>%s</span>'s security group rule should allow inbound traffic towards its ping port: <span class='validation-tag tag-port'>%s</span>."
      zh: ""

    ERROR_ELB_RULE_NOT_OUTBOUND_TO_INSTANCE_LISTENER:
      en: "Load balancer <span class='validation-tag tag-elb'>%s</span> should allow outbound traffic towards its backend instance or auto-scaling group through Instance Protocol: %s."
      zh: ""

    ERROR_ELB_RULE_INSTANCE_NOT_OUTBOUND_FOR_ELB_LISTENER:
      en: "%s <span class='validation-tag tag-elb'>%s</span> should allow inbound traffic towards %s according to %s's Instance Listener Protocol."
      zh: ""

    ERROR_ELB_ATTACHED_SUBNET_CIDR_SUFFIX_GREATE_27:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span> has been associated with Subnet <span class='validation-tag tag-subnet'>%s</span>, whose CIDR mask must be smaller than /27."
      zh: ""

    ERROR_ELB_SSL_CERT_NOT_EXIST_FROM_AWS:
      en: "Load Balancer <span class='validation-tag tag-elb'>%s</span>'s Listener is configured with nonexistent Server Certificate <span class='validation-tag tag-cert'>%s</span>."
      zh: ""

    # SG
    WARNING_SG_RULE_EXCEED_FIT_NUM:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> has more than %s rules, If a security group has a large number of rules, performance can be degraded."
      zh: ""
    NOTICE_STACK_USING_ONLY_ONE_SG:
      en: "This stack is only using 1 security group."
      zh: ""
    WARNING_SG_USING_ALL_PROTOCOL_RULE:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> is using 'ALL' protocol traffic."
      zh: ""
    WARNING_SG_RULE_FULL_ZERO_SOURCE_TARGET_TO_OTHER_PORT:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> has inbound rule which traffic from <span class='validation-tag tag-ip'>0.0.0.0/0</span> is not targeting port <span class='validation-tag tag-port'>80</span> or <span class='validation-tag tag-port'>443</span>."
      zh: ""
    NOTICE_SG_RULE_USING_PORT_22:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> has rule which using port <span class='validation-tag tag-port'>22</span>. To enhance security, suggest to use other port than <span class='validation-tag tag-port'>22</span>."
      zh: ""
    WARNING_SG_RULE_HAVE_FULL_ZERO_OUTBOUND:
      en: "Security Group <span class='validation-tag tag-sg'>%s</span> has outbound rule towards <span class='validation-tag tag-ip'>0.0.0.0/0</span>. Suggest to change to more specific range."
      zh: ""
    ERROR_RESOURCE_ASSOCIATED_SG_EXCEED_LIMIT:
      en: "%s <span class='validation-tag tag-%s'>%s</span>'s associated Security Group exceed max %s limit."
      zh: ""

    # ASG
    ERROR_ASG_HAS_NO_LAUNCH_CONFIG:
      en:"Auto Scaling Group <span class='validation-tag tag-asg'>%s</span> has no launch configuration."
      zh:""

    WARNING_ELB_HEALTH_NOT_CHECK:
      en: "Auto Scaling Group <span class='validation-tag tag-asg'>%s</span> has connected to Load Balancer but the Load Balancer health check is not enabled."
      zh: ""

    ERROR_HAS_EIP_NOT_HAS_IGW:
      en: "VPC has instance with Elastic IP must have an Internet Gateway."
      zh: ""

    # RT
    NOTICE_RT_ROUTE_NAT:
      en: "Instance <span class='validation-tag tag-instance'>%s</span> is a target of Route Table <span class='validation-tag tag-rtb'>%s</span>. To make sure the routing works, <span class='validation-tag tag-instance'>%s</span> should have security group rule to allow traffic from subnets assciated with <span class='validation-tag tag-rtb'>%s</span>."
      zh: ""

    NOTICE_INSTANCE_HAS_RTB_NO_ELB:
      en: "Route Table <span class='validation-tag tag-rtb'>%s</span> has route to Instance <span class='validation-tag tag-instance'>%s</span>. If <span class='validation-tag tag-instance'>%s</span> is working as NAT instance, it should be assigned with an Elastic IP."
      zh: ""

    WARNING_NO_RTB_CONNECT_IGW:
      en: "No Route Table is connected to Internet Gateway."
      zh: ""

    WARNING_NO_RTB_CONNECT_VGW:
      en: "No Route Table is connected to VPN Gateway."
      zh: ""

    NOTICE_ACL_HAS_NO_ALLOW_RULE:
      en: "Network ACL <span class='validation-tag tag-acl'>%s</span> has no ALLOW rule. The subnet(s) associate(s) with it cannot have traffic in or out."
      zh: ""

    ERROR_RT_HAVE_CONFLICT_DESTINATION:
      en:"Route Table <span class='validation-tag tag-rtb'>%s</span> has routes with conflicting CIDR blocks."
      zh:""

    # AZ
    WARNING_SINGLE_AZ:
      en: "Only 1 Availability Zone is used. Multiple Availability Zone can improve fault tolerance."
      zh: ""

    # CGW
    ERROR_CGW_CHECKING_IP_CONFLICT:
      en:"Checking Customer Gateway IP Address confliction with existing resource..."
      zh:""
    ERROR_CGW_IP_CONFLICT:
      en:"Customer Gateway <span class='validation-tag tag-cgw'>%s</span>'s IP <span class='validation-tag tag-ip'>%s</span> conflicts with existing <span class='validation-tag tag-cgw'>%s</span>'s IP <span class='validation-tag tag-ip'>%s</span>."
      zh:""
    WARNING_CGW_IP_RANGE_ERROR:
      en:"Customer Gateway <span class='validation-tag tag-cgw'>%s</span>'s IP(%s) invalid."
      zh:""
    ERROR_CGW_MUST_ATTACH_VPN:
      en:"Customer Gateway %s must be attached to a VPN Gateway via VPN connection."
      zh:""

    # VPN
    ERROR_VPN_NO_IP_FOR_STATIC_CGW:
      en:"VPN Connection of <span class='validation-tag tag-cgw'>%s</span> and <span class='validation-tag tag-vgw'>%s</span> is missing IP prefix."
      zh:""
    ERROR_VPN_NOT_PUBLIC_IP:
      en:"VPN Connection <span class='validation-tag tag-vpn'>%s</span>'s IP prefix <span class='validation-tag tag-ip'>%s</span> is invalid."
      zh:""

    # Stack
    ERROR_STACK_CHECKING_FORMAT_VALID:
      en:"Checking Stack data format validity..."
      zh:""
    ERROR_STACK_FORMAT_VALID_FAILED:
      en:"Resource %s has format problem, %s."
      zh:""
    ERROR_STACK_HAVE_NOT_EXIST_AMI:
      en:"%s <span class='validation-tag tag-%s'>%s</span>'s AMI <span class='validation-tag tag-ami'>%s</span> is not available any more. Please change another AMI."
      zh:""
    ERROR_STACK_HAVE_NOT_EXIST_SNAPSHOT:
      en:"Snapshot <span class='validation-tag tag-snapshot'>%s</span> attached to %s <span class='validation-tag tag-instance'>%s</span> is not available or not accessible to your account. Please change another one."
      zh:""
    ERROR_STACK_HAVE_NOT_AUTHED_AMI:
      en:"You are not authorized for %s <span class='validation-tag tag-%s'>%s</span>'s AMI <span class='validation-tag tag-ami'>%s</span>. Go to AWS Marketplace to get authorized or use another AMI by creating new instance."
      zh:""

    # State Editor
    ERROR_STATE_EDITOR_INEXISTENT_INSTANCE:
      en: "Instance <span class='validation-tag tag-instance'>%s</span> state <span class='validation-tag tag-state'>%s</span> has referenced the inexistent %s."
      zh: ""

    ERROR_STATE_EDITOR_INEXISTENT_ASG:
      en: "Auto Scaling Group <span class='validation-tag tag-asg'>%s</span> state <span class='validation-tag tag-state'>%s</span> has referenced the inexistent %s."
      zh: ""

    ERROR_STATE_EDITOR_INEXISTENT_OSSERVER:
      en: "Server <span class='validation-tag tag-osserver'>%s</span> state <span class='validation-tag tag-state'>%s</span> has referenced the inexistent %s."
      zh: ""

    ERROR_STATE_EDITOR_EMPTY_REQUIED_PARAMETER:
      en: "<span class='validation-tag tag-instance'>%s</span>'s state <span class='validation-tag tag-state'>%s</span> is missing required parameter <span class='validation-tag tag-parameter'>%s</span>."
      zh: ""

    ERROR_STATE_EDITOR_INVALID_FORMAT:
      en: "<span class='validation-tag tag-instance'>%s</span>'s state <span class='validation-tag tag-state'>%s [%s]</span> should reference a state in correct format. For example, <span class='validation-tag'>@{host1.state.3}</span>."
      zh: ""

    # State
    ERROR_NOT_CONNECT_OUT:
      en: "Subnet <span class='validation-tag tag-subnet'>%s</span> must be connected to internet directly or via a NAT instance. "
      zh: ""

    ERROR_NO_EIP_OR_PIP:
      en: "<span class='validation-tag tag-instance'>%s</span> has configured states. To make sure OpsAgent to work, <span class='validation-tag tag-instance'>%s</span> must have an elastic IP or public IP. If not, subnet <span class='validation-tag tag-subnet'>%s</span>'s outward traffic must be routed to a <a href='javascript:void(0)' class='bubble bubble-NAT-instance' data-bubble-template='bubbleNATreq'>NAT instance</a>."
      zh: ""

    ERROR_NO_CGW:
      en: "You have configured states for instance. To make sure OpsAgent to work, the VPC must have an internet gateway."
      zh: ""
    ERROR_NO_OUTBOUND_RULES:
      en: "<span class='validation-tag tag-instance'>%s</span> has configured states. To make sure OpsAgent to work, it should have outbound rules on <span class='validation-tag tag-port'>80</span> and <span class='validation-tag tag-port'>443</span> ports to the outside."
      zh: ""
    WARNING_OUTBOUND_NOT_TO_ALL:
      en: "<span class='validation-tag tag-instance'>%s</span> has configured states. Suggest to set its outbound rule on <span class='validation-tag tag-port'>80</span> and <span class='validation-tag tag-port'>443</span> to <span class='validation-tag tag-ip'>0.0.0.0/0</span>. Otherwise, agent may not be able to work properly, install packages or check out source codes lacking route to VisualOps's monitoring systems or required repositories."
      zh: ""

    # Share Resource
    ERROR_ASG_NOTIFICATION_NO_TOPIC:
      en: "Auto Scaling Group <span class='validation-tag tag-asg'>%s</span> has configured notification. Please select a SNS Topic for it."
      zh: ""

    ERROR_ASG_POLICY_NO_TOPIC:
      en: "Auto Scaling Group %s's Scaling Policy <span class='validation-tag'>%s</span> has configured notification. Please select a SNS Topic for it."
      zh: ""

    ERROR_ASG_NOTIFICITION_TOPIC_NONEXISTENT:
      en: "Auto Scaling Group <span class='validation-tag tag-asg'>%s</span> is using a nonexistent SNS Topic <span class='validation-tag'>%s</span>. Please change to an existing SNS Topic to make notification work."
      zh: ""

    ERROR_ASG_POLICY_TOPIC_NONEXISTENT:
      en: "Auto Scaling Group <span class='validation-tag tag-asg'>%s</span>'s Scaling Policy %s is using a nonexistent SNS Topic <span class='validation-tag'>%s</span>. Please change to an existing SNS Topic to make notification work."
      zh: ""

    ERROR_VPC_DHCP_NONEXISTENT:
      en: "VPC is using a nonexistent DHCP option set. Please specify default, auto-assigned or an existing DHCP option set."
      zh: ""

    WARNING_VPC_CANNOT_USE_DEFAULT_DHCP_WHEN_USE_VISUALOPS:
      en: "vpc can not use default(none) dhcpoptions when use visualops"
      zh: ""

    ERROR_RDS_DB_T1_MICRO_DEFAULT_OPTION:
      en: " DB Instance %s has db.t1.micro instance class, which can only be members of the default option group."
      zh: ""

    ERROR_RDS_CIDR_NOT_LARGE_ENOUGH:
      en: "The CIDR blocks in each of your subnets must be large enough to accommodate spare IP addresses for Amazon RDS to use during maintenance activities, including failover and compute scaling. (For each DB instance that you run in a VPC, you should reserve at least one address in each subnet in the DB subnet group for use by Amazon RDS for recovery actions.)"
      zh: ""

    ERROR_RDS_TENANCY_MUST_DEFAULT:
      en: "To launch DB instance, instance tenancy attribute of the VPC must be set to default. "
      zh: ""

    ERROR_RDS_SNAPSHOT_NOT_LARGE_ENOUGH:
      en: "Snapshot storage need large than original value."
      zh: ""

    ERROR_RDS_AZ_NOT_CONSISTENT:
      en: "DB Instance <span class='validation-tag'>%s</span> is assigned to a Preferred AZ <span class='validation-tag'>%s</span> inconsistent with its subnet group."
      zh: ""

    ERROR_RDS_ACCESSIBLE_NOT_HAVE_IGW:
      en: "To allow DB instance to be publicly accessible, VPC must have an Internet Gateway."
      zh: ""

    ERROR_RDS_ACCESSIBLE_NOT_HAVE_DNS:
      en: "To allow DB instance to be publicly accessible, VPC must enable DNS hostnames and DNS resolution."
      zh: ""

    ERROR_RDS_OG_COMPATIBILITY:
      en: "App Update: Option Group compatibility."
      zh: ""

    WARNING_RDS_UNUSED_OG_NOT_CREATE:
      en: "Unused Option Group %s will not be created in live app."
      zh: ""

    ERROR_RDS_OG_EXCEED_20_LIMIT:
      en: "Region %s has reached the limit of 20 option groups."
      zh: ""

    ERROR_RDS_SQL_SERVER_MIRROR_MUST_HAVE3SUBNET:
      en: "DB Instance <span class='validation-tag tag-rds'>%s</span> is using SQL Server Mirroring (Multi-AZ). Its subnet group must have 3 subnets in distinct Availability Zones."
      zh: ""

    ERROR_RDS_BACKUP_MAINTENANCE_OVERLAP:
      en: "DB Instance <span class='validation-tag tag-rds'>%s</span> Backup Window and Maintenance Window are overlapping. Please update to avoid overlapping."
      zh: ""

    ERROR_HAVE_NOT_ENOUGH_IP_FOR_DB:
      en:"To accommodate spare IP address for Amazon RDS to use during maintenance activities, subnet <span class='validation-tag tag-subnet'>%s</span> should use a larger CIDR block."
      zh: ""

    ERROR_REPLICA_STORAGE_SMALL_THAN_ORIGIN:
      en: "Read Replica <span class='validation-tag tag-rds'>%s</span> should have same or larger storage than its source <span class='validation-tag tag-rds'>%s</span>."
      zh: ""

    ERROR_MASTER_PASSWORD_INVALID:
      en: "DB instance <span class='validation-tag tag-rds'>%s</span>'s Master Password must contain 8 to 41 characters."
      zh: ""

    ERROR_OG_DB_BOTH_MODIFIED:
      en: "DB Instance %s cannot be modified in the same update with the Option Group %s it is using."
      zh: ""

    # Open Stack

    ERROR_PORT_MUST_CONNECT_WITH_SERVER:
      en: "Port <span class='validation-tag tag-osport'>%s</span> must connect with a server."
      zh: ""

    ERROR_SUBNET_HAS_PORT_SHOULD_CONNECTED_OUT:
      en: "Subnet %s should be connected to a router associated with External Gateway, so that Floating IP would work. "
      zh: ""

    ERROR_SUBNET_HAS_CONFLICT_CIDR_WITH_OTHERS:
      en: "Subnet <span class='validation-tag tag-ossubnet'>%s</span>'s CIDR block(%s) conflicts with  Subnet <span class='validation-tag tag-ossubnet'>%s</span>'s CIDR block(%s)."
      zh: ""

    ERROR_ROUTER_ENABLING_NAT_MUST_CONNECT_EXT:
      en: "Router enabling NAT must be connected to external network."
      zh: ""

    ERROR_ROUTER_XXX_MUST_CONNECT_TO_AT_LEAST_ONE_SUBNET:
      en: "Router <span class='validation-tag tag-osrt'>%s</span> must connect to at least one subnet."
      zh: ""

    ERROR_POOL_XXX_MUST_BE_CONNECTED_TO_A_LISTENER:
      en: "Pool <span class='validation-tag tag-pool'>%s</span> must be connected to a listener"
      zh: ""

    ERROR_LISTENER_XXX_MUST_BE_CONNECTED_TO_A_POOL:
      en: "Listener <span class='validation-tag tag-oslistener'>%s</span> must be connected to a pool"
      zh: ""

    ERROR_POOL_AND_MEMBER_SUBNET_NOT_CONNECTED:
      en: "Load Balancer's Pool <span class='validation-tag tag-ospool'>%s</span> and Member %s must belong to the same subnet or subnets interconnected by the same router. "
      zh: ""

    ERROR_STACK_RESOURCE_EXCCED_LIMIT:
      en: "Resource %s does not have enough quota. %s/%s used."
      zh: ""

    ##### Trust Advisor
