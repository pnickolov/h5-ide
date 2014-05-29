
define [], ()->
  ###
  # === McError ===
  # McError is Object to represent an Error. Every promise handler that wants to throw error should throw an McError
  # If McError contains aws result error, it will have 3 additional members:
    awsError     : Number
    awsErrorCode : String
    awsResult    : String or Object
  ###
  window.McError = ( errorNum, errorMsg, params )->
    {
      error  : errorNum
      msg    : errorMsg || ""
      result : params || undefined
      reason : errorMsg
      ### env:dev ###
      stack  : MC.prettyStackTrace(1)
      ### env:dev:end ###
    }


  ###
  == Following name of the paramter is autofilled. Thus the paramter is not required.
  == It also means that you cannot use a param name if the param is for sth. else.
     For example, the param's name cannot be username, if it's used to represent Instance's Id.

  ** Auto Fill List :
  username
  usercode
  session_id
  ###

  ApiRequestDefs = {}

  ApiRequestDefs.Defs =
    saveStack  : { url:"/stack/",   method:"save",       params:["username", "session_id", "region_name", 'data'] }
    createStack: { url:"/stack/",   method:"create",     params:["username", "session_id", "region_name", "data"] }

  ###
  Parsers are promise's success hanlder.
  Thus, if the parser cannot parse a result, it should throw an error !!!
  An example would be like : `throw McError( 300, "Cannot parse the result" )`
  ###
  ApiRequestDefs.Parsers = {}


  ApiRequestDefs.AutoFill = ( paramter_name )->
    switch paramter_name
      # The generated API uses the username as the username
      when "username"
        return App.user.get("usercode")
      when "session_id"
        return App.user.get("session")
      when "region_name"
        console.warn "Autofilling region_name:'us-east-1' for ApiRequest, this is for some api who requires region_name while it doesn't care about its value. %o", MC.prettyStackTrace(1)
        return "us-east-1"
    return null

  ApiRequestDefs
