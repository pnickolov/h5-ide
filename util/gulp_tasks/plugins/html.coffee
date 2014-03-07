
es = require("event-stream")
path = require("path")
fs = require("fs")

# Modified Html with:

# 1. Includes files for html, Syntax : <!-- {{./abc.html}} -->
# 2. Insert CSS version.

ReplaceRegex = /<!--\s+{{([^}]+)}}\s+-->/g
ReadOption = {encoding:"utf8"}

htmlModify = ( file )->

  ReplaceRegex.lastIndex = 0

  modified = false

  data = file.contents.toString("utf8").replace ReplaceRegex, (match, includePath)->

    p = path.resolve( file.path, includePath )

    if not fs.existsSync( p )
      console.log "[Include Error] Cannot find : #{match}"
      return match

    modified = true
    fs.readFileSync p, ReadOption

  if modified
    file.contents = new Buffer(data)

  @emit "data", file
  null

module.exports = ()-> es.through htmlModify
