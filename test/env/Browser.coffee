
Q       = require("q")
Browser = require("zombie")
gutil   = require("gulp-util")
Browser.localhost('ide.xxx.io', 3010)

module.exports = browser = new Browser({ waitDuration : "30000s" })

if GLOBAL.gulpConfig.showTestRequest || true
  browser.on "request", ()-> console.log(arguments[0].url)

logTitle = ()-> "[" + gutil.colors.green("Debug @#{(new Date()).toLocaleTimeString()}") + "]"

browser.launchIDE = ()->
  d = Q.defer()
  browser.resources.post 'http://api.xxx.io/session/', {
    body : '{"jsonrpc":"2.0","id":"1","method":"login","params":["test","aaa123aa",{"timezone":8}]}'
  }, ( error, response )->
    if error then return d.reject( error )

    res = JSON.parse( response.body.toString() ).result[1]
    browser.setCookie({
      name   : "session_id"
      value  : res.session_id
      maxAge : 3600*24*30
      domain : "ide.xxx.io"
    })
    browser.setCookie({
      name   : "usercode"
      value  : res.username
      maxAge : 3600*24*30
      domain : "ide.xxx.io"
    })

    browser.on "loaded", ()->
      console.log logTitle(), "Document loaded."

      # Wait until the IDE has finished launching ( with require.js )
      # Define a magical attribute
      # The ide will set this to true once it is inited.
      # Not sure why, but the attribute has to be set on the prototype, otherwise
      # the attribute's getter/setter won't work
      __inited = false
      Object.defineProperty browser.window.constructor.prototype, "__IDE__INITED", {
        configurable : true
        enumerable   : true
        get : ()-> __inited
        set : (v)->
          if not __inited
            __inited = v
            if v then d.resolve()
          return
      }

    # Seems like we need to attach handlers to the visit promise.
    # Otherwise, it will not work as expected.
    browser.visit("/").then (()->), ((e)-> if e then console.log(e))
    return

  d.promise

browser.close = ()->
  window = browser.window

  window.App?.WS?.close()

  xhr.abort() for xhr in window.____xhrarray || []
  ws.close()  for ws  in window.____wsarray  || []

  Browser.prototype.close.call @, window

originWS = originXHR = null
browser.on "loading", ( document )->
  if not originXHR then originXHR = document.window.XMLHttpRequest
  if not originWS  then originWS  = document.window.WebSocket

  if document.window.XMLHttpRequest is originXHR
    document.window.XMLHttpRequest = (a,b,c,d,e)->

      xhr = new originXHR(a,b,c,d,e)

      # Make jquery know we can do CORS request
      xhr.withCredentials = true

      # Keep track of xhr
      xhra = document.window.____xhrarray || (document.window.____xhrarray = [])
      xhra.push xhr

      slice = ()->
        xhra.splice( xhra.indexOf(xhr), 1 )
        xhr.removeEventListener "load", slice

      xhr.addEventListener "load", slice
      xhr

  if document.window.WebSocket is originWS
    # Keep track of websocket
    document.window.WebSocket = (a,b,c,d,e)->
      ws = new originWS(a,b,c,d,e)

      # Keep track of xhr
      wsa = document.window.____wsarray || (document.window.____wsarray = [])
      wsa.push ws
      ws
  return
