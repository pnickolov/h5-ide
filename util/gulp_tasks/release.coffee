
gulp      = require("gulp")
gutil     = require("gulp-util")
es        = require("event-stream")
fs        = require("fs")
Q         = require("q")
path      = require("path")

coffee      = require("gulp-coffee")
stripdDebug = require("gulp-strip-debug")

include     = require("./plugins/include")
langsrc     = require("./plugins/langsrc")
confCompile = require("./plugins/conditional")
handlebars  = require("./plugins/handlebars")
ideversion  = require("./plugins/ideversion")
variable    = require("./plugins/variable")
rjsconfig   = require("./plugins/rjsconfig")
requirejs   = require("./plugins/r")
rjsreporter = require("./plugins/rjsreporter")
unittest    = require("./plugins/test")
util        = require("./plugins/util")

server = require("./server")


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

    util.runCommand "git", ["clean", "-Xdf"], { cwd : process.cwd() + "/src" }, stdRedirect

  copyAssets : ()->
    logTask "Copying Assets"

    p = ["./src/assets/**/*", "!**/*.glyphs", "!**/*.scss"]

    d = Q.defer()
    gulp.src( p, SrcOption ).pipe( dest() ).on( "end", end(d) )
    d.promise

  copyJs : ()->
    logTask "Copying Js & Templates"

    p = ["./src/**/*.js", "!./src/test/**/*"]

    d = Q.defer()
    gulp.src( p, SrcOption ).pipe( dest() ).on( "end", end(d) )
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

      p = ["./src/**/*.coffee", "!src/test/**/*", "!./src/nls/lang-source.coffee"]

      d = Q.defer()
      pipe = gulp.src( p, SrcOption )
        .pipe( confCompile( true ) ) # Remove ### env:dev ###
        .pipe( coffee() ) # Compile coffee
        .pipe( fileLogger() )

      if not debugMode then pipe = pipe.pipe( stripdDebug() )

      pipe.pipe( dest() ).on( "end", end(d, true) )
      d.promise

  compileTemplate : ()->
    logTask "Compiling templates", true

    p = ["./src/**/*.partials", "./src/**/*.html", "!src/test/**/*", "!src/*.html", "!src/include/*.html" ]

    d = Q.defer()
    gulp.src( p, SrcOption )
      .pipe( confCompile(true) )
      .pipe( handlebars( false ) )
      .pipe( fileLogger() )
      .pipe( dest() )
      .on( "end", end(d, true) )
    d.promise

  processHtml : ()->
    logTask "Processing ./src/*.html"

    p = ["./src/*.html"]

    d = Q.defer()
    gulp.src( p )
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
      requirejs.optimize(
        rjsconfig( debug, outputPath )
      , (buildres)->
        if rjsreporter(buildres)
          d.resolve()
        else
          console.log gutil.colors.bgRed.white("Aborted due to concat error")
          d.reject()
      , (err)->
        console.log err
        d.reject()
      )

      d.promise

  removeBuildFolder : ()->
    util.deleteFolderRecursive( process.cwd() + "/build" )
    true

  fetchRepo : ( debugMode )->
    ()->
      logTask "Checking out h5-ide-build"

      # First delete the repo
      util.deleteFolderRecursive( process.cwd() + "/h5-ide-build" )

      # Checkout latest repo
      params = ["clone", GLOBAL.gulpConfig.buildRepoUrl, "-v", "--progress", "-b", if debugMode then "develop" else "master"]

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

    # Move gitignore if there's any
    if fs.existsSync("./h5-ide-build/.gitignore" )
      move = move.then ()->
        util.runCommand "mv", ["h5-ide-build/.gitignore", "deploy/.gitignore"], {}

    option = { cwd : process.cwd() + "/deploy" }

    # Add all files
    commitData = ""
    move.then ()->

      # Delete the deprecated repo
      util.deleteFolderRecursive( process.cwd() + "/h5-ide-build" )

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

    urlRegex = /(\="|\='|url\('|url\(")([^'":]+?\/[^'"]+?\/[^'"?]+?)("|')/g
    noramlize = /\\/g

    versions = {}

    listFile.then ()->
      for entry in fileData.split("\n")
        line = entry.split(/\s+?/)
        if line[3]
          versions[ line[3].replace(noramlize, "/") ] = line[1].substr(0, 8)
        null

    .then ()-> # Insert buster in all *.html and all *.css
      d = Q.defer()
      gulp.src(["./deploy/*.html","./deploy/assets/css/*.css"], {base:process.cwd()+"/deploy"})
        .pipe es.through (f)->

          cwd = path.resolve( process.cwd(), "./deploy" )
          newContent = f.contents.toString("utf8").replace urlRegex, ( match, p1, p2, p3 )->

            p = path.resolve( path.dirname(f.path), p2 ).replace( cwd, "" )
            if p[0] is "/" or p[0] is "\\"
              p = p.replace(/\/|\\/, "")

            version = versions[p]

            if GLOBAL.gulpConfig.verbose
              console.log p, version

            if version
              p1 + p2 + "?v=#{version}" + p3
            else
              match

          f.contents = new Buffer( newContent )
          @emit "data", f
          null
        .pipe( gulp.dest("./deploy") ).on( "end", end(d) )
      d.promise

    .then ()-> # Generate file version and pack them into config.js
      jsV = {}
      for key, value of versions
        l = key.length
        if key[l-3] is "." and key[l-2] is "j" and key[l-1] is "s"
          jsV[key] = value

      # Only keep js file version
      buster = "window.FileVersions="+JSON.stringify(jsV)+";\n"
      d = Q.defer()
      gulp.src("./deploy/**/config.js")
        .pipe es.through (f)->
          f.contents = new Buffer( buster + f.contents.toString("utf8") )
          @emit "data", f
        .pipe( gulp.dest("./deploy") ).on("end", end(d) )

      d.promise

  logDeployInDevRepo : ()->
    logTask "Commit IdeVersion in h5-ide"
    # Update IDE Version to dev repo
    util.runCommand "git", ["commit", "-m", '"Deploy '+ideversion.version()+'"', "package.json"]


  finalCommit : ()->
    logTask "Final Commit"

    option = { cwd : process.cwd() + "/deploy" }

    # Add all files
    devRepoV = "HEAD"
    task = util.runCommand "git", ["rev-parse", "HEAD"], undefined, (d)-> devRepoV=d;null

    task.then ()->
      util.runCommand "git", ["add", "-A"], option
    .then ()->
      util.runCommand "git", ["commit", "-m", "#{ideversion.version()} ; DevRepo: MadeiraCloud/h5-ide@#{devRepoV}"], option
    .then ()->

      if GLOBAL.gulpConfig.autoPush
        console.log "[ " + gutil.colors.bgBlue.white("Pushing to Remote") + " ]"
        console.log gutil.colors.bgYellow.black("  AutoPush might be slow, you can always kill the task at this moment. ")
        console.log gutil.colors.bgYellow.black("  Then manually git-push `./deploy`. You can delete `./deploy` after git-pushing. ")

        util.runCommand "git", ["push", "-v", "--progress", "-f"], option, stdRedirect
      else
        console.log gutil.colors.bgYellow.black("  AutoPush is disabled. Please manually git-push `./deploy`. ")
        console.log gutil.colors.bgYellow.black("  You can delete `./deploy` after pushing. ")
        true
    .then ()->
      if GLOBAL.gulpConfig.autoPush
        util.deleteFolderRecursive( process.cwd() + "/deploy" )
      true

  test : ( qaMode )->
    path = if qaMode then "./qa" else "./deploy"

    ()->
      # Create a server to serve the files for testing.
      testserver = server.create path, 3010, false, false

      # Start test with zombie
      logTask "Starting automated test"

      unittest().then ()-> testserver.close(); true


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

    tasks = [
      Tasks.cleanRepo
      Tasks.copyAssets
      Tasks.copyJs
      Tasks.compileLangSrc
      Tasks.compileCoffee( debugMode )
      Tasks.compileTemplate
      Tasks.processHtml
      Tasks.concatJS( debugMode, outputPath )
      Tasks.removeBuildFolder
      Tasks.test( qaMode )
    ]

    if not qaMode
      tasks = tasks.concat [
        Tasks.logDeployInDevRepo
        Tasks.fetchRepo( debugMode )
        Tasks.preCommit
        Tasks.fileVersion
        Tasks.finalCommit
      ]

    tasks.reduce( Q.when, Q() )
