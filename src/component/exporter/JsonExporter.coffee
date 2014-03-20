
define ['./Download', 'i18n!nls/lang.js', "./HmacMd5"], ( download, lang )->

  exportJson = ( json, name )->
    # Remove uncessary attributes of the json
    for i in ["description", "history", "id", "key", "property", "state", "username" ]
      delete json[i]

    json.signature = CryptoJS.HmacMD5(JSON.stringify( json ), "MaderiaCloudIDE").toString()

    # I don't want to mess up with the grunt.
    # If we use gulp to build the source, the export json will be pretty-print in dev mode.
    space = 4
    ### env:prod ###
    space = undefined
    ### env:prod:end ###

    j = JSON.stringify json, undefined, space

    ua = window.navigator.userAgent

    if ua.indexOf("Safari") > -1 and ua.indexOf("Chrome") is -1
      blob = null
    else
      blob = new Blob [j]

    if not blob
      return {
        data : "data://text/plain;, " + j
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
    if CryptoJS.HmacMD5( JSON.stringify( j ) , "MaderiaCloudIDE" ).toString() isnt signature
      return lang.ide.POP_IMPORT_MODIFIED_ERROR

    return j

  {
    export : exportJson
    import : importJson
  }
