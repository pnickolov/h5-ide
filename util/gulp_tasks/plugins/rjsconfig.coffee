
fs = require("fs")
vm = require("vm")

ConfigFile = "./build/js/ide/config.js"

DefaultConfig =
  baseUrl        : "./build"
  dir            : "./build2"
  removeCombined : true


readRequirejsConfig = ( path )->
  source = fs.readFileSync path, "utf8"

  Context =
    version  : ""
    language : ""
    window   : {}
    require : ()->
    document :
      getElementsByTagName : ()-> []
      cookie : ""


  Context.require.config = ( config )->
    this.config = config
    null

  Context = vm.createContext( Context )
  vm.runInContext( source, Context )

  Context.require.config


extend = ( a, b )->
  for i of b
    a[i] = b[i]
  a

transformModules = ( config )->
  # Transform the bundles
  exclude = [] # i18n!nls/lang.js must have a suffix `.js`, otherwise, it will have error when compiling. And we always exclude the lang from anything.

  config.modules = []
  bundleExcludes = config.bundleExcludes || {}
  for bundleName, bundles of config.bundles

    config.modules.push {
      name    : bundleName
      create  : !!bundles.length
      include : bundles
      exclude : exclude.concat( bundleExcludes[bundleName] || [] )
    }

    # We assume the first bundle is "requirelib", and "requirelib" cannot have "i18n!xxx" excluded.
    if exclude.length == 0
      exclude.push "i18n!nls/lang.js"

    exclude.push bundleName

  delete config.bundles
  config

getConfig = ()->

  if debugMode is undefined then debugMode = true

  if debugMode
    extra =
      optimize        : "none"
      optimizeCss     : "none"
      skipDirOptimize : true
  else
    extra = {}

  config = extend( extra, DefaultConfig )

  config = extend( readRequirejsConfig( ConfigFile ), config )

  # Read the config. Transform the bundles to modules
  transformModules( config )

  ###
  # Example of the modules definination
  config.modules = [
    {
      name    : "vender/vender"
      create  : true
      include : [ "jquery", "underscore", "backbone", "handlebars", "Meteor" ]
    }

    {
      name   : "ui/ui"
      create : true
      include : ["UI.tooltip","UI.scrollbar","UI.tabbar","UI.bubble","UI.modal","UI.table","UI.tablist","UI.selectbox","UI.searchbar","UI.filter","UI.radiobuttons","UI.notification","UI.multiinputbox","UI.canvg","UI.sortable","UI.parsley","UI.errortip"]
      exclude : [ "vender/vender" ]
    }
  ]
  ###

  config

module.exports = getConfig
