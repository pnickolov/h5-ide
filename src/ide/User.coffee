
###
----------------------------
  User is a model containing user's data. Nothing more, nothing less.
  Currently most of the data is stored in cookie. But in the future,
  it might just fetch user data at the beginning.
----------------------------
###

define [ "ApiRequest", "event" , "backbone" ], ( ApiRequest, ide_event )->

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
        intercomHash : result.intercom_secret
        account      : result.account_id
        awsAccessKey : result.access_key
        awsSecretKey : result.secret_key

      if result.account_id is "demo_account"
        res.account = ""
      else
        res.account = result.account_id

      @set res

      # Set user to already used IDE, so that next time we don't show welcome
      if @isFirstVisit()
        ApiRequest("updateAccount", { params : {
          state : @get("state")|UserState.NotFirstTime
        } })

      return


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
        username : @get("username")
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
      ApiRequest("login", {
        username : @get("username")
        password : password
      }).then ( result )=>

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

    validateCredential : ( accessKey, secretKey )->
      ApiRequest("validateCred", {
        access_key : accessKey
        secret_key : secretKey
      })

    changeCredential : ( account = "", accessKey = "", secretKey = "", force = false )->
      self = this
      ApiRequest("updateCred", {
        access_key : accessKey
        secret_key : secretKey
        account_id : account
        force : force
      }).then ()->
        attr =
          account      : account
          awsAccessKey : accessKey
          awsSecretKey : secretKey

        if attr.awsAccessKey.length > 6
          attr.awsAccessKey = (new Array(accessKey.length-6)).join("*")+accessKey.substr(-6)
        if attr.awsSecretKey.length > 6
          attr.awsSecretKey = (new Array(secretKey.length-6)).join("*")+secretKey.substr(-6)

        self.set attr

        self.trigger "change:credential"

        # LEGACY code, trigger an ide event when credential is updated.
        ide_event.trigger ide_event.UPDATE_AWS_CREDENTIAL
        return
  }
