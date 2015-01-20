
###
----------------------------
  User is a model containing user's data. Nothing more, nothing less.
  Currently most of the data is stored in cookie. But in the future,
  it might just fetch user data at the beginning.
----------------------------
###

define [ "ApiRequest", "backbone", "crypto" ], ( ApiRequest )->

  UserState =
    NotFirstTime : 2

  Backbone.Model.extend {

    initialize : ()->
      @set {
        usercode     : $.cookie "usercode"
        username     : Base64.decode $.cookie "usercode"
        session      : $.cookie "session_id"
      }
      return

    #isFirstVisit   : ()-> !(UserState.NotFirstTime&@get("state"))
    fullnameNotSet : ()-> !@get("firstName") or !@get("lastName")

    userInfoAccuired : ( result )->
      @set {
        email        : Base64.decode result.email
        state        : parseInt result.state, 10
        intercomHash : result.intercom_hash
        firstName    : Base64.decode( result.first_name || "" )
        lastName     : Base64.decode( result.last_name || "")

        # No time to fix this.. Hard code it here.
        repo         : "https://github.com/MadeiraCloud/salt.git"
        tag          : "v2014-07-18"
      }

      # Set user to already used IDE, so that next time we don't show welcome
      # if @isFirstVisit()
      #   ApiRequest("account_update_account", { attributes : {
      #     state : "" + (@get("state")|UserState.NotFirstTime)
      #   } })

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
        widget    : {'activator':'#support'}
      }
      return

    fetch : ()->
      self = @

      ApiRequest("session_login", {
        username : @get("username")
        password : @get("session")
      }).then ( result )->

        self.userInfoAccuired( result )
        ### env:prod ###
        self.bootIntercom()
        ### env:prod:end ###
        return

      , ( err )->

        # We might want to do some error handling here.
        # If any error occurs while fetching user infomation. It might because the server is down or somthing.
        # But we should we do?

        if err.error < 0
          if err.error is ApiRequest.Errors.Network500
            # Server down
            # Actually this logic should be done in Application, not in User
            # But we don't have a unified api to get the user's global data,
            # thus the Application do no fetching.
            # So we can only handle this situation here.
            # TODO : Maybe we should move this to ApiRequest's global handling.
            window.location = "/500"
          else
            # Network Error, Try reloading
            window.location.reload()
        else
          # If there's service error. I think we need to logout, because I guess it's because the session is not right.
          App.logout()

        throw err

    # Send a request to acquire a new session
    acquireSession : ( password )->
      ApiRequest("session_login", {
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
      domain = { "domain" : window.location.hostname.replace("ide", ""), "path" : "/" }
      def    = { "path" : "/" }
      for ckey, cValue of $.cookie()
        $.removeCookie ckey, domain
        $.removeCookie ckey, def
      return

    changePassword : ( oldPwd, newPwd )->
      ApiRequest("account_update_account", { attributes : {
        password     : oldPwd
        new_password : newPwd
      }})

    changeEmail : ( email, oldPwd )->
      self = @
      ApiRequest("account_update_account", { attributes : {
        password : oldPwd
        email    : email
      }}).then ()-> self.set("email", email)

    changeName : ( firstName, lastName )->
      self = @
      defer = new Q.defer()
      if firstName is self.get("firstName") and lastName is self.get("lastName")
        defer.resolve()
      ApiRequest("account_update_account", { attributes : {
        first_name : firstName
        last_name  : lastName
      }}).then ( res )->
        self.userInfoAccuired( res )
        defer.resolve(res)
      , (err)->
        defer.reject(err)

      defer.promise

    gravatar: ->
      email = CryptoJS.MD5(@get("email").trim().toLowerCase()).toString()
      "https://www.gravatar.com/avatar/#{email}"

  }
