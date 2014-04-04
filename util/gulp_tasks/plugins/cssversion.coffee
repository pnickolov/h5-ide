
es = require("event-stream")
path = require("path")
fs = require("fs")

# Insert CSS Version to html

CssVersionRegex = /(href="|href=')([^'"]+)\/([^.]+.css)("|')/g

htmlModify = ( file )->

  modified = false

  # Insert CSS Version
  data = file.contents.toString("utf8").replace CssVersionRegex, (match, p1, p2, p3, p4)=>

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
