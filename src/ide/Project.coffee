
define [
  "ApiRequest"
  "ProjectLog"
  "ide/submodels/OpsCollection"
  "OpsModel"
  "Credential"
  "ApiRequestR"
  "constant"
  "backbone"
], ( ApiRequest, ProjectLog, OpsCollection, OpsModel, Credential, ApiRequestR, constant )->

  ###
  # One-time initializer to observe the websocket. Since the websocket is not
  # available during the defination of the class
  ###
  tenSecCheckTimer = {}
  clearTenSecCheck = ( id )->
    if tenSecCheckTimer[id]
      console.info "tenSecCheckTimer removed:", id
      clearTimeout( tenSecCheckTimer[id] )
      delete tenSecCheckTimer[id]
    return

  OneTimeWsInit = ()->
    OneTimeWsInit = ()-> return

    App.WS.collection.project.find().observe {
      # added   : ()-> # Ignored. Server doesn't return add event.
      changed : ( newDocument, oldDocument )-> App.model.projects().get( newDocument.id )?.updateWithWsData( newDocument )
      removed : ( oldDocument )->
        if not oldDocument then return
        console.info "Project has been removed", oldDocument
        App.model.projects().get( oldDocument.id )?.cleanup()
        return
    }

    App.WS.collection.history.find().observe {
      added : ( newDocument )->
        if not newDocument then return
        project = App.model.projects().get( newDocument.project_id )
        if not project
          console.log "There's an audit that is not related to any project, ignored.", newDocument
          return

        project.logs().unshift newDocument
        return

      # changed : ()-> # Ignored
      # removed : ()-> # Ignored
    }


    tenSecCheck = ( col, attr, wsdata, retry )->
      # Remove timer
      delete tenSecCheckTimer[wsdata.id]

      # The stack already exist. Ignore.
      if col.get(wsdata.id) then return

      # There's no sign of the model, we determine that this model is created by other
      if not col.findWhere(attr)
        console.log "[WS Add] The ops doesn't exist, add to collection", wsdata, col
        col.add( new OpsModel( wsdata ) )
        return

      if retry is 5
        console.warn "[WS Add] Fail to determine the ops after 5 reties, ignoring.", wsdata
        return

      console.log "[WS Add] Cannot determine the ops, retry in 2 sec.", wsdata
      sheduleTenSecCheck( col, attr, wsdata, retry + 1, 2000 )
      return

    sheduleTenSecCheck = ( col, attr, wsdata, retry, deplay )->
      tenSecCheckTimer[ wsdata.id ] = setTimeout (()->tenSecCheck( col, attr, wsdata, retry )), deplay
      return

    App.WS.collection.stack.find().observe {
      added : ( newDocument )->
        if not newDocument or not App.WS.isSubReady( newDocument.project_id, "stack" ) then return
        project = App.model.projects().get( newDocument.project_id )
        if not project
          console.log "Adding a stack that is not related to any project, ignored.", newDocument
          return

        wsdata = project.__parseListRes([newDocument])[0]
        # Set 1sec timeout to reduce the check time.
        # Since the first check will always fail.
        sheduleTenSecCheck( project.stacks(), {
          name     : wsdata.name
          provider : wsdata.provider
          region   : wsdata.region
          state    : OpsModel.State.Saving
        }, wsdata, 0, 1000 )
        return
      changed : ( newDocument )->
        if not newDocument or not App.WS.isSubReady( newDocument.project_id, "stack" ) then return
        project = App.model.projects().get( newDocument.project_id )
        if not project
          console.log "Changing a stack that is not related to any project, ignored.", newDocument

        project.stacks().get( newDocument.id )?.set( "name", newDocument.name )
        return

      removed : ( newDocument )->
        if not newDocument or not App.WS.isSubReady( newDocument.project_id, "stack" ) then return
        project = App.model.projects().get( newDocument.project_id )
        if not project
          console.log "Removing a stack that is not related to any project, ignored.", newDocument
          return

        # Use private api to destroy the stack directly.
        project.stacks().get( newDocument.id )?.__destroy()
        return
    }

    App.WS.collection.app.find().observe {
      added : ( newDocument )->
        if not newDocument or not App.WS.isSubReady( newDocument.project_id, "app" ) then return
        project = App.model.projects().get( newDocument.project_id )
        if not project
          console.log "There's an app that is not related to any project, ignored.", newDocument
          return

        wsdata = project.__parseListRes([newDocument])[0]
        # Set time 1sec timeout to reduce the check time.
        # Since the first check will always fail.
        sheduleTenSecCheck( project.apps(), {
          name     : wsdata.name
          provider : wsdata.provider
          region   : wsdata.region
          state    : OpsModel.State.Initializing
        }, wsdata, 0, 1000 )
        return

      changed : ( newDocument )->
        if not newDocument or not App.WS.isSubReady( newDocument.project_id, "app" ) then return
        project = App.model.projects().get( newDocument.project_id )
        if not project
          console.log "There's an app that is not related to any project that is changed, ignored.", newDocument
          return

        # Do not update app's state when app subscription changed.
        # Because the app's state is handled via request subscription.
        project.apps().get( newDocument.id )?.set("name", newDocument.name)
        return

      removed : ( newDocument )->
        if not newDocument or not App.WS.isSubReady( newDocument.project_id, "app" ) then return
        project = App.model.projects().get( newDocument.project_id )
        if not project
          console.log "There's an app that is not related to any project that is removed. ignored.", newDocument
          return

        # Cannot immediately remove the app when we received the event.
        # If the app fails to run, we would like to know the reason from the request event.
        app = project.apps().get( newDocument.id )
        if app
          if app.testState( OpsModel.State.RollingBack )
            # When the app fails to launch ( or maybe fail to update? ) we will destroy the app in 5sec,
            # if request event never come.
            setTimeout (()->app.__destroy()), 5000
          else
            app.__destroy()
        return
    }

    handleRequest = ( req )->
      if not req.project_id or req.state is constant.OPS_STATE.PENDING then return

      if req.state is constant.OPS_STATE.DONE and ( req.code is constant.OPS_CODE_NAME.APP_SAVE or req.code is constant.OPS_CODE_NAME.APP_IMPORT )
        targetId = req.data
      else
        targetId = if req.dag and req.dag.spec then req.dag.spec.id else req.rid

      ###
      # Update the corresponding opsmodel.
      ###
      # only updates when WS has finished pushing the initial data.
      if not App.WS.isSubReady( req.project_id, "request" ) then return

      TGT = App.model.projects().get( req.project_id )
      if not TGT then return
      TGT = TGT.apps().get( targetId ) or TGT.apps().findWhere({requestId:req.id})
      if not TGT then return
      if not TGT.id and targetId
        TGT.set "id", targetId
      TGT.updateWithWSEvent( req )
      return

    App.WS.collection.request.find().observe {
      added   : handleRequest
      changed : handleRequest
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
      logs         : new ProjectLog.Collection()
      members      : null
      myRole       : "observer"
      private      : false
      billingState : ""

    constructor : ( attr )->
      Backbone.Model.apply this

      # Normal attr
      @set {
        id      : attr.id
        name    : attr.name or "My Workspace"
        private : attr.id is App.user.id
        billingState: attr.payment?.state
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

      @listenTo @stacks(), "change",   ()-> @trigger "change:stack"
      @listenTo @stacks(), "change:id",()-> @trigger "update:stack"
      @listenTo @stacks(), "add",      ()-> @trigger "update:stack"
      @listenTo @stacks(), "remove",   (o)-> clearTenSecCheck(o.id); @trigger "update:stack"

      @listenTo @apps(), "change", ()-> @trigger "change:app"
      @listenTo @apps(), "add",    ()-> @trigger "update:app"
      @listenTo @apps(), "remove", (o)-> clearTenSecCheck(o.id); @trigger "update:app"

      # Ask Websocket to watch changes for this project
      App.WS.subscribe( @id )

      OneTimeWsInit()
      return


    # Getters.
    stacks       : ()-> @get("stacks")
    apps         : ()-> @get("apps")
    credentials  : ()-> @get("credentials")
    logs         : ()-> @get("logs")
    tokens       : ()-> @get("tokens")
    defaultToken : ()-> @get("defaultToken")

    getOpsModel  : ( id )-> @get("stacks").get( id ) or @get("apps").get( id )

    url : ()-> "workspace/" + @get("id")
    showCredential: ()-> App.loadUrl "/settings/#{@get("id")}/credential"


    # Convenient Methods
    isPrivate        : ()-> @get("private")
    hasCredential    : ()-> console.log @get("credentials"); @get("credentials").length > 0
    credIdOfProvider : ( CredentialProvider )-> (@credOfProvider( CredentialProvider ) || {}).id
    credOfProvider   : ( CredentialProvider )->
      for cred in @get("credentials").models
        if cred.get("provider") is CredentialProvider
          return cred
      return null

    # Project Payment
    shouldPay       : ()-> not (@get("billingState") in ["active", "pastdue"])

    amIAdmin    : ()-> @get("myRole") is MEMBERROLE.ADMIN or @isPrivate()
    amIMeber    : ()-> @get("myRole") is MEMBERROLE.MEMBER
    amIObserver : ()-> @get("myRole") is MEMBERROLE.OBSERVER

    isDemoMode: ( provider = Credential.PROVIDER.AWSGLOBAL ) ->
      cred = @credentials().findWhere provider: provider
      cred and cred.isDemo() or false

    updateName: ( name ) ->
      model = @
      ApiRequest( "project_rename", { project_id: @id, spec: { name: name } } ).then ( res ) ->
        model.set 'name', name
        res

    destroy: () ->
      self = @
      @__manualDestroy = true
      ApiRequest( "project_remove", { project_id: @id } ).then ( res )->
        self.cleanup()
        res
      , ( err )->
        self.__manualDestroy = false
        throw err

    cleanup : ()->
      if @__isRemoved then return
      @__isRemoved = true
      @trigger "destroy", @, @collection, { manualAction : !!@__manualDestroy }
      App.WS.unsubscribe( @id )
      return

    leave: ->
      that = @
      @__manualDestroy = true
      ApiRequest( "project_remove_members", {
        project_id: @id
        member_ids: [ App.user.id ]
      }).then ( res ) ->
        that.cleanup()
        res
      , ( err )->
        self.__manualDestroy = false
        throw err

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

    createAppByExistingResource : ( resourceId, region, provider = Credential.PROVIDER.AWSGLOBAL )->
      @apps().findWhere({importMsrId:resourceId}) || @apps().add( new OpsModel({
        name        : "ImportedApp"
        importMsrId : resourceId
        region      : region
        provider    : provider
        state       : OpsModel.State.Running
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
          unlimited  : ops.before_charge
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
        formattedResult.renewDays = (Math.round (new Date(formattedResult.nextPeriod) - new Date())/(24*3600*1000))
        formattedResult.isDefault = that.isPrivate()
        formattedResult.failToCharge = that.shouldPay()
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

      if wsdata.payment
        @set "billingState", wsdata.payment.state

      # To many if here.. Many have bug..
      if wsdata.credentials
        creds = {}
        for cred in wsdata.credentials
          if @credentials().get(cred.id)
            @credentials().get(cred.id).set "isDemo", cred.is_demo
          else
            @credentials.add cred, {project:@}

          creds[ cred.id ] = true

        for cred in @credentials().models.slice(0)
          if not creds[ cred.id ]
            @credentials().remove( cred )
      return

  }, {
    MEMBERROLE : MEMBERROLE
  }
