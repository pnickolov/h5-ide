
###
----------------------------
  User is a model containing user's data. Nothing more, nothing less.
  Currently most of the data is stored in cookie. But in the future,
  it might just fetch user data at the beginning.
----------------------------
###

define [ "ApiRequest", "ApiRequestR", "backbone" ], ( ApiRequest, ApiRequestR )->

  UserState =
    NotFirstTime : 2

  PaymentState =
    NoInfo  : ""
    Pastdue : "pastdue"
    Unpaid  : "unpaid"
    Active  : "active"

  Model = Backbone.Model.extend {

    defaults :
      paymentState    : "" # "" || "pastdue" || "unpaid" || "active"
      voQuotaPerMonth : 1000
      voQuotaCurrent  : 0

    initialize : ()->
      @set {
        usercode     : $.cookie "usercode"
        username     : Base64.decode $.cookie "usercode"
        session      : $.cookie "session_id"
      }
      return

    hasCredential : ()-> !!@get("account")
    isFirstVisit  : ()-> !(UserState.NotFirstTime&@get("state"))

    fullnameNotSet : ()-> !@get("firstName") or !@get("lastName")
    isUnpaid       : ()-> @get("paymentState") is PaymentState.Unpaid

    shouldPay      : ()-> ( @get("voQuotaCurrent") >= @get("voQuotaPerMonth") ) and ( not @get("creditCard") or @isUnpaid() )

    getBillingOverview : ()->

      ov =
        quotaTotal   : @get("voQuotaPerMonth")
        quotaCurrent  : @get("voQuotaCurrent")

        billingStart  : @get("billingStart")
        billingEnd    : @get("billingEnd")
        billingRemain : Math.round( (@get("billingEnd") - new Date()) / 24 / 3600000 )

      ov.quotaRemain = Math.max((ov.quotaTotal - ov.quotaCurrent), 0)
      ov.billingRemain = Math.min( ov.billingRemain, 31 )
      ov.billingRemain = Math.max( ov.billingRemain, 0 )
      ov.quotaPercent = Math.round(Math.min(ov.quotaCurrent, ov.quotaTotal)/Math.max(ov.quotaCurrent, ov.quotaTotal) * 100)

      ov

    userInfoAccuired : ( result )->
      paymentInfo = result.payment || {}
      selfPage    = paymentInfo.self_page || {}

      res =
        email           : Base64.decode result.email
        repo            : result.mod_repo
        tag             : result.mod_tag
        state           : parseInt result.state, 10
        intercomHash    : result.intercom_secret
        account         : result.account_id
        firstName       : Base64.decode( result.first_name || "" )
        lastName        : Base64.decode( result.last_name || "")
        cardFirstName   : Base64.decode( selfPage.first_name || "")
        cardLastName    : Base64.decode( selfPage.last_name || "")
        voQuotaCurrent  : paymentInfo.current_quota || 0
        voQuotaPerMonth : paymentInfo.max_quota || 3600
        has_card        : !!paymentInfo.has_card
        paymentUrl      : selfPage.url
        creditCard      : selfPage.card
        billingEnd      : new Date( selfPage.current_period_ends_at    || new Date() )
        billingStart    : new Date( selfPage.current_period_started_at || new Date() )
        renewDate       : if paymentInfo.next_reset_time then new Date(paymentInfo.next_reset_time * 1000 ) else new Date()
        paymentState    : paymentInfo.state || ""
        awsAccessKey    : result.access_key
        awsSecretKey    : result.secret_key
        tokens          : result.tokens || []
        defaultToken    : ""

      if result.account_id is "demo_account"
        res.account = res.awsAccessKey = res.awsSecretKey = ""

      for t, idx in res.tokens
        if not t.name
          res.defaultToken = t.token
          res.tokens.splice idx, 1
          break

      @set res

      # Set user to already used IDE, so that next time we don't show welcome
      if @isFirstVisit()
        ApiRequest("account_update_account", { attributes : {
          state : "" + (@get("state")|UserState.NotFirstTime)
        } })

      return

    onWsUserStateChange : ( changes )->
      console.log changes
      that = @
      paymentInfo = changes.payment
      if not changes then return
      attr =
        current_quota   : "voQuotaCurrent"
        max_quota       : "voQuotaPerMonth"
        has_card        : "creditCard"
        state           : "paymentState"

      changed = !!changes.time_update
      toChange = {}
      for key, value of attr
        if paymentInfo?.hasOwnProperty( key )
          changed = true
          toChange[ value ] = paymentInfo[ key ]

      if changed
        @set toChange

      if paymentInfo?.next_reset_time
        App.user.set("renewDate", new Date(paymentInfo.next_reset_time * 1000))

      if App.user.get("firstName") and App.user.get("lastName") then ApiRequestR("payment_self").then (result)->
        paymentInfo = {
          creditCard: result.card
          billingEnd: new Date(result.current_period_ends_at || null)
          billingStart: new Date(result.current_period_started_at || null)
          paymentUrl: result.url
          cardFirstName: if result.card then Base64.decode( result.first_name || "")
          cardLastName : if result.card then Base64.decode( result.last_name  || "" )
        }
        that.set paymentInfo
        that.trigger "paymentUpdate"

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

        if self.hasCredential()
          # Just pick a fast aws api to validate if the user's credential is valid before launching IDE.
          # Even if this method fails, ApiRequest will hanlde it for us. We would still launch IDE.
          return ApiRequest("ec2_DescribeRegions").fail ()-> return

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


    validateCredential : ( accessKey, secretKey )->
      ApiRequest("account_validate_credential", {
        access_key : accessKey
        secret_key : secretKey
      })

    changeCredential : ( account = "", accessKey = "", secretKey = "", force = false )->
      self = this
      ApiRequest("account_set_credential", {
        access_key   : accessKey
        secret_key   : secretKey
        account_id   : account
        force_update : force
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
        return

    createToken : ()->
      tmpl = "MyToken"
      base = 1
      nameMap = {}
      for t in @attributes.tokens
        nameMap[ t.name ] = true

      while true
        newName = tmpl + base
        if nameMap[ newName ]
          base += 1
        else
          break

      self = this
      ApiRequest("token_create", {token_name:newName}).then (res)->
        self.attributes.tokens.splice 0, 0, {
          name  : res[0]
          token : res[1]
        }
        return

    removeToken : (token)->
      for t, idx in @attributes.tokens
        if t.token is token
          break

      self = this
      ApiRequest("token_remove", {token:token,token_name:t.name}).then ( res )->
        idx = self.attributes.tokens.indexOf t
        if idx >= 0
          self.attributes.tokens.splice idx, 1
        return

    updateToken : ( token, newName )->
      self = this
      ApiRequest("token_update", {token:token, new_token_name:newName}).then ( res )->
        for t, idx in self.attributes.tokens
          if t.token is token
            t.name = newName
            break
        return
  }

  Model.PaymentState = PaymentState

  Model
