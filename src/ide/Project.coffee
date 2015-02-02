
define [
  "ApiRequest"
  "ide/submodels/OpsCollection"
  "ide/settings/projectSubModels/MemberCollection"
  "OpsModel"
  "Credential"
  "ApiRequestR"
  "backbone"
], ( ApiRequest, OpsCollection, MemberCollection, OpsModel, Credential, ApiRequestR )->

  ###
  # One-time initializer to observe the websocket. Since the websocket is not
  # available during the defination of the class
  ###
  OneTimeWsInit = ()->
    OneTimeWsInit = ()-> return

    App.WS.collection.project.find().observe {
      # added : ()-> # Ignored
      changed : ( newDocument, oldDocument )-> App.model.projects().get( newDocument.id ).updateWithWsData( newDocument )
      removed : ( oldDocument )->
        if not oldDocument then return
        console.info "Project has been removed", oldDocument
        App.model.projects().get( oldDocument.id ).cleanup()
        return
    }
    return


  MEMBERROLE =
    ADMIN    : "admin"
    MEMBER   : "collaborator"
    OBSERVER : "observer"


  Backbone.Model.extend {

    ###
    # Possible events that will trigger on this model:
    `change:credential` :
        Convenient event for someone that is interested in the credentials of the project.
        Fires when one of the credential of this project is updated.
    `update:credential` :
        Fires when credential is added / removed.

    `change:app` :
        Convenient event for someone that is interested in the apps of the project.
        Fires when one of the app is updated. The same as listen to the change event of the app collection.
    `update:app` :
        Fires when app is added / removed.

    `change:stack`
        Convenient event for someone that is interested in the stacks of the project.
        Fires when one of the stack is updated. The same as listen to the change event of the stacks collection.
    `update:stack`
        Fires when stack is added / removed.

    ###
    defaults : ()->
      name         : ""
      tokens       : []
      credentials  : new Credential.Collection()
      stacks       : new OpsCollection()
      apps         : new OpsCollection()
      history      : new Backbone.Collection()
      audits       : new Backbone.Collection()
      members      : null
      myRole       : "observer"
      private      : false
      billingState : ""

    constructor : ( attr )->
      Backbone.Model.apply this

      # Normal attr
      @set {
        id      : attr.id
        name    : attr.name or "Free Workspace"
        private : !attr.name
        members : new MemberCollection({projectId: attr.id})
      }

      # Token
      for t, idx in attr.tokens || []
        if not t.name
          @attributes.defaultToken = t.token
        else
          @attributes.tokens.push t

      # Credential
      @credentials().set attr.credentials, { project:@, silent:true }
      @listenTo @credentials(), "change", ()-> @trigger "change:credential"
      @listenTo @credentials(), "add",    ()-> @trigger "update:credential"
      @listenTo @credentials(), "remove", ()-> @trigger "update:credential"

      # Check my role
      @__checkMyRole( attr.members )

      # Stack / App
      @stacks().set @__parseListRes( attr.stacks or [] )
      @apps().set   @__parseListRes( attr.apps or [] )

      @listenTo @stacks(), "change", ()-> @trigger "change:stack"
      @listenTo @stacks(), "add",    ()-> @trigger "update:stack"
      @listenTo @stacks(), "remove", ()-> @trigger "update:stack"

      @listenTo @apps(), "change", ()-> @trigger "change:app"
      @listenTo @apps(), "add",    ()-> @trigger "update:app"
      @listenTo @apps(), "remove", ()-> @trigger "update:app"

      # Ask Websocket to watch changes for this project
      App.WS.subscribe( @id )

      OneTimeWsInit()
      return


    # Getters.
    stacks       : ()-> @get("stacks")
    apps         : ()-> @get("apps")
    credentials  : ()-> @get("credentials")
    history      : ()-> @get("history")
    audits       : ()-> @get("audits")
    tokens       : ()-> @get("tokens")
    defaultToken : ()-> @get("defaultToken")

    getOpsModel  : ( id )-> @get("stacks").get( id ) or @get("apps").get( id )

    url : ()-> "project/" + @get("id")


    # Convenient Methods
    isPrivate        : ()-> @get("private")
    hasCredential    : ()-> @get("credentials").length > 0
    credIdOfProvider : ( CredentialProvider )-> (@credOfProvider( CredentialProvider ) || {}).id
    credOfProvider   : ( CredentialProvider )->
      for cred in @get("credentials").models
        if cred.get("provider") is CredentialProvider
          return cred
      return null

    # Project Payment
    shouldPay       : ()-> @get("billingState") in ["active", "pastdue"]

    amIAdmin    : ()-> @get("myRole") is MEMBERROLE.ADMIN or @isPrivate()
    amIMeber    : ()-> @get("myRole") is MEMBERROLE.MEMBER
    amIObserver : ()-> @get("myRole") is MEMBERROLE.OBSERVER


    updateName: ( name ) ->
      model = @
      ApiRequest( "project_save", { project_id: @id, spec: { name: name } } ).then ( res ) ->
        model.set 'name', name
        res

    destroy: ( options ) ->
      self = @
      ApiRequest( "project_remove", { project_id: @id } ).then ( res )-> self.cleanup( options ); res

    cleanup : ( options )->
      if @__isRemoved then return
      @__isRemoved = true
      @trigger "destroy", @, @collection, options
      App.WS.unsubscribe( @id )
      return

    leave: ->
      ApiRequest( "project_remove_members", { project_id: @id, member_ids: [ App.user.get("usercode") ] })



    # createImportOps : ( region, provider, msrId )->
    #   m = @attributes.appList.findWhere({importMsrId:msrId})
    #   if m then return m
    #   m = new OpsModel({
    #     name        : "ImportedApp"
    #     importMsrId : msrId
    #     region      : region
    #     provider    : provider
    #     state       : OpsModel.State.Running
    #   })
    #   @attributes.appList.add m
    #   m


    # OpsModel Related.

    # This method creates a new stack in IDE, and returns that model.
    # The stack is not automatically stored in server.
    # You need to call save() after that.
    createStack : ( region, provider = Credential.PROVIDER.AWSGLOBAL )->
      @stacks().add new OpsModel({
        region   : region
        provider : provider
      })

    createStackByJson : ( json, updateLayout = false )->
      @stacks().add( new OpsModel({
        name       : json.name
        region     : json.region
        autoLayout : updateLayout
        __________itsshitdontsave : updateLayout
      }, {
        jsonData : json
      }) )

    __parseListRes : ( res )->
      r = []

      for ops in res
        r.push {
          id         : ops.id
          updateTime : ops.time_update
          region     : ops.region
          usage      : ops.usage
          name       : ops.name
          version    : ops.version
          provider   : ops.provider
          state      : OpsModel.State[ ops.state ] || OpsModel.State.UnRun
          stoppable  : not (ops.property and ops.property.stoppable is false)
        }
      r

    getPaymentState: ()->
      that = @
      projectId = @get "id"
      ApiRequestR "payment_self", {projectId}
      .then (result)->
        formattedResult = {
          email       : result.email
          cardNumber  : result.card
          lastName    : result.last_name
          firstName   : result.first_name
          periodEnd   : result.current_period_ends_at
          periodStart : result.current_period_started_at
          maxQuota    : result.max_quota
          currentQuota: result.current_quota
          nextPeriod  : result.next_assessment_at
          paymentState: result.state
        }
        formattedResult.renewDays = (Math.round (new Date(formattedResult.nextPeriod) - new Date())/(24*3600*100))/10
        formattedResult.isDefault = that.get("name") is "Default Project"
        that.set("payment", formattedResult)
        return formattedResult

    __checkMyRole : ( members )->
      id = App.user.id
      for m in members || []
        if m.id is id
          @set "myRole", m.role
          return

    updateWithWsData : ( wsdata )->
      if wsdata.name
        @set "name", wsdata.name
      if wsdata.members
        @__checkMyRole( wsdata.members )
      if wsdata.credentials
        creds = {}
        for cred in wsdata.credentials
          if not @credentials().get( cred.id )
          creds[cred.id] = cred

        for cred in @credentials().models.slice(0)
          if creds[ cred.id ]
            cred.set "isDemo", creds[ cred.id ]
          else
            @credentials().remove( cred )
      return

  }, {
    MEMBERROLE : MEMBERROLE
  }
