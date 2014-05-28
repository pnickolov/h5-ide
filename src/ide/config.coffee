(()->

  # When deploying, node will load this file to get the requirejs config
  # In such case, window is undefined.
  if not window then return

  # Release : https://ide && https://api
  # Debug   : http://ide  && https://ide
  # Dev     : http://ide  && https://ide
  # Public  : http://ide  && http://ide

  # Set domain and set http
  window.MC_DOMAIN = "visualops.io"
  window.MC_PROTO  = "http"
  shouldIdeHttps   = false
  ideHttps         = true

  ### env:debug ###
  window.MC_DOMAIN = "mc3.io"
  ideHttps = false
  ### env:debug:end ###

  ### env:dev ###
  window.MC_DOMAIN = "mc3.io"
  ideHttps = false
  ### env:dev:end ###

  ### AHACKFORRELEASINGPUBLICVERSION ###
  # AHACKFORRELEASINGPUBLICVERSION is a hack. The block will be removed in Public Version.
  # Only js/ide/config and user/main supports it.
  shouldIdeHttps  = ideHttps
  window.MC_PROTO = "https"
  ### AHACKFORRELEASINGPUBLICVERSION ###

  # Redirect
  l = window.location
  window.language = window.version = ""
  if shouldIdeHttps and l.protocol is "http:"
    window.location = l.href.replace("http:","https:")
    return

  # Check if there're missing cookie
  getCookie = (sKey)-> decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null

  if not (getCookie('usercode') and getCookie('session_id'))
  	window.location.href = "/login/"
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

	baseUrl     : './'
	waitSeconds : 30
	locale      : language
	urlArgs     : "v=#{version}"
	paths       :

		### env:dev ###
		#############################################
		# Requirejs lib             # Merge in deploy
		#############################################
		'i18n'               : 'vender/requirejs/i18n'

		#############################################
		# vender                    # Merge in deploy
		#############################################
		'jquery'             : 'vender/jquery/jquery'
		'canvon'             : 'vender/canvon/canvon'

		'underscore'         : 'vender/underscore/underscore'
		'backbone'           : 'vender/backbone/backbone'
		'handlebars'         : 'vender/handlebars/handlebars.rt'

		'sprintf'            : 'vender/sprintf/sprintf'
		'Meteor'             : 'vender/meteor/meteor'
		'crypto'             : 'vender/crypto-js/cryptobundle'
		'q'                  : 'vender/q/q'
		'select2'			 : 'vender/select2/select2.min'

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

		#############################################
		# lib                       # Merge in deploy
		#############################################
		'aws_handle'         : 'lib/aws/main'
		'forge_handle'       : 'lib/forge/main'
		'common_handle'      : 'lib/common/main'

		#############################################
		# ui/                       # Merge in deploy
		#############################################
		'UI.tooltip'         : 'ui/UI.tooltip'
		'UI.scrollbar'       : 'ui/UI.scrollbar'
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
		'UI.tour'            : 'ui/UI.tour'
		'jqpagination'       : 'ui/jqpagination'
		"jquerysort"         : 'ui/jquery.sort'
		'UI.modalplus'       : 'ui/UI.modalplus'

		#############################################
		# cloud resources           # Merge in deploy
		#############################################
		"CloudResources"     : "ide/cloudres/CloudResources"


		#############################################
		# design model              # Merge in deploy
		#############################################
		'Design'             : 'module/design/framework/Design'
		'CanvasManager'      : 'module/design/framework/canvasview/CanvasManager'

		#############################################
		# model                     # Merge in deploy
		#############################################
		'base_model'             : 'model/base_model'

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
		# component                 # Merge in deploy
		#############################################
		'validation'         : 'component/trustedadvisor/validation'


		#############################################
		# api                       # Merge in deploy
		#############################################
		'ApiRequest'     : 'api/ApiRequest'
		'ApiRequestDefs' : 'api/ApiRequestDefs'


		#############################################
		# ide                       # Merge in deploy
		#############################################
		"OpsModel"  : "ide/submodels/OpsModel"
		"Workspace" : "ide/Workspace"


		#############################################
		# module
		#############################################
		'base_main'          : 'module/base/base_main'

		# 'navigation'         : 'module/navigation/main'
		# 'navigation_view'    : 'module/navigation/view'
		# 'navigation_model'   : 'module/navigation/model'

		# 'tabbar'             : 'module/tabbar/main'
		# 'tabbar_view'        : 'module/tabbar/view'
		# 'tabbar_model'       : 'module/tabbar/model'

		# 'dashboard'          : 'module/dashboard/main'
		# 'dashboard_view'     : 'module/dashboard/view'
		# 'dashboard_model'    : 'module/dashboard/model'

		# 'process'            : 'module/process/main'
		# 'process_view'       : 'module/process/view'
		# 'process_model'      : 'module/process/model'

		'design_module'      : 'module/design/main'
		'design_view'        : 'module/design/view'
		'design_model'       : 'module/design/model'

		#sub module with design
		'resource'           : 'module/design/resource/main'
		'property'           : 'module/design/property/property'
		'canvas'             : 'module/design/canvas/main'
		'toolbar'            : 'module/design/toolbar/main'

		#statusbar state
		'state_status'       : 'component/statestatus/main'
		'kp'                 : 'component/kp/kpMain'
		'kp_upload'          : 'component/kp/kpUpload'
		'sns_dropdown'       : 'component/sns/snsDropdown'
		'sns_manage'		 : 'component/sns/snsManage'
		'combo_dropdown'     : 'component/common/comboDropdown'
		'toolbar_modal'      : 'component/common/toolbarModal'
		'dhcp'               : 'component/dhcp/dhcpMain'

		#############################################
		# component
		#############################################

		'unmanagedvpc'       : 'component/unmanagedvpc/main'
		'unmanagedvpc_view'  : 'component/unmanagedvpc/view'
		'unmanagedvpc_model' : 'component/unmanagedvpc/model'

	shim               :

		#############################################
		# vender
		#############################################

		'canvon'       :
			deps       : [ 'jquery' ]
			exports    : 'Canvon'

		'underscore'   :
			exports    : '_'

		'handlebars'   :
			exports    : 'Handlebars'

		'Meteor'       :
			deps       : ['underscore']
			exports    : 'Meteor'

		#############################################
		# modules
		#############################################

		'navigation'   :
			deps       : [ 'navigation_view', 'navigation_model', 'MC' ]

		'process'      :
			deps       : [ 'process_view', 'process_model', 'MC' ]

		'select2'	   :
			deps 	   : [ 'jquery' ]
			exports    : "$"

	### env:prod ###
	# The rule of bundles is that, if an ID defined above is ever included in a bundle
	# Then that ID should appear in the bundle's array.
	bundles :
		"vender/requirejs/requirelib" : [ "i18n" ] # requirelib must be the first one.
		"vender/vender" : [
			"jquery"
			"backbone"
			"underscore"
			"handlebars"
			"sprintf"
			"Meteor"
			"canvon"
			"crypto"
			"q"
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
		]
		"lib/deprecated" : [
			'aws_handle'
			'forge_handle'
			'common_handle'
		]
		"ui/ui" : [
			'UI.tooltip'
			'UI.scrollbar'
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
			'UI.tour'
			"jqpagination"
			'jquerysort'
			"UI.modalplus"
		]
		"ApiRequest" : []
		"model/model" : [
			'base_model'
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
		"component/exporter/Exporter"  : [ "component/exporter/Download", "component/exporter/Thumbnail", "component/exporter/JsonExporter" ]
		"ide/cloudres/CrBundle"  : ["CloudResources"]
		"ide/Application" : [ "Workspace" ]
		'combo_dropdown'  : ["toolbar_modal"]
		"kp" : ["kp_upload"]
		"module/design/framework/DesignBundle" : [ "Design", "CanvasManager" ]
		"validation" : []
		"component/stateeditor/stateeditor" : []
		"property" : []

	bundleExcludes : # This is a none requirejs option, but it's used by compiler to exclude some of the source.
		"lib/deprecated" : ["Design"]
		"component/sgrule/SGRulePopup" : [ "Design" ]
		"kp" : ["Design"]
		"component/stateeditor/stateeditor" : [
			"component/stateeditor/lib/ace"
			"component/stateeditor/lib/markdown"
		]
		"module/design/framework/DesignBundle" : [ "component/sgrule/SGRulePopup" ]
		"property" : [ "component/sgrule/SGRulePopup" ]

	### env:prod:end ###
}

requirejs.onError = ( err )->
	# Because there are so many **WRONG USAGE** of require()
	# We can only try reloading the dependency if timeout
	err = err || { requireType : "timeout" }
	if err.requireType is "timeout"
		for i in err.requireModules || []
			requirejs.undef i

		require err.requireModules || [], ()->
	else
		console.error "[RequireJS Error]", err, err.stack


require ['ide/Application', 'ide/deprecated/ide', "ide/cloudres/CrBundle", "workspaces/Dashboard"], ( Application, ide, bundle, Dashboard ) ->
	(new Application()).initialize().then ()->
		ide.initialize()
		new Dashboard()
	return
, ( err )->
	err = err || { requireType : "timeout" }
	if err.requireType is "timeout"
		requirejs.onError = ()-> # Just use to suppress subsequent error
		console.error "[RequireJS timeout] Reloading, error modules :", err.requireModules
		window.location.reload()
	else
		console.error "[RequireJS Error]", err, err.stack
		# requirejs.onError = ()-> # Just use to suppress subsequent error
		# console.error "[Script Error] Redirecting to 500, error modules :", err.requireModules
		# window.location = "/500"
	return
