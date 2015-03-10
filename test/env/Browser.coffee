
Browser = require("zombie")
Browser.localhost('ide.xxx.io', 3010)

module.exports = browser = new Browser({
  waitDuration : "30s"
})

# browser.on "request", ()-> console.log(arguments[0].url)

browser.on "loading", ( document )->
  # Patch zombie's XMLHttpRequest, so that jquery will know we can do CORS request
  originXHR = document.window.XMLHttpRequest
  if not (new originXHR()).withCredentials
    console.log("[Debug] Adding CORS support")
    document.window.XMLHttpRequest = ()-> (a = new originXHR()).withCredentials = true; a
  return
