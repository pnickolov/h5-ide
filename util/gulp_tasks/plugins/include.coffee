
es = require("event-stream")
path = require("path")
fs = require("fs")

# Includes files for html, Syntax : <!-- {{./abc.html}} -->

ReplaceRegex = /<!--\s+{{([^}]+)}}\s+-->/g
ReadOption = {encoding:"utf8"}

include = ( file )->

  modified = false

  # Include file
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

module.exports = ()-> es.through include
