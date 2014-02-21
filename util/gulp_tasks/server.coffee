
module.exports = {}
module.exports.create = ()->

  gutil = require("gulp-util")
  gutil.log gutil.colors.bgBlue(" Creating File Server... ")

  nstatic = require("node-static")
  http    = require("http")

  file = new nstatic.Server("./src", {"Cache-Control": "no-cache"} )

  server = http.createServer ( request, response )->

    request.addListener 'end', ()->

      url = request.url

      if url is "/"
        file.serveFile( "/ide.html", 200, {"Cache-Control": "no-cache"}, request, response )
      else
        if url[ url.length - 1 ] is "/"

          file.serveFile( "/ide.html", 301, { "Location" : url.substring(0,url.length-1) }, request, response )

        else if url.lastIndexOf(".html") isnt -1
          file.serve( request, response )
        else if (url.indexOf("/", 1) is -1)
          file.serveFile( url + ".html", 200, {"Cache-Control": "no-cache"}, request, response )
        else
          file.serve( request, response )
      null

    request.resume()


  server.listen( "3000", "127.0.0.1" )
  null
