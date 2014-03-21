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
  baseUrl     : './'
  waitSeconds : 30
  locale      : language
  urlArgs     : 'v=' + version

  paths :

    #vender
    'jquery'     : 'vender/jquery/jquery.1.0'
    'underscore' : 'vender/underscore/underscore'
    'backbone'   : 'vender/backbone/backbone'
    'handlebars' : 'vender/handlebars/handlebars'

    'domReady' : 'vender/requirejs/domReady'
    'i18n'     : 'vender/requirejs/i18n'
    'text'     : 'vender/requirejs/text'

    'sprintf'            : 'vender/sprintf/sprintf'

    'crypto'             : 'vender/crypto-js/hmac-sha256'
    'MC'                 : 'js/MC.core'
    'constant'           : 'lib/constant'
    'common_handle'      : 'lib/common/main'
    'event'              : 'lib/ide_event'
    'MC.canvas.constant' : 'lib/MC.canvas.constant'

    'base_main'       : 'module/base/base_main'
    'base_model'      : 'model/base_model'
    'result_vo'       : 'service/result_vo'
    'session_model'   : 'model/session_model'
    'session_service' : 'service/session/session_service'
    'account_model'   : 'model/account_model'
    'account_service' : 'service/account/account_service'


    'UI.notification' : 'ui/UI.notification'

  shim                  :

    'underscore'      :
      exports       : '_'

    'backbone'        :
      deps          : [ 'underscore', 'jquery' ]
      exports       : 'Backbone'

    'handlebars'      :
      exports       : 'Handlebars'

    'MC'              :
      deps          : [ 'jquery', 'constant' ]
      exports       : 'MC'

  ### env:prod ###
  # The bundles is a subset of the one defined in "js/ide/config"
  # The bundle doesn't have to excately be the same as in "js/ide/config"
  bundles :
    "vender/requirejs/requirelib" : [ "domReady", "i18n", "text" ] # requirelib must be the first one.
    "vender/vender" : [
      "jquery"
      "backbone"
      "underscore"
      "handlebars"
      "sprintf"
    ]
    "lib/lib" : [
      "MC"
      "constant"
      "MC.canvas.constant"
      "event"
    ]
    "ui/ui" : [ 'UI.notification' ]
    "model/model" : [
      'base_model'
      'account_model'
      'session_model'
      'session_service'
      'account_service'
      "result_vo"
    ]
  ### env:prod:end ###
}

# Load Corresponding Page
# HandlebarHelpers
require [ "MC", "i18n!nls/lang.js", "jquery" ], ( MC, lang ) ->

  $ ()->
    if MC.isSupport() == false
      $(document.body).prepend '<div id="unsupported-browser"><p>MadeiraCloud IDE does not support the browser you are using.</p> <p>For a better experience, we suggest you use the latest version of <a href=" https://www.google.com/intl/en/chrome/browser/" target="_blank">Chrome</a>, <a href=" http://www.mozilla.org/en-US/firefox/all/" target="_blank">Firefox</a> or <a href=" http://windows.microsoft.com/en-us/internet-explorer/ie-10-worldwide-languages" target="_blank">IE10</a>.</p></div>'

  entry = $("body").attr("data-entry")

  Handlebars.registerHelper 'i18n', ( text ) ->
    new Handlebars.SafeString lang[entry][ text ]

  switch entry
    when "login"
      require ["js/user/login"], (login)->
        login.ready()
        null

    when "register"
      require [ 'backbone', 'module/register/main' ], ( Backbone, register ) ->

        AppRouter = Backbone.Router.extend {
          routes :
            'success'  : 'success'
            '*actions' : 'defaultRouter'
        }

        router = new AppRouter()

        router.on 'route:defaultRouter', () ->
          register.loadModule 'normal'

        router.on 'route:success', () ->
          register.loadModule 'success'

        Backbone.history.start()
        null

    when "reset"
      require [ 'backbone', 'module/reset/main' ], ( Backbone, reset ) ->

        AppRouter = Backbone.Router.extend {
          routes :
            'email'         : 'email'
            'password/:key' : 'password'
            'expire'        : 'expire'
            'success'       : 'success'
            '*actions'      : 'defaultRouter'
        }

        router = new AppRouter()
        router.on 'route:defaultRouter', () ->
          reset.loadModule 'normal'

        router.on 'route:email', () ->
          reset.loadModule 'email'

        router.on 'route:password', ( key ) ->
          reset.loadModule 'password', key

        router.on 'route:expire', () ->
          reset.loadModule 'expire'

        router.on 'route:success', () ->
          reset.loadModule 'success'

        Backbone.history.start()
        null

