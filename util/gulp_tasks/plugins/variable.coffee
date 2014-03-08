
# Replace #{variable}, if variable can be found in GLOBAL.gulpConfig
# This should be pipe right after include.coffee

es = require("event-stream")

stringType = typeof ""

ReplaceRegex = /#{(.+?)}/g

ReplaceFunc = ( match, p1 )->
  if GLOBAL.gulpConfig.hasOwnProperty p1
    return GLOBAL.gulpConfig[ p1 ]
  else
    return match

module.exports = ()->
  es.through ( f )->
    if typeof( f.strings ) is stringType
      f.contents = new Buffer( f.strings.replace ReplaceRegex, ReplaceFunc )
      f.strings  = null

    @emit "data", f
