
###
----------------------------
  This is the core / entry point / controller of the whole IDE.
----------------------------

  It contains some basical logics to maintain the IDE. And it holds other components
  to provide other functionality
###

define [ "ApiRequest", "component/exporter/JsonExporter", "./Websocket", "./ApplicationView", "./ApplicationModel", "./User", "./subviews/SettingsDialog", "common_handle" ,"event", "vpc_model", "constant" ], ( ApiRequest, JsonExporter, Websocket, ApplicationView, ApplicationModel, User, SettingsDialog, common_handle, ide_event, vpc_model, constant )->

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

    # view / model depends on User and Websocket
    @model  = new ApplicationModel()
    @__view = new ApplicationView()

    # This function returns a promise
    @user.fetch()


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

    @user.on "change:credential", ()=> @__onCredentialChanged()
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

  VisualOps.prototype.importJson = ( json )->

      result = JsonExporter.importJson json

      if _.isString result
          return result

      # The result is a valid json
      console.log "Imported JSON: ", result, result.region

      # check repeat stack name
      MC.common.other.checkRepeatStackName()

      # set username
      result.username = $.cookie 'usercode'

      # set name
      result.name     = MC.aws.aws.getDuplicateName(result.name)

      # set id
      result.id       = 'import-' + MC.data.untitled + '-' + result.region

      # create new result
      new_result      = {}
      new_result.resolved_data = []
      new_result.resolved_data.push result

      # formate json
      console.log "Formate JSON: ", new_result

      # push IMPORT_STACK
      ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'IMPORT_STACK', new_result

      null

  VisualOps.prototype.openSampleStack = (fromWelcome) ->

    that = this

    try

      isFirstVisit = @user.isFirstVisit()

      if (isFirstVisit and fromWelcome) or (not isFirstVisit and not fromWelcome)

        stackStoreIdStamp = $.cookie('stack_store_id') or ''
        localStackStoreIdStamp = $.cookie('stack_store_id_local') or ''

        stackStoreId = stackStoreIdStamp.split('#')[0]

        if stackStoreId and stackStoreIdStamp isnt localStackStoreIdStamp
          
          $.cookie('stack_store_id_local', stackStoreIdStamp, {expires: 30})

          gitBranch = 'master'

          ApiRequest('stackstore_fetch_stackstore', {
            file_name: "#{gitBranch}/stack/#{stackStoreId}/#{stackStoreId}.json"
          }).then (result) ->

            jsonDataStr = result
            that.importJson(jsonDataStr)

    catch err

      console.log('Open store stack failed')

  VisualOps
