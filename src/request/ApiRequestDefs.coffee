
define [], ()->

  ###
  == Following name of the paramter is autofilled. Thus the paramter is not required.
  == It also means that you cannot use a param name if the param is for sth. else.
     For example, the param's name cannot be username, if it's used to represent Instance's Id.

  ** Auto Fill List :
  username
  password
  session_id
  ###


  ApiRequestDefs =
    login      : { url:"/session/", method:"login",  params:["username", "password"] }
    logout     : { url:"/session/", method:"logout", params:["username", "session_id"] }
    updateCred : { url:"/session/", method:"set_credential", params:["username","session_id","access_key","secret_key","account_id"] }
    sync_redis : { url:"/session/", method:"sync_redis", params:["username", "session_id"]}


  ApiRequestDefs.Parsers =
    login : ( result )->
      usercode    : result[0]
      email       : result[1]
      user_hash   : result[2]
      session_id  : result[3]
      account_id  : result[4]
      mod_repo    : result[5]
      mod_tag     : result[6]
      state       : result[7]
      has_cred    : result[8]


  ApiRequestDefs.autoFill = ( paramter_name )->
    switch paramter_name
      when "username"
        return $.cookie('usercode')
      when "session_id"
        return $.cookie('session_id')
    return null

  ApiRequestDefs
