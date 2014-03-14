
gulp      = require("gulp")
gutil     = require("gulp-util")
es        = require("event-stream")
Q         = require("q")

coffee      = require("gulp-coffee")
include     = require("./plugins/include")
langsrc     = require("./plugins/langsrc")
confCompile = require("./plugins/conditional")
handlebars  = require("./plugins/handlebars")
ideversion  = require("./plugins/ideversion")
variable    = require("./plugins/variable")
rjsconfig   = require("./plugins/rjsconfig")
requirejs   = require("./plugins/r")

stripdDebug = require("gulp-strip-debug")

util = require("./plugins/util")

SrcOption = {"base":"./src"}

logTask = ( msg, noNewlineWhenNotVerbose )->
  msg = "[ #{gutil.colors.bgBlue.white(msg)} ] "

  if noNewlineWhenNotVerbose and not GLOBAL.gulpConfig.verbose
    process.stdout.write msg
  else
    console.log msg
  null

fileLogger = ()->
  es.through ( f )->
    if GLOBAL.gulpConfig.verbose
      console.log util.compileTitle( f.extra, false ), "#{f.relative}"
    else
      process.stdout.write "."

    @emit "data", f
    null

dest = ()-> gulp.dest "./build"
end  = ( d, printNewlineWhenNotVerbose )->
  if printNewlineWhenNotVerbose and not GLOBAL.gulpConfig.verbose
    ()->
      process.stdout.write "\n"
      d.resolve()
  else
    ()-> d.resolve()

stdRedirect = (d)-> process.stdout.write d; null

Tasks =
  cleanRepo : ()->
    logTask "Removing ignored files in src (git clean -Xf)"

    util.runCommand "git", ["clean", "-Xf"], { cwd : process.cwd() + "/src" }, stdRedirect

  copyAssets : ()->
    logTask "Copying Assets"

    path = ["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"]

    d = Q.defer()
    gulp.src( path, SrcOption ).pipe( dest() ).on( "end", end(d) )
    d.promise

  copyJs : ()->
    logTask "Copying Js & Templates"

    path = ["./src/**/*.js", "./src/**/*.html", "!./src/test/**/*"]

    d = Q.defer()
    gulp.src( path, SrcOption ).pipe( dest() ).on( "end", end(d) )
    d.promise

  compileLangSrc : ()->
    logTask "Compiling lang-source"

    d = Q.defer()
    gulp.src(["./src/nls/lang-source.coffee"])
        .pipe(langsrc("./build",false,GLOBAL.gulpConfig.verbose))
        .on( "end", end(d) )
    d.promise

  compileCoffee : ( debugMode )->
    ()->
      logTask "Compiling coffees", true

      path = ["./src/**/*.coffee", "!src/test/**/*", "!./src/nls/lang-source.coffee"]

      d = Q.defer()
      pipe = gulp.src( path, SrcOption )
        .pipe( confCompile( true ) ) # Remove ### env:dev ###
        .pipe( coffee() ) # Compile coffee
        .pipe( fileLogger() )

      if not debugMode then pipe = pipe.pipe( stripdDebug() )

      pipe.pipe( dest() ).on( "end", end(d, true) )
      d.promise

  compileTemplate : ()->
    logTask "Compiling templates", true

    path = ["./src/**/*.partials", "./src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html" ]

    d = Q.defer()
    gulp.src( path, SrcOption )
      .pipe( confCompile(true) )
      .pipe( handlebars( false ) )
      .pipe( fileLogger() )
      .pipe( dest() )
      .on( "end", end(d, true) )
    d.promise

  processHtml : ()->
    logTask "Processing ./src/*.html"

    path = ["./src/*.html"]

    d = Q.defer()
    gulp.src( path )
      .pipe( confCompile( true ) )
      .pipe( include() ) # Include other templates or variables to the html
      .pipe( variable() )
      .pipe( dest() )
      .on( "end", end(d) )
    d.promise

  concatJS : ( debug, outputPath )->
    ()->
      logTask "Concating JS"

      d = Q.defer()
      requirejs.optimize( rjsconfig( debug, outputPath )

      , (buildres)->
        console.log "Concat result:"
        console.log buildres
        d.resolve()
      , (err)->
        console.log err
      )

      d.promise

  removeBuildFolder : ()->
    util.deleteFolderRecursive( process.cwd() + "/build" )
    true

  fetchRepo : ( debugMode, qaMode )->
    if qaMode
      return ()-> true

    ()->
      logTask "Checking out h5-ide-build"

      # First delete the repo
      util.deleteFolderRecursive( process.cwd() + "/h5-ide-build" )

      # Checkout latest repo
      params = ["clone", GLOBAL.gulpConfig.buildRepoUrl, "-b", if debugMode then "develop" else "master"]

      if GLOBAL.gulpConfig.buildUsername
        params.push "-c"
        params.push "user.name=\"#{GLOBAL.gulpConfig.buildUsername}\""
      if GLOBAL.gulpConfig.buildEmail
        params.push "-c"
        params.push "user.email=\"#{GLOBAL.gulpConfig.buildEmail}\""

      util.runCommand "git", params, {}, stdRedirect

  preCommit : ()->
    logTask "Pre-commit"

    # Move h5-ide-build/.git to deploy/.git
    move = util.runCommand "mv", ["h5-ide-build/.git", "deploy/.git"], {}

    option = { cwd : process.cwd() + "/deploy" }

    # Add all files
    commitData = ""
    move.then ()->
      util.runCommand "git", ["add", "-A"], option
    .then ()->
      util.runCommand "git", ["commit", "-m", "pre-#{ideversion.version()}"], option, (d)-> commitData+=d;null
    .then ()->
      if commitData[0] is "#"
        console.log commitData
      else
        # Strip uncessary commit info
        commitData = commitData.split("\n")
        console.log commitData[0]
        console.log commitData[1]
      true

  fileVersion : ()->
    logTask "Getting all files version"

    fileData = ""
    listFile = util.runCommand "git", ["ls-files", "-s"], { cwd : process.cwd() + "/deploy" }, (d, type)->
      if type is "out" then fileData += d
      null

    listFile.then ()->
      versions = {}
      for entry in fileData.split("\n")
        line = entry.split(/\s+?/)
        if line[3]
          versions[ line[3] ] = line[1].substr(0, 8)
        null
      GLOBAL.gulpConfig.fileVersions = versions
      true

# A task to build IDE
  #*** Perform `git -fX ./src` first, to remove ignored files.
  #*** Copy assets file to `build` folder
  #*** Copy js file to `build` folder
  #*** Process `lang-source.coffee` and copy to `build` folder
  #*** Process `*.coffee` and copy to `build` folder
  #*** Process all other `templates` and copy to `build` folder
  #*** Process `./src/*.html` and copy to `build` folder
  #*** Use `r.js` to optimize the whole `build` folder
  #*** Git commit
  #*** Fetach all file version
  #*** Insert css version to html
  #*** Generate version for JS files
  #*** Final Git commit
  #*** Push to remote
module.exports =
  build : ( mode )->

    deploy     = mode isnt "qa"
    debugMode  = mode is "qa" or mode is "debug"
    outputPath = if mode is "qa" then "./qa" else undefined
    qaMode     = mode is "qa"

    ideversion.read( deploy )

    [
      # Tasks.cleanRepo
      # Tasks.copyAssets
      # Tasks.copyJs
      # Tasks.compileLangSrc
      # Tasks.compileCoffee( debugMode )
      # Tasks.compileTemplate
      # Tasks.processHtml
      # Tasks.concatJS( debugMode, outputPath )
      # Tasks.removeBuildFolder
      # Tasks.fetchRepo( debugMode, qaMode )
      # Tasks.preCommit
      # Tasks.fileVersion
    ].reduce( Q.when, Q() )
