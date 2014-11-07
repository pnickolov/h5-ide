
es = require("event-stream")

module.exports = ( nextPipe )->
  if not GLOBAL.gulpConfig.enableCache
    return nextPipe

  newCache = {}
  pipeline = es.through ( file )->
    if newCache[ file.path ]
      utf8Content = file.contents.toString("utf8")
      if newCache[ file.path ] is utf8Content
        if GLOBAL.gulpConfig.verbose
          console.log "[Cached]", file.path
        return

    if not utf8Content
      utf8Content = file.contents.toString("utf8")

    newCache[ file.path ] = utf8Content
    @emit "data", file
    null

  pipeline.pipe( nextPipe )
  pipeline
