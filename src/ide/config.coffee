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

	### env:dev ###
	paths       :

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
		'Design'        : 'workspaces/editor/framework/Design'
		'CanvasManager' : 'workspaces/editor/framework/canvasview/CanvasManager'

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

		#############################################
		# component                 # Merge in deploy
		#############################################
		'validation'       : 'component/trustedadvisor/validation'
		'kp_dropdown'      : 'component/kp/kpDropdown'
		'kp_manage'        : 'component/kp/kpManage'
		'kp_upload'        : 'component/kp/kpUpload'
		'sns_dropdown'     : 'component/sns/snsDropdown'
		'sns_manage'       : 'component/sns/snsManage'
		'combo_dropdown'   : 'component/common/comboDropdown'
		'toolbar_modal'    : 'component/common/toolbarModal'
		'dhcp'             : 'component/dhcp/dhcp'
		'snapshotManager'  : 'component/snapshot/snapshot'
		'sslcert_manage'   : 'component/sslcert/sslCertManage'
		'sslcert_dropdown' : 'component/sslcert/sslCertDropdown'
		'state_status'     : 'component/statestatus/main'
		"ThumbnailUtil"    : "component/exporter/Thumbnail"
		"JsonExporter"     : "component/exporter/JsonExporter"

	### env:dev:end ###
	shim :
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
		"api/api" : ["ApiRequest"]
		"service/service" : [
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

		"component/Exporter"                : [ "ThumbnailUtil", "JsonExporter" ]
		"component/Validation"              : [ "validation", "component/trustedadvisor/main" ]
		"component/StateStatus"             : ["state_status"]
		"component/sgrule/SGRulePopup"      : []
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

		"ide/cloudres/CrBundle"  : [ "CloudResources" ]
		"ide/Application" : [ "Workspace", "OpsModel" ]

		"workspaces/Dashboard" : []

		"workspaces/editor/PropertyPanel" : [ "workspaces/editor/subviews/PropertyPanel" ]
		"workspaces/editor/framework/DesignBundle" : [ "Design", "CanvasManager" ]
		"workspaces/OpsEditor" : []

	bundleExcludes : # This is a none requirejs option, but it's used by compiler to exclude some of the source.
		"component/sgrule/SGRulePopup" : [ "Design" ]
		"component/stateeditor/stateeditor" : ["Design"]
		"component/sharedrescomp"  : [ "Design" ]
		"component/Validation" : ["Design"]

		"workspaces/editor/PropertyPanel" : [ "Design" ]
		"workspaces/editor/framework/DesignBundle" : []
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


require [
	'ide/Application'
	"ide/cloudres/CrBundle"
	"workspaces/Dashboard"
	"workspaces/OpsEditor"
	"MC"
	'lib/aws'
], (  Application, CrBundle, Dashboard, OpsEditor ) ->

	# There's an issue of requirejs dependency. In order to avoid that, we need to export OpsEditor as an Global Object.
	window.OpsEditor = OpsEditor
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
