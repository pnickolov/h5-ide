(()->
	# Redirect
	l = window.location
	if l.protocol is "http:" and not l.port
		window.location = l.href.replace("http:","https:")
		return

	# Get Version and locale
	scripts = document.getElementsByTagName("script")
	for s in scripts
		version = s.getAttribute("data-main")
		if version
			window.version = version.split("?")[1]
			break
	if window.version is '#{version}' then window.version = "dev"

	window.language = document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + "lang\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1") || "en-us"
	null
)()

require.config {

	baseUrl : './'
	locale  : language
	urlArgs : "v=#{version}"
	paths   :

		### env:dev ###
		#############################################
		# Requirejs lib             # Merge in deploy
		#############################################
		'domReady'           : 'vender/requirejs/domReady'
		'text'               : 'vender/requirejs/text'
		'i18n'               : 'vender/requirejs/i18n'

		#############################################
		# vender                    # Merge in deploy
		#############################################
		'jquery'             : 'vender/jquery/jquery'
		'canvon'             : 'vender/canvon/canvon'

		'underscore'         : 'vender/underscore/underscore'
		'backbone'           : 'vender/backbone/backbone'
		'handlebars'         : 'vender/handlebars/handlebars'

		'sprintf'            : 'vender/sprintf/sprintf'
		'Meteor'             : 'vender/meteor/meteor'

		#############################################
		# MC                        # Merge in deploy
		#############################################
		'MC'                 : 'js/MC.core'
		'MC.validate'        : 'js/MC.validate'

		'canvas_layout'      : 'js/canvas_layout'
		'MC.canvas'          : 'js/MC.canvas'

		'MC.canvas.constant' : 'js/MC.canvas.constant'
		'constant'           : 'lib/constant'

		'event'              : 'lib/ide_event'

		'WS'                 : 'lib/websocket'

		#############################################
		# ui/                       # Merge in deploy
		#############################################
		'UI.tooltip'         : 'ui/UI.tooltip'
		'UI.scrollbar'       : 'ui/UI.scrollbar'
		'UI.tabbar'          : 'ui/UI.tabbar'
		'UI.bubble'          : 'ui/UI.bubble'
		'UI.modal'           : 'ui/UI.modal'
		'UI.table'           : 'ui/UI.table'
		'UI.tablist'         : 'ui/UI.tablist'
		'UI.selectbox'       : 'ui/UI.selectbox'
		'UI.searchbar'       : 'ui/UI.searchbar'
		'UI.filter'          : 'ui/UI.filter'
		'UI.radiobuttons'    : 'ui/UI.radiobuttons'
		'UI.notification'    : 'ui/UI.notification'
		'UI.multiinputbox'   : 'ui/UI.multiinputbox'
		'UI.canvg'           : 'ui/UI.canvg'
		'UI.sortable'        : 'ui/jquery.sortable'
		'UI.parsley'         : 'ui/UI.parsley'
		'UI.errortip'        : 'ui/UI.errortip'
		'hoverIntent'        : 'ui/jquery.hoverIntent'
		'bootstrap-carousel' : 'ui/bootstrap-carousel'
		'jqpagination'       : 'ui/jqpagination'


		#############################################
		# design model              # Merge in deploy
		#############################################
		'Design'             : 'module/design/framework/Design'
		'CanvasManager'      : 'module/design/framework/canvasview/CanvasManager'

		#############################################
		# model                     # Merge in deploy
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
		# service                   # Merge in deploy
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

		### env:dev:end ###



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
		# lib/aws logic handler
		#############################################
		'aws_handle'         : 'lib/aws/main'
		'forge_handle'       : 'lib/forge/main'
		'common_handle'       : 'lib/common/main'

		#
		'validation'         : 'component/trustedadvisor/validation'
		'ta_conf'            : 'component/trustedadvisor/config'

		#statusbar state
		'state_status'       : 'component/statestatus/main'

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

	shim               :

		#############################################
		# vender
		#############################################

		'canvon'       :
			deps       : [ 'jquery' ]
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

		'MC.canvas'    :
			deps       : [ 'MC', 'canvon' ]

		#############################################
		# UI
		#############################################

		'UI.tabbar'    :
			deps       : [ 'jquery' ]

		'UI.bubble'    :
			deps       : [ 'jquery' ]

		'UI.modal'     :
			deps       : [ 'jquery' ]

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
			deps     : [ 'jquery' ]

		#############################################
		# WS
		#############################################

		'Meteor'       :
			deps       : ['underscore']
			exports    : 'Meteor'

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

	### env:prod ###
	# The rule of bundles is that, if an ID defined above is ever included in a bundle
	# Then that ID should appear in the bundle's array.
	bundles :
		"vender/requirejs/requirelib" : [ "domReady", "i18n", "text" ] # requirelib must be the first one.
		"vender/vender" : [
			"jquery"
			"backbone"
			"underscore"
			"handlebars"
			"sprintf"
			"Meteor"
			"canvon"
		]
		"lib/lib" : [
			"MC"
			"constant"
			"MC.canvas"
			"MC.canvas.constant"
			'MC.validate'
			"canvas_layout"
			"lib/handlebarhelpers"
			"event"
			"WS"
		]
		"common_handle" : []
		"ui/ui" : [
			'UI.tooltip'
			'UI.scrollbar'
			'UI.tabbar'
			'UI.bubble'
			'UI.modal'
			'UI.table'
			'UI.tablist'
			'UI.selectbox'
			'UI.searchbar'
			'UI.filter'
			'UI.radiobuttons'
			'UI.notification'
			'UI.multiinputbox'
			'UI.canvg'
			'UI.sortable'
			'UI.parsley'
			'UI.errortip'
			"jqpagination"
			'hoverIntent'
			'bootstrap-carousel'
		]
		"model/model" : [
			'base_model'
			'account_model'
			'session_model'
			'favorite_model'
			'app_model'
			'stack_model'
			'state_model'
			'ec2_model'
			'vpc_model'
			'aws_model'
			'ami_model'
			'ebs_model'
			'elb_model'
			'dhcp_model'
			'customergateway_model'
			'vpngateway_model'
			'keypair_model'
			'autoscaling_model'
			'cloudwatch_model'
			'sns_model'
			'subnet_model'
			'instance_model'
			'result_vo'
			'favorite_service'
			'session_service'
			'account_service'
			'app_service'
			'stack_service'
			'aws_service'
			'state_service'
			'ami_service'
			'ebs_service'
			'ec2_service'
			'eip_service'
			'instance_service'
			'keypair_service'
			'placementgroup_service'
			'securitygroup_service'
			'acl_service'
			'customergateway_service'
			'dhcp_service'
			'eni_service'
			'internetgateway_service'
			'routetable_service'
			'subnet_service'
			'vpc_service'
			'vpngateway_service'
			'vpn_service'
			'elb_service'
			'iam_service'
			'autoscaling_service'
			'cloudwatch_service'
			'sns_service'
		]
		"component/sgrule/SGRulePopup" : []
		"module/design/framework/DesignBundle" : [ "Design", "CanvasManager" ]
	bundleExcludes : # This is a none requirejs option, but it's used by compiler to exclude some of the source.
		"component/sgrule/SGRulePopup" : [ "Design" ]
		"module/design/framework/DesignBundle" : [ "component/sgrule/SGRulePopup" ]

	### env:prod:end ###
}

require ['./js/ide/ide' ], ( ide ) ->
	$ ()-> ide.initialize()
	null
