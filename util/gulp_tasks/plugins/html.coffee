
es = require("event-stream")
path = require("path")
fs = require("fs")

# Modified Html with:

# 1. Includes files for html, Syntax : <!-- {{./abc.html}} -->
# 2. Insert CSS version.

ReplaceRegex = /<!--\s+{{([^}]+)}}\s+-->/g
CssVersionRegex = /(href="|')([^'"]+)\/([^.]+.css)("|')/g
ReadOption = {encoding:"utf8"}

htmlModify = ( file )->

  ReplaceRegex.lastIndex = 0

  modified = false

  # Include file
  data = file.contents.toString("utf8").replace ReplaceRegex, (match, includePath)->

    p = path.resolve( file.path, includePath )

    if not fs.existsSync( p )
      console.log "[Include Error] Cannot find : #{match}"
      return match

    modified = true
    fs.readFileSync p, ReadOption

  # Insert CSS Version
  data = data.replace CssVersionRegex, (match, p1, p2, p3, p4)=>

    if @cssVersion[ p3 ]
      modified = true
      return p1 + p2 + "/" + p3 + "?v=" + @cssVersion[p3] + p4
    else
      return match
    null

  if modified
    file.contents = new Buffer(data)

  @emit "data", file
  null

module.exports = ( cssVersion )->
  pipe = es.through htmlModify
  pipe.cssVersion = cssVersion || {}

  pipe
