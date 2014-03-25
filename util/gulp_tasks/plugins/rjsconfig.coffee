
fs     = require("fs")
vm     = require("vm")
es     = require("event-stream")
coffee = require("gulp-coffee")

ConfigFile = "./src/js/ide/config.coffee"

readRequirejsConfig = ( path )->

  # We should compile the config.coffee without conditionalCompiler
  # instead of reading the compiled config.js
  s = fs.readFileSync path

  pipeline = es.through ()-> null

  pipeline.pipe(coffee()).pipe es.through ( f )-> s = f.contents.toString("utf8");null

  pipeline.emit "data", {
    path     : path
    contents : s
    isNull   : ()-> false
    isStream : ()-> false
  }


  Context =
    version  : ""
    language : ""
    require  : ()-> return

  Context.require.config = ( config )->
    this.config = config
    null

  Context = vm.createContext( Context )
  vm.runInContext( s, Context )

  Context.require.config


extend = ( a )->
  for arg, idx in arguments
    if idx is 0 then continue
    for i of arg
      a[i] = arg[i]
  a

transformModules = ( config )->
  # Transform the bundles
  exclude = [] # i18n!nls/lang.js must have a suffix `.js`, otherwise, it will have error when compiling. And we always exclude the lang from anything.

  config.modules = []
  bundleExcludes = config.bundleExcludes || {}
  for bundleName, bundles of config.bundles

    config.modules.push {
      name    : bundleName
      include : bundles
      exclude : exclude.concat( bundleExcludes[bundleName] || [] )
    }

    # We assume the first bundle is "requirelib", and "requirelib" cannot have "i18n!xxx" excluded.
    if exclude.length == 0
      exclude.push "i18n!nls/lang.js"

    exclude.push bundleName

  delete config.bundles
  config

getConfig = ( debugMode = true, outputPath = "./deploy" )->
  if debugMode is true
    extra =
      optimize        : "none"
      optimizeCss     : "none"
      skipDirOptimize : true
  else
    extra =
      optimizeCss : "standard"

  config = extend( readRequirejsConfig( ConfigFile ), extra, {
    removeCombined : true
    baseUrl : "./build"
    dir     : outputPath
  } )

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
