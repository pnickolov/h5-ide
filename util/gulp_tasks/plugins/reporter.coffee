
table = require("text-table")
gutil = require("gulp-util")
es    = require("event-stream")

stringLength = (str) -> gutil.colors.stripColor(str).length

problemSign = if process.platform is "win32" then "x " else "✖ "

transform = ( el, i )->
  err = el.error or el
  [
    ""
    gutil.colors.yellow "line " + (err.line or err.lineNumber)
    gutil.colors.yellow( if err.character then "col " + err.character else "" )
    gutil.colors.inverse("(#{err.code or err.rule})") + " " + gutil.colors.blue( err.reason or err.message )
  ]

reporter = ( fileName, title, result ) ->
  total = result.length
  if total > 0
    title = gutil.colors.red.bold("[#{title} #{problemSign}#{total}] ") + gutil.colors.underline( fileName )

    ret = title + "\n" + table( result.map(transform), { stringLength : stringLength } )

    console.log ret + "\n"

  null

reporterWrap = (file) ->
  p = file.path.replace process.cwd(), ""

  if file.coffeelint and not file.coffeelint.success
    reporter p, "CoffeeLint", file.coffeelint.results

  if file.jshint and not file.jshint.success
    reporter p, "JsHint", file.jshint.results

  @emit('data', file)

module.exports = ()-> es.through reporterWrap
