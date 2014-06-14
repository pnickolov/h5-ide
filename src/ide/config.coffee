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

		#############################################
		# MC                        # Merge in deploy
		#############################################
		'MC'                 : 'js/MC.core'
		'MC.validate'        : 'js/MC.validate'
		'MC.canvas'          : 'js/MC.canvas'
		'MC.canvas.constant' : 'js/MC.canvas.constant'
		'constant'           : 'lib/constant'
		'event'              : 'lib/ide_event'

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
		# opseditor                 # Merge in deploy
		#############################################
		'Design'             : 'workspaces/editor/framework/Design'
		'CanvasManager'      : 'workspaces/editor/framework/canvasview/CanvasManager'

		#############################################
		# deprecated service        # Merge in deploy
		#############################################
		'base_model'             : 'service/base_model'
		'state_model'            : 'service/state_model'
		'keypair_model'          : 'service/keypair_model'
		'instance_model'         : 'service/instance_model'
		'result_vo'              : 'service/result_vo'
		'stack_service'          : 'service/stack_service'
		'state_service'          : 'service/state_service'
		'ami_service'            : 'service/ami_service'
		'ebs_service'            : 'service/ebs_service'
		'instance_service'       : 'service/instance_service'
		'keypair_service'        : 'service/keypair_service'
		'customergateway_service': 'service/customergateway_service'
		### env:dev:end ###

		#############################################
		# component                 # Merge in deploy
		#############################################
		'validation'         : 'component/trustedadvisor/validation'

		# tmp will delete in 2 days
		'jsona'				 : 'component/resdiff/a'
		'jsonb'				 : 'component/resdiff/b'


		#statusbar state
		'state_status'       : 'component/statestatus/main'
		'kp_dropdown'        : 'component/kp/kpDropdown'
		'kp_manage'          : 'component/kp/kpManage'
		'kp_upload'          : 'component/kp/kpUpload'
		'sns_dropdown'       : 'component/sns/snsDropdown'
		'sns_manage'		 : 'component/sns/snsManage'
		'combo_dropdown'     : 'component/common/comboDropdown'
		'toolbar_modal'      : 'component/common/toolbarModal'
		'dhcp'               : 'component/dhcp/dhcp'
		'snapshotManager'    : 'component/snapshot/snapshot'
		'sslcert_manage'     : 'component/sslcert/sslCertManage'
		'sslcert_dropdown'     : 'component/sslcert/sslCertDropdown'

		#resource diff
		'ResDiff'            : 'component/resdiff/ResDiff'

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
			"lib/handlebarhelpers"
			"event"
		]
		"lib/aws/main" : []
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
		"service" : [
			'base_model'
			'state_model'
			'keypair_model'
			'instance_model'
			'result_vo'
			'stack_service'
			'state_service'
			'ami_service'
			'ebs_service'
			'instance_service'
			'keypair_service'
			'customergateway_service'
		]
		"component/sgrule/SGRulePopup" : []
		"component/exporter/Exporter"  : [ "component/exporter/Download", "component/exporter/Thumbnail", "component/exporter/JsonExporter" ]
		"CloudResources"  : []
		"ide/Application" : [ "Workspace", "OpsModel" ]
		"module/design/framework/DesignBundle" : [ "Design", "CanvasManager" ]
		"validation" : []
		"component/stateeditor/stateeditor" : []
		"component/sharedrescomp" : [
			'kp_dropdown'
			'kp_manage'
			'kp_upload'
			'sns_dropdown'
			'sns_manage'
			'combo_dropdown'
			'toolbar_modal'
			'dhcp'
			'snapshotManager'
			'sslcert_manage'
			'sslcert_dropdown'
		]
		"workspaces/editor/subviews/PropertyPanel" : []

	bundleExcludes : # This is a none requirejs option, but it's used by compiler to exclude some of the source.
		"lib/aws/main" : ["Design"]
		"component/sgrule/SGRulePopup" : [ "Design" ]
		"component/stateeditor/stateeditor" : [
			"component/stateeditor/lib/ace"
			"component/stateeditor/lib/markdown"
		]
		"Design"   : [ "component/sgrule/SGRulePopup" ]
		"workspaces/editor/subviews/PropertyPanel" : [ "component/sgrule/SGRulePopup" ]

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


require ["constant", 'ide/Application', "workspaces/Dashboard", "ide/cloudres/CrBundle", "MC", 'lib/aws/main'], ( constant, Application, Dashboard, CrBundle ) ->

	##########################################################
	# Deprecated Global shit. Doesn't anyone dare to add more of these. They will be removed in the future.
	MC.data = MC.data || {}

	#global config data by region
	MC.data.config = {}
	MC.data.config[r] = {} for r in constant.REGION_KEYS

	#global cache for all ami
	MC.data.dict_ami = {}

	#global resource data (Describe* return)
	MC.data.resource_list = {}
	MC.data.resource_list[r] = {} for r in constant.REGION_KEYS

	#state editor
	MC.data.state = {}

	# State clipboard
	MC.data.stateClipboard = []
	##########################################################

	(new Application()).initialize().then ()-> new Dashboard(); return

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
