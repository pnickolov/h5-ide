
define [
  "./submodels/OpsCollection"
  "./Credential"
  "backbone"
], ( OpsCollection )->

  Backbone.Model.extend {

    ###
    # Possible events that will trigger on this model:

    `change:credential`
    ###
    defaults : ()->
      name         : ""
      tokens       : []
      billingState : ""
      history      : new Backbone.Collection()
      audits       : new Backbone.Collection()

    initialize : ( attr )->
      # Credential
      self = @
      @attributes.credential = new Credential( attr.credential )
      @listenTo @attributes.credential "change", ()-> self.trigger("change:credential")

      # App / Stack
      @attributes.stacks = new OpsCollection()
      @attributes.apps   = new OpsCollection()

      # Token
      for t, idx in attr.tokens
        if not t.name
          @attributese.defaultToken = t.token
          attr.tokens.splice idx, 1
          break
      @attributes.tokens = attr.tokens
      return

    # Getters.
    stacks       : ()-> @get("stacks")
    apps         : ()-> @get("apps")
    credential   : ()-> @get("credential")
    history      : ()-> @get("history")
    audits       : ()-> @get("audits")
    tokens       : ()-> @get("tokens")
    defaultToken : ()-> @get("defaultToken")


    # Token related. Unlike credential,
    # token is managed through project object. Since they are really lightweight.
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

    removeToken : (token)->
      for t, idx in @attributes.tokens
        if t.token is token
          break

      self = this
      ApiRequest("token_remove", {token:token,token_name:t.name}).then ( res )->
        idx = self.attributes.tokens.indexOf t
        if idx >= 0
          self.attributes.tokens.splice idx, 1

    updateToken : ( token, newName )->
      self = this
      ApiRequest("token_update", {token:token, new_token_name:newName}).then ( res )->
        for t, idx in self.attributes.tokens
          if t.token is token
            t.name = newName
            break
  }
