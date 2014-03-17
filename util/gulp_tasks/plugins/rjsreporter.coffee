
path  = require("path")
gutil = require("gulp-util")

# Files in IgnoreCheckPath can be merged to everywhere
IgnoreCheckPath =
  "ui/MC.template.js" : true

PathTransform =
  "service/" : "model/"
  "js/" : "lib/"

ExcludeRjsPluginRegex = /^[^/!]+!/

transformedPath = ( p )->
  p = p.replace ExcludeRjsPluginRegex, ""
  for key, value of PathTransform
    if p.indexOf(key) is 0
      return p.replace key, value
  p

module.exports = ( info )->
  info = info.replace(/\r\n/g, "\n").replace(/\\/g, "/") #"

  if info[0] is "\n"
    info = info.replace "\n", ""

  info = info.split "\n\n"

  duplicateTest     = {}
  hasDuplicate      = false
  hasInvalidInclude = false

  for item, idx in info
    item = item.split("\n----------------\n")
    target = path.dirname(item[0]) + "/"
    if idx > 0 then console.log ""
    console.log gutil.colors.green(target) + item[0].replace(target,"")
    console.log "----------------"

    for source in item[1].split "\n"
      message = ""

      if duplicateTest[ source ]
        hasDuplicate = true
        message = gutil.colors.bgRed.white("Duplicated") + " "
      duplicateTest[ source ] = true

      if IgnoreCheckPath[ source ]
        message += source
      else
        s = transformedPath( source )
        if s.indexOf( target ) is 0
          res = s.replace( target, "" )
          message += gutil.colors.green(source.replace(res,"")) + res
        else
          hasInvalidInclude = true
          message += gutil.colors.bgRed.white("Invalid") + " " + source

      console.log message

  not (hasDuplicate or hasInvalidInclude)
