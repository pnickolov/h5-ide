
path    = require("path")
es      = require("event-stream")
indexOf = require("./indexof")

delimeterMap =
  ".coffee"   : "### env ###"
  ".js"       : "/* env */"
  ".html"     : "<!-- env -->"
  ".hbs"      : "<!-- env -->"
  ".partials" : "<!-- env -->"

transform = ( file, replaceKey, delimeter )->
  s_delimeter = delimeter.replace("env", "env:#{replaceKey}")
  e_delimeter = delimeter.replace("env", "env:#{replaceKey}:end")

  buffer = file.contents
  index = 0
  found = 0
  while (index = indexOf( buffer, s_delimeter, index )) != -1
    if GLOBAL.gulpConfig.verbose then console.log "[EnvProdFound]", file.relative

    endIndex = indexOf( buffer, e_delimeter, index+s_delimeter.length )
    if endIndex == -1
      console.log "[Missing EnvProdEnd]"
      break
    else if GLOBAL.gulpConfig.verbose
      console.log "[EnvProdEndFound]", file.relative

    index    += s_delimeter.length - 3
    endIndex += 3

    while index <= endIndex
      buffer[ index ] = 32
      ++index

    index += e_delimeter.length - 3
    ++found

  found

module.exports = ( isProduction, keepDebugConf )->

  replaceKey = if isProduction then "dev" else "prod"

  # This transformer simply replace things inside delimeter to be space
  es.through ( file )->

    delimeter = delimeterMap[ path.extname(file.path) ]
    if not delimeter then return @emit "data", file

    found = transform file, replaceKey, delimeter

    if not keepDebugConf
      found += transform file, "debug", delimeter

    if found
      file.extra = "EnvProdFound"
      if found > 1 then file.extra += " x" + found

    @emit "data", file
    null
