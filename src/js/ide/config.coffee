
require.config {

	baseUrl            : './'

	waitSeconds        : 30

	deps               : [ 'js/ide/main' ]

	locale             : 'en-us'

	paths              :

		#vender
		'jquery'       : 'vender/jquery/jquery'
		'canvon'       : 'vender/canvon/canvon'

		'underscore'   : 'vender/underscore/underscore'
		'backbone'     : 'vender/backbone/backbone'
		'handlebars'   : 'vender/handlebars/handlebars'

		'domReady'     : 'vender/requirejs/domReady'
		'text'         : 'vender/requirejs/text'
		'i18n'         : 'vender/requirejs/i18n'

		'zeroclipboard': 'vender/zeroclipboard/ZeroClipboard'
		'jqpagination' : 'vender/jqpagination/jquery.jqpagination'

		#core lib
		'MC'                 : 'lib/MC.core'
		'MC.template'        : 'lib/MC.template'
		'MC.ide.template'    : 'lib/MC.ide.template'

		#canvas
		'MC.canvas'          : 'lib/MC.canvas'
		'MC.canvas.constant' : 'lib/MC.canvas.constant'
		'MC.canvas.add'      : 'lib/MC.canvas.add'

		#ui
		'UI.tooltip'        : 'ui/common/UI.tooltip'
		'UI.scrollbar'      : 'ui/common/UI.scrollbar'
		'UI.accordion'      : 'ui/common/UI.accordion'
		'UI.tabbar'         : 'ui/common/UI.tabbar'
		'UI.bubble'         : 'ui/common/UI.bubble'
		'UI.modal'          : 'ui/common/UI.modal'
		'UI.table'          : 'ui/common/UI.table'
		'UI.tablist'        : 'ui/common/UI.tablist'
		'UI.fixedaccordion' : 'ui/common/UI.fixedaccordion'
		'UI.selectbox'      : 'ui/common/UI.selectbox'
		'UI.toggleicon'     : 'ui/common/UI.toggleicon'
		'UI.searchbar'      : 'ui/common/UI.searchbar'
		'UI.filter'         : 'ui/common/UI.filter'
		'UI.radiobuttons'   : 'ui/common/UI.radiobuttons'
		'UI.notification'   : 'ui/common/UI.notification'
		'UI.secondarypanel' : 'ui/common/UI.secondarypanel'
		'UI.slider'         : 'ui/common/UI.slider'
		'UI.editablelabel'  : 'ui/common/UI.editablelabel'
		'UI.multiinputbox'  : 'ui/common/UI.multiinputbox'
		'UI.zeroclipboard'  : 'ui/common/UI.zeroclipboard'
		'UI.sortable'       : 'ui/common/jquery.sortable'

		#jquery plugin
		'hoverIntent'  : 'ui/common/jquery.hoverIntent.minified'
		#'parsley' : 'ui/common/parsley.min'

		#bootstrap
		#'bootstrap-tab'     : 'ui/common/bootstrap-tab'
		#'bootstrap-dropdown' : 'ui/common/bootstrap-dropdown'

		#ide
		'router'       : 'js/ide/router'
		'ide'          : 'js/ide/ide'
		'view'         : 'js/ide/view'
		#temp
		'layout'       : 'js/ide/layout'
		'canvas_layout': 'js/ide/canvas_layout'

		#module
		'header'       : 'module/header/main'
		'navigation'   : 'module/navigation/main'
		'tabbar'       : 'module/tabbar/main'
		'dashboard'    : 'module/dashboard/main'
		'design'       : 'module/design/main'
		'process'      : 'module/process/main'

		#sub module with design
		'resource'     : 'module/design/resource/main'
		'property'     : 'module/design/property/main'
		'canvas'       : 'module/design/canvas/main'
		'toolbar'      : 'module/design/toolbar/main'

		#aws logic handler
		'aws_handle'   : 'lib/aws/main'

		#events
		'event'        : 'event/ide_event'

		#model
		'session_model'   : 'model/session_model'

		'favorite_model' : 'model/favorite_model'
		'app_model'    : 'model/app_model'
		'stack_model'  : 'model/stack_model'
		'ec2_model'    : 'model/aws/ec2/ec2_model'
		'vpc_model'    : 'model/aws/vpc/vpc_model'
		'aws_model'    : 'model/aws/aws_model'
		'ami_model'    : 'model/aws/ec2/ami_model'
		'ebs_model'    : 'model/aws/ec2/ebs_model'
		'elb_model'    : 'model/aws/elb/elb_model'
		'dhcp_model'   : 'model/aws/vpc/dhcp_model'
		'customergateway_model'    : 'model/aws/vpc/customergateway_model'
		'vpngateway_model'    : 'model/aws/vpc/vpngateway_model'
		'keypair_model' : 'model/aws/ec2/keypair_model'

		'autoscaling_model' : 'model/aws/autoscaling/autoscaling_model'
		'cloudwatch_model'  : 'model/aws/cloudwatch/cloudwatch_model'
		'sns_model'         : 'model/aws/sns/sns_model'

		#result_vo
		'result_vo'    : 'service/result_vo'

		#constant
		'constant'     : 'lib/constant'

		#websocket
		'Meteor'       : 'vender/meteor/meteor'
		'WS'           : 'lib/websocket'

		#############################################
		#############################################

		#forge service

		'favorite_service'   : 'service/favorite/favorite_service'

		'session_service'   : 'service/session/session_service'

		'app_service'   : 'service/app/app_service'

		'stack_service' : 'service/stack/stack_service'

		'aws_service'   : 'service/aws/aws/aws_service'

		#aws service

		'ami_service'   : 'service/aws/ec2/ami/ami_service'

		'ebs_service'   : 'service/aws/ec2/ebs/ebs_service'

		'ec2_service'   : 'service/aws/ec2/ec2/ec2_service'

		'eip_service'   : 'service/aws/ec2/eip/eip_service'

		'instance_service'   : 'service/aws/ec2/instance/instance_service'

		'keypair_service'    : 'service/aws/ec2/keypair/keypair_service'

		'placementgroup_service'   : 'service/aws/ec2/placementgroup/placementgroup_service'

		'securitygroup_service'    : 'service/aws/ec2/securitygroup/securitygroup_service'

		'acl_service'   : 'service/aws/vpc/acl/acl_service'

		'customergateway_service'   : 'service/aws/vpc/customergateway/customergateway_service'

		'dhcp_service'   : 'service/aws/vpc/dhcp/dhcp_service'

		'eni_service'    : 'service/aws/vpc/eni/eni_service'

		'internetgateway_service'   : 'service/aws/vpc/internetgateway/internetgateway_service'

		'routetable_service'   : 'service/aws/vpc/routetable/routetable_service'

		'subnet_service'   : 'service/aws/vpc/subnet/subnet_service'

		'vpc_service'   : 'service/aws/vpc/vpc/vpc_service'

		'vpngateway_service'   : 'service/aws/vpc/vpngateway/vpngateway_service'

		'vpn_service'   : 'service/aws/vpc/vpn/vpn_service'

		'elb_service'   : 'service/aws/elb/elb/elb_service'

		'iam_service'   : 'service/aws/iam/iam/iam_service'

		#
		'autoscaling_service' : 'service/aws/autoscaling/autoscaling/autoscaling_service'

		'cloudwatch_service'  : 'service/aws/cloudwatch/cloudwatch/cloudwatch_service'

		'sns_service'         : 'service/aws/sns/sns/sns_service'


	shim               :

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

		'MC'           :
			deps       : [ 'jquery' ]
			exports    : 'MC'

		'MC.template'  :
			deps       : [ 'handlebars', 'MC' ]
			exports    : 'MC.template'

		'MC.ide.template'  :
			deps       : [ 'MC', 'jquery', 'underscore' ]

		'UI.tabbar'    :
			deps       : [ 'MC.template' ]

		'UI.bubble'    :
			deps       : [ 'MC.template' ]

		'UI.modal'     :
			deps       : [ 'MC.template' ]

		'Meteor'       :
			deps       : ['underscore']
			exports    : 'Meteor'

		'WS'           :
			deps       : ['Meteor', 'underscore']
			exports    : 'WS'

		'MC.canvas':
			deps: [ 'MC', 'canvon' ]

		'MC.canvas.constant':
			deps: [ 'MC.canvas' ]

		'MC.canvas.add':
			deps: [ 'MC.canvas.constant']

		'canvas_layout':
			deps: [ 'MC.canvas', 'MC.canvas.add', 'MC.canvas.constant', 'canvon' ]

}

#requirejs.onError = ( err ) ->
#    console.log 'error type:', err.requireType, ', modules:', err.requireModules, ', error:', err
