
###
----------------------------
  User is a model containing user's data. Nothing more, nothing less.
  Currently most of the data is stored in cookie. But in the future,
  it might just fetch user data at the beginning.
----------------------------
###

define [ "ApiRequest", "backbone" ], ( ApiRequest )->

  UserState =
    FirstLogin : 1

  Backbone.Model.extend {

    initialize : ()->
      @set {
        unfetched : true
        session   : $.cookie "session_id"
      }
      return

    hasAccount : ()-> !!@get("account")

    userInfoAccuired : ( result )->
      res =
        username     : MC.base64Decode result.usercode
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

    # Fetch additional user infomation from an api.
    fetch : ()->
      ApiRequest("login", {
        username : $.cookie "session_id"
        password : null
      }).then ( result )=>
        @unset "unfetched"
        @userInfoAccuired( result )
      , ( err )->
        # We might want to do some error handling here.
        # If any error occurs while fetching user infomation. It might because the server is down or somthing.
        # But we should we do?
        throw err

    # Send a request to acquire a new session
    acquireSession : ( password )->
      ApiRequest("login", {password:password}).then ( result )=>

        $.cookie "session_id", result.session_id, {
          expires : 30
          path    : '/'
        }

        # When the User fails to fetch additional user info at the beginning, due to Invalid Session.
        # We will have an empty session. In this case, we do a full reload instead of updating resources.
        if @get("unfetched")
          window.location.reload()
          return

        @set "session", result.session_id
        @userInfoAccuired( result )

        @trigger "SessionUpdated"
        return

  }
