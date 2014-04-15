
gutil        = require("gulp-util")
notifier     = require("node-notifier")
fs           = require("fs")
childprocess = require('child_process')
Q            = require("q")

spawn = childprocess.spawn
exec  = childprocess.exec

util =
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
    if GLOBAL.gulpConfig.enbaleNotifier and msg
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

  deleteFolderRecursive : ( path )->
    if not fs.existsSync( path ) then return true

    for file, index in ( fs.readdirSync( path ) || [] )
      curPath = path + "/" + file
      if fs.lstatSync( curPath ).isDirectory()
        if not util.deleteFolderRecursive( curPath )
          return false
      else
        try
          if process.platform is "win32" then fs.chmodSync curPath, 666

          fs.unlinkSync( curPath )
        catch e
          if GLOBAL.gulpConfig.verbose
            console.log "[Cannot remove file]", curPath
          return false

    try
      fs.rmdirSync( path )
    catch e
      if GLOBAL.gulpConfig.verbose
        console.log "[Cannot remove folder]", path
      return false

    true

  runCommand : ( command, args, options, handlers )->
    d = Q.defer()
    process = spawn( command, args, options )

    handlers = handlers || {}

    onData = if handlers.apply and handlers.call then handlers else handlers.onData

    process.on "exit", ()-> d.resolve()

    process.on "error", (e)->
      if handlers.onError
        handlers.onError.apply( null, arguments )

      if e.code is "ENOENT" and e.errno is "ENOENT" and e.syscall is "spawn"
        d.resolve()
      null

    if onData
      process.stderr.on("data", (d)-> onData d.toString("utf8"), "error" )
      process.stdout.on("data", (d)-> onData d.toString("utf8"), "out" )

    d.promise

module.exports = util
