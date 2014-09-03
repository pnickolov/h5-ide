(()->

  # When deploying, node will load this file to get the requirejs config
  # In such case, window is undefined.
  if not window then return

  location = window.location

  if /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/.exec( location.hostname )
    # This is a ip address
    console.error "VisualOps IDE can not be browsed with IP address."
    return

  hosts = location.hostname.split(".")
  if hosts.length >= 3
    window.MC_DOMAIN = hosts[ hosts.length - 2 ] + "." + hosts[ hosts.length - 1]
  else
    window.MC_DOMAIN = location.hostname

  window.MC_API_HOST = location.protocol + "//api." + window.MC_DOMAIN


  # Redirect
  window.language = window.version = ""
  if location.hostname.toLowerCase().indexOf( "visualops.io" ) >= 0 and location.protocol is "http:"
    window.location = location.href.replace("http:","https:")
    return

  # Check if there're missing cookie
  getCookie = (sKey)-> decodeURIComponent(document.cookie.replace(new RegExp("(?:(?:^|.*;)\\s*" + encodeURIComponent(sKey).replace(/[\-\.\+\*]/g, "\\$&") + "\\s*\\=\\s*([^;]*).*$)|^.*$"), "$1")) || null

  if not (getCookie('usercode') and getCookie('session_id'))
    p = window.location.pathname
    if p is "/"
      p = window.location.hash.replace("#", "/")
    if p and p isnt "/"
      window.location.href = "/login?ref=" + p
    else
      window.location.href = "/login"
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

  baseUrl     : '/'
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
    'underscore'         : 'vender/underscore/underscore'
    'backbone'           : 'vender/backbone/backbone'
    'handlebars'         : 'vender/handlebars/handlebars.rt'
    'sprintf'            : 'vender/sprintf/sprintf'
    'Meteor'             : 'vender/meteor/meteor'
    'crypto'             : 'vender/crypto-js/cryptobundle'
    'q'                  : 'vender/q/q'
    "svg"                : 'vender/svgjs/svg'

    #############################################
    # MC                        # Merge in deploy
    #############################################
    'MC'                 : 'js/MC.core'
    'MC.validate'        : 'js/MC.validate'
    'MC.canvas'          : 'js/MC.canvas'
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
    'UI.dnd'             : 'ui/UI.dnd'
    'UI.nanoscroller'    : 'ui/UI.nanoscroller'
    'jqpagination'       : 'ui/jqpagination'
    "jquerysort"         : 'ui/jquery.sort'
    'jqtimepicker'       : 'ui/jquery.timepicker'
    'jqdatetimepicker'   : 'ui/jquery.datetimepicker'
    'UI.modalplus'       : 'ui/UI.modalplus'

    #############################################
    # cloud resources           # Merge in deploy
    #############################################
    "CloudResources"     : "cloudres/CloudResources"

    #############################################
    # api                       # Merge in deploy
    #############################################
    'ApiRequest'      : 'api/ApiRequest'
    'ApiRequestDefs'  : 'api/ApiRequestDefs'
    "ApiRequestR"     : "api/ApiRequestR"
    "ApiRequestRDefs" : "api/ApiRequestRDefs"

    #############################################
    # ide                       # Merge in deploy
    #############################################
    "OpsModel"  : "ide/submodels/OpsModel"
    "Workspace" : "ide/Workspace"

    #############################################
    # coreeditor                # Merge in deploy
    #############################################
    "OpsEditor"        : "workspaces/OpsEditor"
    'Design'           : 'workspaces/coreeditor/Design'
    "ResourceModel"    : "workspaces/coreeditor/ModelResource"
    "ComplexResModel"  : "workspaces/coreeditor/ModelComplex"
    "ConnectionModel"  : "workspaces/coreeditor/ModelConnection"
    "GroupModel"       : "workspaces/coreeditor/ModelGroup"
    "CoreEditor"       : "workspaces/coreeditor/EditorCore"
    "CoreEditorView"   : "workspaces/coreeditor/EditorView"
    "ProgressViewer"   : "workspaces/coreeditor/ProgressViewer"
    "CanvasElement"    : "workspaces/coreeditor/CanvasElement"
    "CanvasLine"       : "workspaces/coreeditor/CanvasLine"
    "CanvasView"       : "workspaces/coreeditor/CanvasView"
    "CanvasViewLayout" : "workspaces/coreeditor/CanvasViewLayout"
    "CanvasManager"    : "workspaces/coreeditor/CanvasManager"
    "CanvasPopup"      : "workspaces/coreeditor/CanvasPopup"

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

    'validation'       : 'component/trustedadvisor/exposure'
    'TaHelper'       : 'component/trustedadvisor/lib/TA.Helper'
    'kp_dropdown'      : 'component/kp/kpDropdown'
    'kp_manage'        : 'component/kp/kpManage'
    'kp_upload'        : 'component/kp/kpUpload'
    'sns_dropdown'     : 'component/sns/snsDropdown'
    'sns_manage'       : 'component/sns/snsManage'
    'combo_dropdown'   : 'component/common/comboDropdown'
    'toolbar_modal'    : 'component/common/toolbarModal'
    'dhcp'             : 'component/dhcp/dhcp'
    'appAction'        : 'component/AppAction/AppAction'
    'snapshotManager'  : 'component/snapshot/snapshot'
    'rds_pg'           : 'component/rds_pg/rds_pg'
    'rds_snapshot'     : 'component/rds_snapshot/rds_snapshot'
    'sslcert_manage'   : 'component/sslcert/sslCertManage'
    'sslcert_dropdown' : 'component/sslcert/sslCertDropdown'
    'state_status'     : 'component/statestatus/main'
    "ThumbnailUtil"    : "component/exporter/Thumbnail"
    "JsonExporter"     : "component/exporter/JsonExporter"
    "ResDiff"          : "component/common/diff/ResDiff"
    "DiffTree"         : "component/common/diff/DiffTree"
    'og_manage'        : 'component/optiongroup/ogManage'
    'og_manage_app'    : 'component/optiongroup/ogManageApp'
    'og_dropdown'      : 'component/optiongroup/ogDropDown'

  ### env:dev:end ###
  shim :
    'underscore'   :
      exports    : '_'

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
      "crypto"
      "q"
      "svg"
    ]
    "lib/lib" : [
      "MC"
      "constant"
      "MC.canvas"
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
      'UI.dnd'
      "jqpagination"
      'jquerysort'
      "jqtimepicker"
      "jqdatetimepicker"
      "UI.modalplus"
      "UI.nanoscroller"
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
    "component/Validation"              : [ "validation", "component/trustedadvisor/gui/main" ]
    "component/StateStatus"             : [ "state_status" ]
    "component/AwsDialog"               : [ "component/sgrule/SGRulePopup", "component/dbsbgroup/DbSubnetGPopup", "appAction", 'og_manage', 'og_manage_app', 'og_dropdown' ]
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
      'ResDiff'
      'DiffTree'
      "rds_pg"
      "rds_snapshot"
    ]

    "cloudres/CrBundle"  : [ "CloudResources" ]
    "ide/AppBundle" : [ "ide/Application", "Workspace", "OpsModel", "ide/Router" ]

    "workspaces/Dashboard" : []

    "workspaces/editor/PropertyPanel" : [ "workspaces/editor/subviews/PropertyPanel" ]
    "workspaces/editor/framework/DesignBundle" : [ "Design" ]
    "workspaces/OpsEditor" : []

  bundleExcludes : # This is a none requirejs option, but it's used by compiler to exclude some of the source.
    "component/AwsDialog" : [ "Design" ]
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
  "cloudres/CrBundle"
  "workspaces/Dashboard"
  "ide/Router"
  "MC"
  "MC.canvas"
  'lib/aws'
  "workspaces/AwsEditor"
], ( Application, CrBundle, Dashboard, Router ) ->

  ###########
  # IDE Init
  ###########
  # There's an issue of requirejs dependency. In order to avoid that, we need to export OpsEditor as an Global Object.
  window.Router    = new Router()
  (new Application()).initialize().then ()->
    window.Router.start()
    window.Dashboard = new Dashboard()
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
