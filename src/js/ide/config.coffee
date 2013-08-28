###
tmpDebug = console.log
this.debug = () ->
	tmpDebug.apply console, arguments

emptyFunction = ->
	for method of console
		if Object.prototype.toString.call method is '[object Function]'
			console[method] = emptyFunction
###

require.config {

	baseUrl                  : './'

	waitSeconds              : 30

	deps                     : [ 'main' ]

	locale                   : 'en-us'

	paths                    :

		#############################################
		# main
		#############################################
		'main'               :   'js/ide/main'

		#############################################
		# vender
		#############################################
		'jquery'             : 'vender/jquery/jquery'
		'canvon'             : 'vender/canvon/canvon'

		'underscore'         : 'vender/underscore/underscore'
		'backbone'           : 'vender/backbone/backbone'
		'handlebars'         : 'vender/handlebars/handlebars'

		'domReady'           : 'vender/requirejs/domReady'
		'text'               : 'vender/requirejs/text'
		'i18n'               : 'vender/requirejs/i18n'

		'zeroclipboard'      : 'vender/zeroclipboard/ZeroClipboard'
		'jqpagination'       : 'vender/jqpagination/jqpagination'
		'sprintf'            : 'vender/sprintf/sprintf'

		#############################################
		# lib
		#############################################
		'MC'                 : 'lib/MC.core'
		'MC.template'        : 'lib/MC.template'
		'MC.ide.template'    : 'lib/MC.ide.template'
		'MC.validate'  	     : 'lib/MC.validate'

		#canvas
		'MC.canvas'          : 'lib/MC.canvas'
		'MC.canvas.constant' : 'lib/MC.canvas.constant'
		'MC.canvas.add'      : 'lib/MC.canvas.add'

		#############################################
		# lib/aws logic handler
		#############################################
		'aws_handle'         : 'lib/aws/main'

		#############################################
		# ui/common
		#############################################
		'UI.tooltip'         : 'ui/common/UI.tooltip'
		'UI.scrollbar'       : 'ui/common/UI.scrollbar'
		'UI.accordion'       : 'ui/common/UI.accordion'
		'UI.tabbar'          : 'ui/common/UI.tabbar'
		'UI.bubble'          : 'ui/common/UI.bubble'
		'UI.modal'           : 'ui/common/UI.modal'
		'UI.table'           : 'ui/common/UI.table'
		'UI.tablist'         : 'ui/common/UI.tablist'
		'UI.fixedaccordion'  : 'ui/common/UI.fixedaccordion'
		'UI.selectbox'       : 'ui/common/UI.selectbox'
		'UI.toggleicon'      : 'ui/common/UI.toggleicon'
		'UI.searchbar'       : 'ui/common/UI.searchbar'
		'UI.filter'          : 'ui/common/UI.filter'
		'UI.radiobuttons'    : 'ui/common/UI.radiobuttons'
		'UI.notification'    : 'ui/common/UI.notification'
		'UI.secondarypanel'  : 'ui/common/UI.secondarypanel'
		'UI.slider'          : 'ui/common/UI.slider'
		'UI.editablelabel'   : 'ui/common/UI.editablelabel'
		'UI.multiinputbox'   : 'ui/common/UI.multiinputbox'
		'UI.zeroclipboard'   : 'ui/common/UI.zeroclipboard'
		'UI.sortable'        : 'ui/common/jquery.sortable'
		'UI.parsley' 	     : 'ui/common/UI.parsley'

		#jquery plugin
		'hoverIntent'        : 'ui/common/jquery.hoverIntent.minified'

		#delete
		#'parsley'           : 'ui/common/parsley.min'
		#'bootstrap-tab'     : 'ui/common/bootstrap-tab'
		#'bootstrap-dropdown': 'ui/common/bootstrap-dropdown'

		#############################################
		# constant
		#############################################
		'constant'           : 'lib/constant'

		#############################################
		# main
		#############################################
		'router'             : 'js/ide/router'
		'ide'                : 'js/ide/ide'
		'view'               : 'js/ide/view'
		#temp
		'layout'             : 'js/ide/layout'
		'canvas_layout'      : 'js/ide/canvas_layout'

		#############################################
		# module
		#############################################
		'header'             : 'module/header/main'
		'navigation'         : 'module/navigation/main'
		'tabbar'             : 'module/tabbar/main'
		'dashboard'          : 'module/dashboard/main'
		'design'             : 'module/design/main'
		'process'            : 'module/process/main'

		#sub module with design
		'resource'           : 'module/design/resource/main'
		'property'           : 'module/design/property/main'
		'canvas'             : 'module/design/canvas/main'
		'toolbar'            : 'module/design/toolbar/main'

		#############################################
		# events
		#############################################
		'event'              : 'event/ide_event'

		#############################################
		# websocket
		#############################################
		'Meteor'             : 'vender/meteor/meteor'
		'WS'                 : 'lib/websocket'

		#############################################
		# model
		#############################################

		#base_model
		'base_model'             : 'model/base_model'

		'session_model'          : 'model/session_model'
		'favorite_model'         : 'model/favorite_model'
		'app_model'              : 'model/app_model'
		'stack_model'            : 'model/stack_model'
		'ec2_model'              : 'model/aws/ec2/ec2_model'
		'vpc_model'              : 'model/aws/vpc/vpc_model'
		'aws_model'              : 'model/aws/aws_model'
		'ami_model'              : 'model/aws/ec2/ami_model'
		'ebs_model'              : 'model/aws/ec2/ebs_model'
		'elb_model'              : 'model/aws/elb/elb_model'
		'dhcp_model'             : 'model/aws/vpc/dhcp_model'
		'customergateway_model'  : 'model/aws/vpc/customergateway_model'
		'vpngateway_model'       : 'model/aws/vpc/vpngateway_model'
		'keypair_model'          : 'model/aws/ec2/keypair_model'
		'autoscaling_model'      : 'model/aws/autoscaling/autoscaling_model'
		'cloudwatch_model'       : 'model/aws/cloudwatch/cloudwatch_model'
		'sns_model'              : 'model/aws/sns/sns_model'

		#result_vo
		'result_vo'              : 'service/result_vo'

		#############################################
		# service
		#############################################

		#forge
		'favorite_service'       : 'service/favorite/favorite_service'
		'session_service'        : 'service/session/session_service'
		'app_service'            : 'service/app/app_service'
		'stack_service'          : 'service/stack/stack_service'
		'aws_service'            : 'service/aws/aws/aws_service'

		#aws
		'ami_service'            : 'service/aws/ec2/ami/ami_service'
		'ebs_service'            : 'service/aws/ec2/ebs/ebs_service'
		'ec2_service'            : 'service/aws/ec2/ec2/ec2_service'
		'eip_service'            : 'service/aws/ec2/eip/eip_service'
		'instance_service'       : 'service/aws/ec2/instance/instance_service'
		'keypair_service'        : 'service/aws/ec2/keypair/keypair_service'
		'placementgroup_service' : 'service/aws/ec2/placementgroup/placementgroup_service'
		'securitygroup_service'  : 'service/aws/ec2/securitygroup/securitygroup_service'
		'acl_service'            : 'service/aws/vpc/acl/acl_service'
		'customergateway_service': 'service/aws/vpc/customergateway/customergateway_service'
		'dhcp_service'           : 'service/aws/vpc/dhcp/dhcp_service'
		'eni_service'            : 'service/aws/vpc/eni/eni_service'
		'internetgateway_service': 'service/aws/vpc/internetgateway/internetgateway_service'
		'routetable_service'     : 'service/aws/vpc/routetable/routetable_service'
		'subnet_service'         : 'service/aws/vpc/subnet/subnet_service'
		'vpc_service'            : 'service/aws/vpc/vpc/vpc_service'
		'vpngateway_service'     : 'service/aws/vpc/vpngateway/vpngateway_service'
		'vpn_service'            : 'service/aws/vpc/vpn/vpn_service'
		'elb_service'            : 'service/aws/elb/elb/elb_service'
		'iam_service'            : 'service/aws/iam/iam/iam_service'

		#
		'autoscaling_service'    : 'service/aws/autoscaling/autoscaling/autoscaling_service'
		'cloudwatch_service'     : 'service/aws/cloudwatch/cloudwatch/cloudwatch_service'
		'sns_service'            : 'service/aws/sns/sns/sns_service'

	shim               :

		#############################################
		# vender
		#############################################

		'jquery'       :
			exports    : '$'

		'canvon'       :
			deps       : [ 'jquery', 'canvas' ]
			exports    : 'Canvon'

		'underscore'   :
			exports    : '_'

		'backbone'     :
			deps       : [ 'underscore', 'jquery' ]
			exports    : 'Backbone'

		'handlebars'   :
			exports    : 'Handlebars'

		#############################################
		# MC
		#############################################

		'MC'           :
			deps       : [ 'jquery','sprintf' ]
			exports    : 'MC'

		'MC.validate'  :
			deps       : [ 'MC' ]

		'MC.template'  :
			deps       : [ 'handlebars', 'MC' ]
			exports    : 'MC.template'

		'MC.ide.template'  :
			deps       : [ 'MC', 'jquery', 'underscore' ]

		'MC.canvas'    :
			deps       : [ 'MC', 'canvon' ]

		'MC.canvas.constant':
			deps       : [ 'MC.canvas' ]

		'MC.canvas.add':
			deps       : [ 'MC.canvas.constant' ]

		#############################################
		# UI
		#############################################

		'UI.tabbar'    :
			deps       : [ 'MC.template', 'jquery' ]

		'UI.bubble'    :
			deps       : [ 'MC.template', 'jquery' ]

		'UI.modal'     :
			deps       : [ 'MC.template', 'jquery' ]

		'UI.tooltip'   :
			deps       : [ 'jquery' ]

		'UI.scrollbar' :
			deps       : [ 'jquery' ]

		'UI.accordion' :
			deps       : [ 'jquery' ]

		'UI.table'     :
			deps       : [ 'jquery' ]

		'UI.tablist'   :
			deps       : [ 'jquery' ]

		'UI.fixedaccordion' :
			deps       : [ 'jquery' ]

		'UI.selectbox' :
			deps       : [ 'jquery' ]

		'UI.toggleicon' :
			deps       : [ 'jquery' ]

		'UI.searchbar' :
			deps       : [ 'jquery' ]

		'UI.filter'    :
			deps       : [ 'jquery' ]

		'UI.radiobuttons' :
			deps       : [ 'jquery' ]

		'UI.notification' :
			deps       : [ 'jquery' ]

		'UI.secondarypanel' :
			deps       : [ 'jquery' ]

		'UI.slider'    :
			deps       : [ 'jquery' ]

		'UI.editablelabel' :
			deps       : [ 'jquery' ]

		'UI.multiinputbox' :
			deps       : [ 'jquery' ]

		'UI.zeroclipboard' :
			deps       : [ 'jquery' ]

		'UI.sortable'  :
			deps       : [ 'jquery' ]

		'UI.parsley'   :
			deps       : [ 'jquery' ]

		#############################################
		# WS
		#############################################

		'Meteor'       :
			deps       : ['underscore']
			exports    : 'Meteor'

		'WS'           :
			deps       : [ 'Meteor', 'underscore', 'MC' ]
			exports    : 'WS'

		#############################################
		# temp
		#############################################

		'canvas_layout':
			deps       : [ 'MC.canvas', 'MC.canvas.add', 'MC.canvas.constant', 'canvon' ]

}

#requirejs.onError = ( err ) ->
#    console.log 'error type:', err.requireType, ', modules:', err.requireModules, ', error:', err
