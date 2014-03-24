
Q     = require("q")
gutil = require("gulp-util")

module.exports = ( url )->
  try
    zombie = require("zombie")
  catch e
    console.log gutil.colors.bgYellow.black "Cannot find zombie. Automated test is not disabled."
    return false

  return true
