

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
	OPS_STATE = {
		OPS_STATE_PENDING		: "Pending"
		OPS_STATE_INPROCESS		: "InProcess"
		OPS_STATE_DONE			: "Done"
		OPS_STATE_ROLLBACK		: "Rollback"
		OPS_STATE_FAILED		: "Failed"
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


