
gutil   = require("gulp-util")
nstatic = require("node-static")
http    = require("http")
open    = require("open")

module.exports.create = ( path = "./src", port = GLOBAL.gulpConfig.staticFileServerPort, autoOpen = GLOBAL.gulpConfig.openUrlAfterCreateServer, logTask = true )->

  defaultHeader = { "Cache-Control" : "no-cache" }

  if logTask
    gutil.log gutil.colors.bgBlue.white(" Creating File Server... ")

  file = new nstatic.Server( path, { cache : false, headers : defaultHeader } )

  redirectRegex = /(login|ide|register|reset)\.html$/

  server = http.createServer ( request, response )->

    request.addListener 'end', ()->
      url = request.url

      if url is "/"
        filePath = "/ide.html"
      else if /ide.html$/.test( url )
        response.writeHead 301, { "Location" : "/" }
        response.end()
        return
      else if url[ url.length - 1 ] is "/"
        response.writeHead 301, { "Location" : url.substring(0, url.length-1) }
        response.end()
        return
      else if redirectRegex.test(url)
        response.writeHead 301, { "Location" : url.replace(".html", "") }
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

  server.listen( port )

  if autoOpen then open "http://127.0.0.1:#{port}"

  server
