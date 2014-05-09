
define [], ()->
  ###
  # === McError ===
  # McError is Object to represent an Error. Every promise handler that wants to throw error should throw an McError
  ###
  window.McError = ( errorNum, errorMsg, params )->
    {
      error  : errorNum
      msg    : errorMsg || ""
      result : params || undefined
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

  ###
    Some of the api defined manually, might change to use generated api.
  ###
  ApiRequestDefs.Defs =
    login      : { url:"/session/", method:"login",      params:["username", "password"]   }
    logout     : { url:"/session/", method:"logout",     params:["username", "session_id"] }
    syncRedis  : { url:"/session/", method:"sync_redis", params:["username", "session_id"] }
    updateCred : { url:"/session/", method:"set_credential", params:["username","session_id","access_key","secret_key","account_id"] }
    resetKey   : { url:"/account/", method:"reset_key", params:["username","session_id","flag"] }
    changePwd  : { url:"/account/", method:"update_account", params:["username","session_id","params"]}


  ###
  Parsers are promise's success hanlder.
  Thus, if the parser cannot parse a result, it should throw an error !!!
  An example would be like : `throw McError( 300, "Cannot parse the result" )`
  ###
  ApiRequestDefs.Parsers = {}


  ApiRequestDefs.AutoFill = ( paramter_name )->
    switch paramter_name
      # The generated API uses the username as the usercode
      when "username"
        return $.cookie('usercode')
      when "session_id"
        return $.cookie('session_id')
    return null

  ApiRequestDefs
