
# A better version of the gulp-jshint
es     = require("event-stream")
gutil  = require("gulp-util")
jshint = require('jshint').JSHINT

# Option for jshint
jshintGlobals = {}
jshintOption =
  "-W099" : true # Allow mixed tabs and spaces
  "-W041" : true # Allow comparing null using ==


problemSign = if process.platform is "win32" then "x " else "✖ "

formatOutput = ( success, file )->
  # no error
  if success then return {success:true}

  filePath = file.path or 'stdin'

  # errors
  results = jshint.errors.map (err)->
    if not err then return
    return {file:filePath, error:err}

  data = [jshint.data()]
  data[0].file = filePath

  {
    success : false
    results : results.filter ( err )-> err
    data    : data
  }

module.exports = ()->
  es.through (file)->

    if file.isNull() or file.isStream() then return @emit "data", file # pass along

    str = file.contents.toString('utf8')
    try
      success = jshint str, jshintOption, jshintGlobals
    catch e
      console.log gutil.colors.red.bold("[JsHint #{problemSign} 999]"), gutil.colors.underline( file.path )
      console.log "Too many jshint error."
      @emit "data", file

    # send status down-stream
    file.jshint = formatOutput success, file

    @emit "data", file
    null
