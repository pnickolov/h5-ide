

define [], () ->

	#private
	MESSAGE_E = {
		MESSAGE_E_SESSION  : "This session has expired, please log in again"
		MESSAGE_E_EXTERNAL : "Sorry, there seems to be a problem with AWS"
		MESSAGE_E_ERROR    : "Sorry, we're experiencing techincal difficulty"
		MESSAGE_E_UNKNOWN  : "Something is wrong. Please contact support@madeiracloud.com"
		MESSAGE_E_PARAM    : "Parameter error!"
	}

	#private
	REGION_KEYS = [ 'us-east-1', 'us-west-1', 'us-west-2', 'eu-west-1', 'ap-southeast-1', 'ap-southeast-2', 'ap-northeast-1', 'sa-east-1' ]

	#private
	REGION_LABEL = []
	REGION_LABEL[ 'us-east-1' ]      = 'US East - Virginia'
	REGION_LABEL[ 'us-west-1' ]      = 'US West - N. California'
	REGION_LABEL[ 'us-west-2' ]      = 'US West - Oregon'
	REGION_LABEL[ 'eu-west-1' ]      = 'EU West - Ireland'
	REGION_LABEL[ 'ap-southeast-1' ] = 'Asia Pacific - Singapore'
	REGION_LABEL[ 'ap-southeast-2' ] = 'Asia Pacific - Sydney'
	REGION_LABEL[ 'ap-northeast-1' ] = 'Asia Pacific - Tokyo'
	REGION_LABEL[ 'sa-east-1' ]      = 'South America - Sao Paulo'

	#private
	REGION_SHORT_LABEL = []
	REGION_SHORT_LABEL[ 'us-east-1' ]      = 'Virginia'
	REGION_SHORT_LABEL[ 'us-west-1' ]      = 'N. California'
	REGION_SHORT_LABEL[ 'us-west-2' ]      = 'Oregon'
	REGION_SHORT_LABEL[ 'eu-west-1' ]      = 'Ireland'
	REGION_SHORT_LABEL[ 'ap-southeast-1' ] = 'Singapore'
	REGION_SHORT_LABEL[ 'ap-southeast-2' ] = 'Sydney'
	REGION_SHORT_LABEL[ 'ap-northeast-1' ] = 'Tokyo'
	REGION_SHORT_LABEL[ 'sa-east-1' ]      = 'Sao Paulo'

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
	APP_STATE = {
		APP_STATE_RUNNING		: "Running"
		APP_STATE_STOPPED		: "Stopped"
		APP_STATE_REBOOTING		: "Rebooting"
		APP_STATE_CLONING		: "Cloning"
		APP_STATE_SAVETOSTACK	: "Saving"
		APP_STATE_TERMINATING	: "Terminating"
		APP_STATE_UPDATING		: "Updating"
		APP_STATE_SHUTTING_DOWN	: "Shutting down"
		APP_STATE_STOPPING		: "Stopping"
		APP_STATE_STARTING		: "Starting"
		APP_STATE_TERMINATED	: "Terminated"
	}

	#private
	SERVICE_REGION = []
	SERVICE_REGION[ 'us-east-1' ] = ['cloudfront', 'cloudsearch-us-east-1', 'cloudwatch-us-east-1',	 'dynamodb-us-east-1',
		'ec2-us-east-1', 'elb-us-east-1', 'emr-us-east-1', 'elastictranscoder-us-east-1', 'elasticache-us-east-1', 'fps',
		'glacier-us-east-1', 'mturk-requestor', 'mturk-worker', 'redshift-us-east-1', 'rds-us-east-1', 'route53',
		'ses-us-east-1', 'sns-us-east-1', 'sqs-us-east-1', 's3-us-standard', 'swf-us-east-1', 'simpledb-us-east-1',
		'vpc-us-east-1', 'cloudformation-us-east-1', 'cloudhsm-us-east-1', 'datapipeline-us-east-1', 'directconnect-us-east-1',
		'elasticbeanstalk-us-east-1', 'import-export', 'management-console', 'opsworks-us-east-1', 'storagegateway-us-east-1'
	]
	SERVICE_REGION[ 'us-west-1' ] = [ 'cloudfront', 'cloudsearch-us-west-1', 'cloudwatch-us-west-1', 'dynamodb-us-west-1',
          'ec2-us-west-1', 'elb-us-west-1', 'emr-us-west-1', 'elastictranscoder-us-west-1', 'elasticache-us-west-1', 'fps',
          'glacier-us-west-1', 'mturk-requestor', 'mturk-worker', 'rds-us-west-1', 'route53', 'sns-us-west-1','sqs-us-west-1',
          's3-us-west-1', 's3-us-standard', 'swf-us-west-1', 'simpledb-us-west-1', 'vpc-us-west-1', 'cloudformation-us-west-1',
          'directconnect-us-west-1','elasticbeanstalk-us-west-1', 'import-export', 'management-console', 'storagegateway-us-west-1'
     ]
	SERVICE_REGION[ 'us-west-2' ] = [
		'cloudfront', 'cloudsearch-us-west-2', 'cloudwatch-us-west-2', 'dynamodb-us-west-2', 'ec2-us-west-2', 'elb-us-west-2',
		'emr-us-west-2', 'elastictranscoder-us-west-2', 'elasticache-us-west-2', 'fps', 'glacier-us-west-2', 'mturk-requestor',
		'mturk-worker', 'redshift-us-west-2', 'rds-us-west-2', 'route53', 'sns-us-west-2', 'sqs-us-west-2', 's3-us-west-2',
		's3-us-standard', 'swf-us-west-2', 'simpledb-us-west-2', 'vpc-us-west-2', 'cloudformation-us-west-2', 'directconnect-us-east-1',
		'elasticbeanstalk-us-west-2', 'import-export', 'management-console','storagegateway-us-west-2'
	]
	SERVICE_REGION[ 'sa-east-1' ] = ['cloudfront', 'cloudwatch-sa-east-1', 'dynamodb-sa-east-1', 'ec2-sa-east-1', 'elb-sa-east-1',
		'emr-sa-east-1', 'elasticache-sa-east-1', 'rds-sa-east-1', 'route53', 'sns-sa-east-1', 'sqs-sa-east-1', 's3-sa-east-1',
		'swf-sa-east-1', 'simpledb-sa-east-1', 'vpc-sa-east-1', 'cloudformation-sa-east-1', 'directconnect-sa-east-1',
		'elasticbeanstalk-sa-east-1', 'management-console', 'storagegateway-sa-east-1'
	]
	SERVICE_REGION[ 'eu-west-1' ] = ['cloudfront', 'cloudsearch-eu-west-1', 'cloudwatch-eu-west-1', 'dynamodb-eu-west-1', 'ec2-eu-west-1',
	'elb-eu-west-1', 'emr-eu-west-1', 'elastictranscoder-eu-west-1', 'elasticache-eu-west-1', 'glacier-eu-west-1', 'mturk-worker',
	'redshift-eu-west-1', 'rds-eu-west-1', 'route53', 'sns-eu-west-1', 'sqs-eu-west-1', 's3-eu-west-1', 'swf-eu-west-1', 'simpledb-eu-west-1',
	'vpc-eu-west-1', 'cloudformation-eu-west-1', 'cloudhsm-eu-west-1', 'directconnect-eu-west-1', 'elasticbeanstalk-eu-west-1', 'import-export',
	'management-console', 'storagegateway-eu-west-1'
	]
	SERVICE_REGION[ 'ap-southeast-1' ] = ['cloudfront', 'cloudsearch-ap-southeast-1', 'cloudwatch-ap-southeast-1','dynamodb-ap-southeast-1',
	'ec2-ap-southeast-1', 'elb-ap-southeast-1', 'emr-ap-southeast-1', 'elastictranscoder-ap-southeast-1', 'elasticache-ap-southeast-1',
	'mturk-worker', 'rds-ap-southeast-1', 'route53', 'sns-ap-southeast-1', 'sqs-ap-southeast-1', 's3-ap-southeast-1','swf-ap-southeast-1',
	'simpledb-ap-southeast-1', 'vpc-ap-southeast-1', 'cloudformation-ap-southeast-1', 'directconnect-ap-southeast-1',
	'elasticbeanstalk-ap-southeast-1', 'import-export', 'management-console', 'storagegateway-ap-southeast-1'
	]
	SERVICE_REGION[ 'ap-southeast-2' ] = ['cloudfront', 'cloudwatch-ap-southeast-2', 'dynamodb-ap-southeast-2', 'ec2-ap-southeast-2',
	'elb-ap-southeast-2', 'emr-ap-southeast-2', 'mturk-worker', 'rds-ap-southeast-2', 'route53', 'sns-ap-southeast-2', 'sqs-ap-southeast-2',
	's3-ap-southeast-2', 'swf-ap-southeast-2', 'simpledb-ap-southeast-2', 'vpc-ap-southeast-2', 'cloudformation-ap-southeast-2',
	'directconnect-ap-southeast-2', 'elasticbeanstalk-ap-southeast-2', 'import-export', 'management-console', 'storagegateway-ap-southeast-2'
	]
	SERVICE_REGION[ 'ap-northeast-1' ] = ['cloudfront', 'cloudwatch-ap-northeast-1', 'dynamodb-ap-northeast-1', 'ec2-ap-northeast-1',
	'elb-ap-northeast-1', 'emr-ap-northeast-1', 'elastictranscoder-ap-northeast-1', 'elasticache-ap-northeast-1', 'glacier-ap-northeast-1',
	'mturk-worker', 'redshift-ap-northeast-1', 'rds-ap-northeast-1', 'route53', 'sns-ap-northeast-1', 'sqs-ap-northeast-1', 's3-ap-northeast-1',
	'swf-ap-northeast-1', 'simpledb-ap-northeast-1', 'vpc-ap-northeast-1', 'cloudformation-ap-northeast-1',
	'directconnect-ap-northeast-1', 'elasticbeanstalk-ap-northeast-1', 'import-export', 'management-console', 'storagegateway-ap-northeast-1'
	]

	#private
	OPS_STATE = {
		OPS_STATE_PENDING		: "Pending"
		OPS_STATE_INPROCESS		: "InProcess"
		OPS_STATE_DONE			: "Done"
		OPS_STATE_ROLLBACK		: "Rollback"
		OPS_STATE_FAILED		: "Failed"
	}

	AWS_RESOURCE = {
		INSTANCE 		:	'EC2.Instance'
		EIP				:	'EC2.EIP'
		VOLUME			:	'EBS.Volume'
		VPC				:	'VPC'
		VPN				:	'VPC.VPN'
		ELB				:	'ELB'
	}


	#private, recent items threshold
	RECENT_NUM		= 4
	RECENT_DAYS		= 30

	#public
	REGION_KEYS			: REGION_KEYS
	REGION_SHORT_LABEL	: REGION_SHORT_LABEL
	REGION_LABEL		: REGION_LABEL
	RETURN_CODE			: RETURN_CODE
	MESSAGE_E			: MESSAGE_E
	APP_STATE			: APP_STATE
	OPS_STATE			: OPS_STATE
	RECENT_NUM			: RECENT_NUM
	RECENT_DAYS			: RECENT_DAYS
	AWS_RESOURCE	    : AWS_RESOURCE
	SERVICE_REGION		: SERVICE_REGION


