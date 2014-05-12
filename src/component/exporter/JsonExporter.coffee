
define ['./Download', 'i18n!nls/lang.js', "crypto"], ( download, lang )->

  ascii = ()-> String.fromCharCode.apply String, arguments
  key = ascii 77,97,100,101,105,114,97,67,108,111,117,100,73,68,69

  exportJson = ( json, name )->
    # Remove uncessary attributes of the json
    for i in ["description", "history", "id", "key", "property", "state", "username" ]
      delete json[i]

    json.signature = CryptoJS.HmacMD5(JSON.stringify( json ), key).toString()

    # I don't want to mess up with the grunt.
    # If we use gulp to build the source, the export json will be pretty-print in dev mode.
    space = 4
    ### env:prod ###
    space = undefined
    ### env:prod:end ###

    j = JSON.stringify json, undefined, space

    if $("body").hasClass("safari")
      blob = null
    else
      blob = new Blob [j]

    if not blob
      return {
        data : "data://text/plain;,#{j}"
        name : name
      }

    download( blob, name )
    null

  importJson = ( json )->
    try
      j = JSON.parse( json )
    catch e
      return lang.ide.POP_IMPORT_FORMAT_ERROR

    signature = j.signature
    delete j.signature
    ### env:dev ###
    return j
    ### env:dev:end ###
    ### env:debug ###
    return j
    ### env:debug:end ###
    if CryptoJS.HmacMD5( JSON.stringify( j ) , key ).toString() isnt signature
      return lang.ide.POP_IMPORT_MODIFIED_ERROR

    return j

  # genericExport() can download a file after the user clicks an `a link`.
  genericExport = ( aTag, contentJsonObject, fileName )->
    space = 4
    ### env:prod ###
    space = undefined
    ### env:prod:end ###
    j = JSON.stringify contentJsonObject, undefined, space

    ua = window.navigator.userAgent
    if ua.indexOf("Safari") > -1 and ua.indexOf("Chrome") is -1
      # Safari doesn't support blob download. We set the content to the link
      $(aTag).attr {
        href     : "data://text/plain;,#{j}"
        download : fileName
      }

    else
      $(aTag).off("click.export").on "click.export", ()->
        download( new Blob([j]), fileName )
        null

    null

  {
    exportJson : exportJson
    importJson : importJson

    genericExport : genericExport
  }
