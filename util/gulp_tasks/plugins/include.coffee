
es = require("event-stream")
path = require("path")
fs = require("fs")

# Includes files for html, Syntax : <!-- {{./abc.html}} -->

ReplaceRegex = /<!--\s+{{([^}]+)}}\s+-->/g
ReadOption = {encoding:"utf8"}

include = ( file )->

  # Include file
  file.strings = file.contents.toString("utf8").replace ReplaceRegex, (match, includePath)->

    p = path.resolve( path.dirname(file.path), includePath )

    if not fs.existsSync( p )
      console.log "[Include Error] Cannot find : #{match}"
      return match

    fs.readFileSync p, ReadOption

  file.contents = null
  @emit "data", file
  null

module.exports = ()-> es.through include
