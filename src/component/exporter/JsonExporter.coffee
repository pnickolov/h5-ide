
define ['./Download', "./HmacMd5"], ( download )->

  exportJson = ( json, name )->
    # Remove uncessary attributes of the json

    for i in ["description", "history", "id", "key", "property", "state", "username" ]
      delete json[i]

    json.signature = CryptoJS.HmacMD5(JSON.stringify( json ), "MaderiaCloudIDE").toString()

    j = JSON.stringify(json)

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
      return "The json file is malformed."

    signature = j.signature
    delete j.signature
    if CryptoJS.HmacMD5( JSON.stringify( j ) , "MaderiaCloudIDE" ).toString() isnt signature
      return "We do not support user modified json."

    return j

  {
    export : exportJson
    import : importJson
  }
