
define [], ()->

  ApiRequestDefs =
    login      : { url:"/session/", method:"login", params:["username", "password"] }
    logout     : { url:"/session/", method:"logout", params:["username", "session_id"] }
    updateCred : { url:"/session/", method:"set_credential", params:["username", "session_id","access_key","secret_key","account_id"] }


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


  ApiRequestDefs
