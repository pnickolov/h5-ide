
###
----------------------------
  User is a model containing user's data. Nothing more, nothing less.
  Currently most of the data is stored in cookie. But in the future,
  it might just fetch user data at the beginning.
----------------------------
###

define [ "ApiRequest", "backbone" ], ( ApiRequest )->

  UserState =
    NotFirstTime : 2

  Backbone.Model.extend {

    initialize : ()->
      @set {
        usercode  : $.cookie "usercode"
        username  : MC.base64Decode $.cookie "usercode"
        session   : $.cookie "session_id"
      }
      return

    hasCredential : ()-> !!@get("account")
    isFirstVisit  : ()-> !(UserState.NotFirstTime&@get("state"))

    userInfoAccuired : ( result )->
      res =
        email        : MC.base64Decode result.email
        repo         : result.mod_repo
        tag          : result.mod_tag
        state        : parseInt result.state, 10
        intercomHash : result.user_hash

      if result.account_id is "demo_account"
        res.account = ""
      else
        res.account = result.account_id

      @set res

    bootIntercom : ()->
      if not window.Intercom
        intId = setInterval ()=>
          if window.Intercom
            console.log "Intercom Loaded, Booting Intercom"
            clearInterval( intId )
            @bootIntercom()
          return
        , 1000
        return

      window.Intercom "boot", {
        app_id    : "3rp02j1w"
        email     : @get("email")
        username  : @get("username")
        user_hash : @get("intercomHash")
        widget    : {'activator' : '#feedback'}
      }
      return

    # Fetch additional user infomation from an api.
    fetch : ()->
      ApiRequest("login", {
        password : @get("session")
      }).then ( result )=>

        @userInfoAccuired( result )
        ### env:prod ###
        @bootIntercom()
        ### env:prod:end ###

      , ( err )->

        # We might want to do some error handling here.
        # If any error occurs while fetching user infomation. It might because the server is down or somthing.
        # But we should we do?

        if err.error < 0
          # Network Error, Try reloading
          window.location.reload()
        else
          # If there's service error. I think we need to logout, because I guess it's because the session is not right.
          App.logout()

        throw err

    # Send a request to acquire a new session
    acquireSession : ( password )->
      ApiRequest("login", {password:password}).then ( result )=>

        $.cookie "session_id", result.session_id, {
          expires : 30
          path    : '/'
        }

        @set "session", result.session_id
        @userInfoAccuired( result )

        @trigger "SessionUpdated"
        return

    logout : ()->
      domain = { "domain" : window.location.hostname.replace("ide", "") }
      for ckey, cValue of $.cookie()
        $.removeCookie ckey, domain
        $.removeCookie ckey
      return

    changePassword : ( oldPwd, newPwd )->
      ApiRequest "changePwd", { params : {
        password     : oldPwd
        new_password : newPwd
      }}

  }
