
gutil    = require("gulp-util")
notifier = require("node-notifier")

module.exports =
  log  : (e)-> console.log e
  noop : ()->

  cwd  : process.cwd()

  endsWith : ( string, pattern )->
    if string.length < pattern.length then return false

    idx      = 0
    startIdx = string.length - pattern.length

    while idx < pattern.length
      if string[ startIdx + idx ] isnt pattern[ idx ]
        return false
      ++idx

    true

  notify : ( msg )->
    if GLOBAL.gulpConfig.enbaleNotifier
      notifier.notify {
        title   : "IDE Gulp"
        message : msg
      }, ()-> # Add an callback, so that windows won't fail.
    null

  compileTitle : ( extra, printTime = true )->

    time = if printTime then " @" + (new Date()).toLocaleTimeString() else ""

    title = "[" + gutil.colors.green("Compile#{time}") + "]"
    if extra
      title += " " + gutil.colors.inverse( extra )
    title
