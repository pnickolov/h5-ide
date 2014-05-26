
###
----------------------------
  This is the core / entry point / controller of the whole IDE.
----------------------------

  It contains some basical logics to maintain the IDE. And it holds other components
  to provide other functionality
###

define [
  "./Websocket"
  "./ApplicationView"
  "./ApplicationModel"
  "./User"
  "./subviews/SettingsDialog"
  "CloudResources"
  "./WorkspaceManager"
  "module/DesignEditor"
  "component/exporter/JsonExporter"
  "common_handle",
  "event",
  "vpc_model",
  "constant",
  "underscore"
], ( Websocket, ApplicationView, ApplicationModel, User, SettingsDialog, CloudResources, WorkspaceManager, DesignEditor, JsonExporter, common_handle, ide_event, vpc_model, constant )->

  VisualOps = ()->
    if window.App
      console.error "Application is already created."
      return

    window.App = this
    return

  # initialize returns a promise that will be resolve when the application is ready.
  VisualOps.prototype.initialize = ()->

    @__createUser()
    @__createWebsocket()

    @workspaces = new WorkspaceManager()

    # view / model depends on User and Websocket
    @model  = new ApplicationModel()
    @__view = new ApplicationView()

    # This function returns a promise
    Q.all [ @user.fetch(), @model.fetch() ]


  VisualOps.prototype.__createWebsocket = ()->
    @WS = new Websocket()

    @WS.on "Disconnected", ()=> @acquireSession()

    @WS.on "StatusChanged", ( isConnected )=>
      console.info "Websocket Status changed, isConnected:", isConnected
      @__view.toggleWSStatus( isConnected )

    return


  VisualOps.prototype.__createUser = ()->
    @user = new User()

    @user.on "SessionUpdated", ()=>
      # Legacy Code
      ide_event.trigger ide_event.UPDATE_APP_LIST
      ide_event.trigger ide_event.UPDATE_DASHBOARD

      # The Websockets subscription will be lost if we have an invalid session.
      @WS.subscribe()

    @user.on "change:credential", ()=>
      @__onCredentialChanged()
      CloudResources.invalidate()
    return


  # LEGACY code
  # Well, first of all. The "DescribeAccountAttributes" is no longer needed because we only support vpc now. And it seems like all we have to do is to call `vpc_model.DescribeAccountAttributes`
  # Second. Forget it, just a piece of shit.
  VisualOps.prototype.__onCredentialChanged = ()->
    # check credential
    vpc_model.DescribeAccountAttributes { sender : vpc_model }, App.user.get( 'usercode' ), App.user.get( 'session' ), '',  ["supported-platforms", "default-vpc"]

    vpc_model.once 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN', (result) ->
      console.log 'VPC_VPC_DESC_ACCOUNT_ATTRS_RETURN'

      if result.is_error then return

      # update account attributes
      regionAttrSet = result.resolved_data
      _.map constant.REGION_KEYS, ( value ) ->
        if regionAttrSet[ value ] and regionAttrSet[ value ].accountAttributeSet

          #resolve support-platform
          support_platform = regionAttrSet[ value ].accountAttributeSet.item[0].attributeValueSet.item
          if support_platform and $.type(support_platform) == "array"
            if support_platform.length == 2
              MC.data.account_attribute[ value ].support_platform = support_platform[0].attributeValue + ',' + support_platform[1].attributeValue
            else if support_platform.length == 1
              MC.data.account_attribute[ value ].support_platform = support_platform[0].attributeValue

          #resolve default-vpc
          default_vpc = regionAttrSet[ value ].accountAttributeSet.item[1].attributeValueSet.item
          if  default_vpc and $.type(default_vpc) == "array" and default_vpc.length == 1
            MC.data.account_attribute[ value ].default_vpc = default_vpc[0].attributeValue
          null


  # This method will prompt a dialog to let user to re-acquire the session
  VisualOps.prototype.acquireSession = ()->
    # LEGACY code
    # Seems like in the old days, someone wants to swtich to dashboard.
    ide_event.trigger ide_event.SWITCH_MAIN
    @__view.showSessionDialog()

  VisualOps.prototype.logout = ()->
    App.user.logout()
    window.location.href = "/login/"
    return

  VisualOps.prototype.showSettings = ( tab )-> new SettingsDialog({ defaultTab:tab })
  VisualOps.prototype.showSettings.TAB = SettingsDialog.TAB


  # These functions are for consistent behavoir of managing stacks/apps
  VisualOps.prototype.deleteStack    = (id)-> @__view.deleteStack(id)
  VisualOps.prototype.duplicateStack = (id)-> @__view.duplicateStack(id)
  VisualOps.prototype.startApp       = (id)-> @__view.startApp(id)
  VisualOps.prototype.stopApp        = (id)-> @__view.stopApp(id)
  VisualOps.prototype.terminateApp   = (id)-> @__view.terminateApp(id)

  # Creates a stack from the "json" and open it.
  # If it cannot import the json data, returns a string to represent the result.
  VisualOps.prototype.importJson = ( json )->
    result = JsonExporter.importJson json

    if _.isString result then return result

    @openOps( @model.createStackByJson(result) )
    return

  # This is a convenient method to open an editor for the ops model.
  VisualOps.prototype.openOps = ( opsModel )->
    if not opsModel then return
    modelId = if _.isString(opsModel) then opsModel else opsModel.cid
    space = @workspaces.find(modelId)
    if space
      space.activate()
      return

    editor = new DesignEditor( modelId )
    editor.activate()
    editor

  # This is a convenient method to create a stack and then open an editor for it.
  VisualOps.prototype.createOps = ( region )->
    if not region then return
    editor = new DesignEditor( @model.createStack(region).cid )
    editor.activate()
    editor


  VisualOps
