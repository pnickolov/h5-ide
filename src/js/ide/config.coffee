###
emptyFunction = ->

for key, value of console
	if key isnt 'debug' and Object.prototype.toString.call( value ) is '[object Function]'
		console[ key ] = emptyFunction
###

require.config {

	baseUrl                  : './'

	waitSeconds              : 30

	deps                     : [ 'main' ]

	locale                   : language

	urlArgs                  : 'v=' + version

	paths                    :

		#############################################
		# main
		#############################################
		'main'               : 'js/ide/main'

		#############################################
		# vender
		#############################################
		'jquery'             : [ current_jquery , 'vender/jquery/jquery' ]
		'canvon'             : 'vender/canvon/canvon'

		'underscore'         : 'vender/underscore/underscore'
		'backbone'           : 'vender/backbone/backbone'
		'handlebars'         : 'vender/handlebars/handlebars'

		'domReady'           : 'vender/requirejs/domReady'
		'text'               : 'vender/requirejs/text'
		'i18n'               : 'vender/requirejs/i18n'

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

		#############################################
		# lib/aws logic handler
		#############################################
		'aws_handle'         : 'lib/aws/main'
		'forge_handle'       : 'lib/forge/main'
		'common_handle'       : 'lib/common/main'

		#
		'validation'         : 'component/trustedadvisor/validation'
		'ta_conf'            : 'component/trustedadvisor/config'
		'validation_helper'	 : 'component/trustedadvisor/lib/helper'

		#statusbar state
		'state_status'       : 'component/statestatus/main'

		#############################################
		# ui/common
		#############################################
		'UI.tooltip'       : 'ui/common/UI.tooltip'
		'UI.scrollbar'     : 'ui/common/UI.scrollbar'
		'UI.tabbar'        : 'ui/common/UI.tabbar'
		'UI.bubble'        : 'ui/common/UI.bubble'
		'UI.modal'         : 'ui/common/UI.modal'
		'UI.table'         : 'ui/common/UI.table'
		'UI.tablist'       : 'ui/common/UI.tablist'
		'UI.selectbox'     : 'ui/common/UI.selectbox'
		'UI.searchbar'     : 'ui/common/UI.searchbar'
		'UI.filter'        : 'ui/common/UI.filter'
		'UI.radiobuttons'  : 'ui/common/UI.radiobuttons'
		'UI.notification'  : 'ui/common/UI.notification'
		'UI.multiinputbox' : 'ui/common/UI.multiinputbox'
		'UI.canvg'         : 'ui/common/UI.canvg'
		'UI.sortable'      : 'ui/common/jquery.sortable'
		'UI.parsley'       : 'ui/common/UI.parsley'
		'UI.errortip'      : 'ui/common/UI.errortip'

		#jquery plugin
		'hoverIntent'        : 'ui/common/jquery.hoverIntent.minified'
		'bootstrap-carousel' : 'ui/common/bootstrap-carousel'

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
		#'layout'            : 'js/ide/layout'
		'canvas_layout'      : 'js/ide/canvas_layout'

		#############################################
		# design model
		#############################################
		'Design'             : 'module/design/framework/Design'
		'CanvasManager'      : 'module/design/framework/canvasview/CanvasManager'

		#############################################
		# module
		#############################################
		'base_main'          : 'module/base/base_main'

		'header'             : 'module/header/main'
		'header_view'        : 'module/header/view'
		'header_model'       : 'module/header/model'

		'navigation'         : 'module/navigation/main'
		'navigation_view'    : 'module/navigation/view'
		'navigation_model'   : 'module/navigation/model'

		'tabbar'             : 'module/tabbar/main'
		'tabbar_view'        : 'module/tabbar/view'
		'tabbar_model'       : 'module/tabbar/model'

		'dashboard'          : 'module/dashboard/main'
		'dashboard_view'     : 'module/dashboard/overview/view'
		'dashboard_model'    : 'module/dashboard/overview/model'

		'process'            : 'module/process/main'
		'process_view'       : 'module/process/view'
		'process_model'      : 'module/process/model'

		'design_module'      : 'module/design/main'
		'design_view'        : 'module/design/view'
		'design_model'       : 'module/design/model'

		#sub module with design
		'resource'           : 'module/design/resource/main'
		'property'           : 'module/design/property/main'
		'canvas'             : 'module/design/canvas/main'
		'toolbar'            : 'module/design/toolbar/main'

		#############################################
		# component
		#############################################

		'unmanagedvpc'       : 'component/unmanagedvpc/main'
		'unmanagedvpc_view'  : 'component/unmanagedvpc/view'
		'unmanagedvpc_model' : 'component/unmanagedvpc/model'

		'jquery_sort'       : 'component/stateeditor/lib/jquery_sort'
		'markdown'    : 'component/stateeditor/lib/markdown'
		'ace'                : 'component/stateeditor/lib/ace/ace'
		'ace_ext_language_tools' : 'component/stateeditor/lib/ace/ext-language_tools'
		'stateeditor'        : 'component/stateeditor/main'
		'stateeditor_view'   : 'component/stateeditor/view'
		'stateeditor_model'  : 'component/stateeditor/model'

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

		'account_model'          : 'model/account_model'
		'session_model'          : 'model/session_model'
		'favorite_model'         : 'model/favorite_model'
		'app_model'              : 'model/app_model'
		'stack_model'            : 'model/stack_model'
		'state_model'            : 'model/state_model'
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
		'subnet_model'           : 'model/aws/vpc/subnet_model'
		'instance_model'         : 'model/aws/ec2/instance_model'

		#result_vo
		'result_vo'              : 'service/result_vo'

		#############################################
		# service
		#############################################

		#forge
		'favorite_service'       : 'service/favorite/favorite_service'
		'session_service'        : 'service/session/session_service'
		'account_service'        : 'service/account/account_service'
		'app_service'            : 'service/app/app_service'
		'stack_service'          : 'service/stack/stack_service'
		'aws_service'            : 'service/aws/aws/aws_service'
		'state_service'          : 'service/state/state_service'

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
			deps       : [ 'jquery', 'underscore', 'backbone', 'handlebars', 'sprintf' ]
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

		'forge_handle' :
			deps       : [ 'Design' ]

		'aws_handle'   :
			deps       : [ 'Design' ]

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

		'UI.table'     :
			deps       : [ 'jquery' ]

		'UI.tablist'   :
			deps       : [ 'jquery' ]

		'UI.selectbox' :
			deps       : [ 'jquery' ]

		'UI.searchbar' :
			deps       : [ 'jquery' ]

		'UI.filter'    :
			deps       : [ 'jquery' ]

		'UI.radiobuttons' :
			deps       : [ 'jquery' ]

		'UI.notification' :
			deps       : [ 'jquery' ]

		'UI.multiinputbox' :
			deps       : [ 'jquery' ]

		'UI.sortable'  :
			deps       : [ 'jquery' ]

		'UI.parsley'   :
			deps       : [ 'jquery', 'UI.errortip' ]

		'UI.errortip'   :
			deps       : [ 'jquery' ]


		'bootstrap-carousel':
			deps	   : [ 'jquery' ]

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
		# modules
		#############################################

		'header'       :
			deps       : [ 'header_view', 'header_model', 'MC' ]

		'navigation'   :
			deps       : [ 'navigation_view', 'navigation_model', 'MC' ]

		'tabbar'       :
			deps       : [ 'tabbar_view', 'tabbar_model', 'MC' ]

		'dashboard'    :
			deps       : [ 'dashboard_view', 'dashboard_model', 'MC' ]

		'process'      :
			deps       : [ 'process_view', 'process_model', 'MC' ]

		'main'         :
			deps       : [ 'jquery' ]

		# unmanaged vpc

		# state editor
		'jquery_sort' :
			deps       : [ 'jquery', 'MC' ]

		'markdown' :
			deps       : [ 'MC' ]

		'ace_ext_language_tools' :
			deps       : [ 'ace' ]

		'stateeditor'  :
			deps       : [ 'stateeditor_view', 'stateeditor_model', 'jquery_sort', 'markdown', 'ace_ext_language_tools', 'MC' ]
}

#requirejs.onError = ( err ) ->
#    console.log 'error type:', err.requireType, ', modules:', err.requireModules, ', error:', err
