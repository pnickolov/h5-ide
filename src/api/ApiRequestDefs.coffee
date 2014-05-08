
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

  ApiRequestDefs =
    login      : { url:"/session/", method:"login",      params:["username", "password"]   }
    logout     : { url:"/session/", method:"logout",     params:["usercode", "session_id"] }
    syncRedis  : { url:"/session/", method:"sync_redis", params:["usercode", "session_id"] }
    updateCred : { url:"/session/", method:"set_credential", params:["usercode","session_id","access_key","secret_key","account_id"] }
    resetKey   : { url:"/account/", method:"reset_key", params:["usercode","session_id","flag"] }


  ###
  Parsers are promise's success hanlder.
  Thus, if the parser cannot parse a result, it should throw an error !!!
  An example would be like : `throw McError( 300, "Cannot parse the result" )`
  ###
  ApiRequestDefs.Parsers =
    login : ( result )->
      usercode     : result.username
      username     : MC.base64Decode( result.username )
      email        : result.email
      user_hash    : result.user_hash
      session_id   : result.session_id
      account_id   : result.account_id
      mod_repo     : result.mod_repo
      mod_tag      : result.mod_tag
      state        : result.state
      has_cred     : result.has_cred


  ApiRequestDefs.autoFill = ( paramter_name )->
    switch paramter_name
      when "username"
        return $.cookie('username')
      when "usercode"
        return $.cookie('usercode')
      when "session_id"
        return $.cookie('session_id')
    return null

  ApiRequestDefs
