
module.exports = {}

defaultHeader = { "Cache-Control" : "no-cache" }

module.exports.create = ()->
  gutil   = require("gulp-util")
  nstatic = require("node-static")
  http    = require("http")

  gutil.log gutil.colors.bgBlue(" Creating File Server... ")

  file = new nstatic.Server("./src", { cache : false, headers : defaultHeader } )

  server = http.createServer ( request, response )->

    request.addListener 'end', ()->
      url = request.url

      if url is "/"
        filePath = "/ide.html"
      else if url[ url.length - 1 ] is "/"
        response.writeHead 301, { "Location" : url.substring(0, url.length-1) }
        response.end()
        return
      else if url.indexOf( ".", 1 ) is -1
        filePath = url + ".html"

      errorHandler = ( e )->
        console.log "[ServerError]", e.message, request.url
        response.writeHead(404)
        response.end()
        null

      if filePath
        file.serveFile( filePath, 200, defaultHeader, request, response ).addListener("error", errorHandler)
      else
        file.serve( request, response ).addListener("error", errorHandler)
      null

    request.resume()
    null

  server.listen( GLOBAL.gulpConfig.staticFileServerPort, "127.0.0.1" )
  null
