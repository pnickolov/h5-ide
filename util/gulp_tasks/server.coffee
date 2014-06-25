
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

    REG_RESET    = /^\/reset(\?\S*)?/
    REG_LOGIN    = /^\/login(\?\S*)?/
    REG_REGISTER = /^\/register(\?\S*)?/
    REG_IDE      = /^\/(ops|store)\/?/
    REG_500      = /^\/500(\?\S)?/
    request.addListener 'end', ()->
      url = request.url

      if url is "/"
        filePath = "/ide.html"
      else if url[ url.length - 1 ] is "/"
        response.writeHead 301, { "Location" : url.substring(0, url.length-1) }
        response.end()
        return
      else if redirectRegex.test(url)
        response.writeHead 301, { "Location" : url.replace(".html", "") }
        response.end()
        return
      else if REG_RESET.test( url )
        filePath = "/reset.html"
      else if REG_REGISTER.test( url )
        filePath = "/register.html"
      else if REG_LOGIN.test( url )
        filePath = "/login.html"
      else if REG_IDE.test( url )
        filePath = "/ide.html"
      else if REG_500.test(url)
        filePath = '/500.html'

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
