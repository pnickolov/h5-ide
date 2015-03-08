define [ "./DashboardTpl",
         "./ImportDialog",
         "./DashboardTplData",
         "constant",
         "./VisualizeDialog",
         "CloudResources",
         "AppAction",
         "UI.modalplus",
         "i18n!/nls/lang.js",
         "ProjectLog",
         "Credential"
         "credentialFormView"
         "UI.bubble",
         "backbone" ], ( Template, ImportDialog, dataTemplate, constant, VisualizeDialog, CloudResources, AppAction, Modal, lang, ProjectLog, Credential, CredentialFormView )->

  Handlebars.registerHelper "awsAmiIcon", ( credentialId, amiId, region )->
    ami = CloudResources(credentialId, constant.RESTYPE.AMI, region ).get( amiId )
    if ami
      ami = ami.attributes
      return ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"
    else
      console.log credentialId, amiId, region, ami
      return "empty.png"

  Handlebars.registerHelper "awsIsEip", ( credentialId, ip, region, options )->
    if not ip then return ""
    for eip in CloudResources(credentialId, constant.RESTYPE.EIP, region ).models
      if eip.get("publicIp") is ip
        return options.fn this
    ""

  Backbone.View.extend {

    events :
      "click .dashboard-header .create-stack"   : "createStack"
      "click .dashboard-header .import-stack"   : "importStack"
      "click .dashboard-header .icon-visualize" : "importApp"
      "click .dashboard-sidebar .dashboard-nav-log" : "updateLog"
      "click .dashboard-sidebar nav buttton"    : "updateLog"
      'click #region-switch-list li'            : 'switchRegion'
      'click .resource-tab'                     : 'switchResource'

      "click .region-resource-list .delete-stack"    : "deleteStack"
      'click .region-resource-list .duplicate-stack' : 'duplicateStack'
      "click .region-resource-list .start-app"       : "startApp"
      'click .region-resource-list .stop-app'        : 'stopApp'
      'click .region-resource-list .terminate-app'   : 'terminateApp'

      "click .show-credential" : "showCredential"
      "click .icon-detail"     : "showResourceDetail"
      'click .refreshResource' : 'reloadResource'
      "click .global-resource-li": "switchGlobalResource"


    initialize : ()->
      @resourcesTab = "INSTANCE"
      @region       = "global"
      @appsRegion   = "global"
      @stacksRegion = "global"
      @setElement $( Template.main({
        providers : @model.supportedProviders()
        id: @model.scene.project.get("id")
        isAdmin: @model.scene.project.amIAdmin()
      }) ).appendTo( @model.scene.spaceParentElement() )

      self = @
      # listen logs change
      @logCol = @model.scene.project.logs()
      @logCol.on('change add', @updateLog, this)

      @render()
      @listenTo @model.scene.project, "update:stack", -> @updateStacks()
      @listenTo @model.scene.project, "update:app", -> @updateApps()
      @listenTo @model.scene.project, "change:stack", -> @updateStacks()
      @listenTo @model.scene.project, "change:app", -> @updateApps()
      @listenTo @model.scene.project, "update:credential", ()-> self.updateDemoView()
      @listenTo @model.scene.project, "change:credential", ()-> self.updateDemoView()

      @listenTo @model.scene.project.apps(), "change:progress", ( ops )-> self.updateAppStackProgress( ops )
      @listenTo @model.scene.project.stacks(), "change:progress", ( ops )-> self.updateAppStackProgress( ops )

      @listenTo App.WS, "visualizeUpdate", @onVisualizeUpdated

      credentialId       = @model.scene.project.credIdOfProvider Credential.PROVIDER.AWSGLOBAL
      @credentialAccount = @model.scene.project.credOfProvider(Credential.PROVIDER.AWSGLOBAL).get("awsAccount")

      @listenTo CloudResources(credentialId, constant.RESTYPE.INSTANCE ), "update", @onGlobalResChanged
      @listenTo CloudResources(credentialId, constant.RESTYPE.EIP ), "update", @onGlobalResChanged
      @listenTo CloudResources(credentialId, constant.RESTYPE.VOL ), "update", @onGlobalResChanged
      @listenTo CloudResources(credentialId, constant.RESTYPE.ELB ), "update", @onGlobalResChanged
      @listenTo CloudResources(credentialId, constant.RESTYPE.VPN ), "update", @onGlobalResChanged

      @listenTo CloudResources(credentialId, constant.RESTYPE.VPC ), "update", @onRegionResChanged
      @listenTo CloudResources(credentialId, constant.RESTYPE.ASG ), "update", @onRegionResChanged
      @listenTo CloudResources(credentialId, constant.RESTYPE.CW ),  "update", @onRegionResChanged

      for region in constant.REGION_KEYS
        @listenTo CloudResources(credentialId, constant.RESTYPE.SUBSCRIPTION, region ), "update", @onRegionResChanged
        @listenTo CloudResources(credentialId, constant.RESTYPE.DBINSTANCE, region ),  "update", @onGlobalResChanged

      MC.template.dashboardBubble = _.bind @dashboardBubble, @
      MC.template.dashboardBubbleSub = _.bind @dashboardBubbleSub, @
      return

    render : ()->
      # Update the dashboard in this method.
      @updateDemoView()
      @updateGlobalResources()
      @model.fetchAwsResources()
      @initRegion()
      @updateLog()
      self = @
      setInterval ()->
        if not self.$el.find(".refreshResource").hasClass("reloading")
          self.$el.find(".refreshResource").text(MC.intervalDate(self.lastUpdate/ 1000))
        # Auto update logs (for time update)
        self.updateLog()
        return
      , 1000 * 60

      @$el.toggleClass "observer", @model.isReadOnly()

      return

    createStack : ( evt )->
      $tgt = $( evt.currentTarget )
      provider = $tgt.closest("ul").attr("data-provider")
      region   = $tgt.attr("data-region")

      opsModel = @model.scene.project.createStack( region, provider )

      @model.scene.loadSpace( opsModel )
      return

    showCredential: ()->
      new CredentialFormView({model: @model.scene.project}).render()

    importStack : ( evt )->
      new ImportDialog({
        type    : $(evt.currentTarget).attr("data-type")
        project : @model.scene.project
      })
      false

    importApp : ()->
      new AppAction({project: @model.scene.project}).showPayment().then (result)=>
        new VisualizeDialog({model:@model.scene.project, dialog: result?.modal})

    updateDemoView : ()->
      if not @model.scene.project.isDemoMode()
        @$el.find("#dashboard-data-wrap").removeClass("demo")
        @$el.find("#VisualizeVPC").removeAttr("disabled").removeClass("tooltip").removeAttr("title")
        newCredentialAccount = @model.scene.project.credOfProvider(Credential.PROVIDER.AWSGLOBAL).get("awsAccount")
        if @credentialAccount isnt newCredentialAccount
          @reloadResource()
          @credentialAccount = newCredentialAccount
      else
        @$el.find("#VisualizeVPC").attr("disabled", "disabled").addClass("tooltip").attr("title", lang.IDE.PROVIDE_CRED_TO_VISUALIZE)
        @$el.find("#dashboard-data-wrap").toggleClass("demo", true)
      return


    updateGlobalResources : ()->
      if not @model.isAwsResReady()
        @__globalLoading = true # Avoid re-rendering the global resource view.
        data = { loading : true }
      else
        @__globalLoading = false
        data = {}
        _.each @model.getAwsResData(), (resList, key)->
          orderedList = _.sortBy resList, (res)->
            -res.data.length
          data[key] = orderedList


      @$el.find("#GlobalView").html( dataTemplate.globalResources( data ) )
      if @region is "global"
        @$el.find("#GlobalView").removeAttr("style")
        @$el.find("#RegionViewWrap").hide()
      return

    onGlobalResChanged: ()->
      @updateGlobalResources()
      @updateRegionResources()

    onRegionResChanged: ()->
      @updateRegionResources()

    initRegion : ( )->
      @updateRegionAppStack("stacks", "global")
      @updateRegionAppStack("stacks", "global", true)
      @updateRegionAppStack("apps", "global")
      @updateRegionAppStack("apps", "global", true)
      @toggleMarathonOpslist()
      @updateRegionResources()

    switchRegion: (evt)->
      if evt and evt.currentTarget
        target = evt.currentTarget
        region = $(target).data("region")
        if region isnt "global"
          @model.fetchAwsResources( region )
        updateType = $(evt.currentTarget).parents(".dash-region-navigation").data("type")
        if updateType in ["stacks", "apps"]
          @[updateType + "Region"] = region
          @updateRegionAppStack(updateType, region)
        else if updateType is "resource"
          @region = region
          @updateRegionResources()

    switchGlobalResource: (evt)->
      console.log(evt)
      $elem = $(evt.currentTarget)
      region = $elem.data("region")
      type = $elem.parent().parent().data("type")
      $(".dash-resource-wrap").find("#region-switch-list").find("li[data-region=#{region}]").click()
      $("#RegionViewWrap").find("nav>div[data-type='#{type}']").click()

    updateRegionResources : ()->
      @$el.find(".dash-resource-wrap .js-toggle-dropdown span").text(constant.REGION_SHORT_LABEL[ @region ] || lang.IDE.DASH_BTN_GLOBAL)
      if @region is "global"
        @updateGlobalResources()
        return

      @$el.find("#RegionViewWrap" ).show()
      @$el.find("#GlobalView" ).hide()
      @updateRegionTabCount()
      type = constant.RESTYPE[ @resourcesTab ]
      if not @model.isAwsResReady( @region, type )
        tpl = '<div class="dashboard-loading"><div class="loading-spinner"></div></div>'
      else
        tpl = dataTemplate["resource#{@resourcesTab}"]( @model.getAwsResData( @region, type ) )
      @$el.find("#RegionResourceData").html( tpl )

    updateAppStackProgress : ( ops )->
      $("#region-resource-app-wrap, #region-resource-stack-wrap").children("li[data-id='#{ops.id}']").find(".region-resource-progess").css("width",ops.get("progress")+"%")
      return

    updateStacks: ()->
      @updateRegionAppStack("stacks", null)
      @updateRegionAppStack("stacks", null, true)
      @toggleMarathonOpslist()

    updateApps: ()->
      @updateRegionAppStack("apps", null)
      @updateRegionAppStack("apps", null, true)
      @toggleMarathonOpslist()

    toggleMarathonOpslist: ()->
      $marathonWrap = @$el.find(".region-app-stack-wrap.marathon")
      hasMarathonOps = $marathonWrap.find(".region-resource-list li").size() > 0

      $marathonWrap.toggle(hasMarathonOps)

    updateRegionAppStack : (updateType="stacks", region, isMarathon = false)->
      if updateType not in ["stacks", "apps"]
        return false
      if not region
        if isMarathon
          region = "global"
        else
          region = @[updateType + "Region"]
      self = @
      attr = { apps:[], stacks:[], region : @region }
      data = _.map constant.REGION_LABEL, ( name, id )->
        id   : id
        name : name
        count: 0
        shortName : constant.REGION_SHORT_LABEL[ id ]
      if region isnt "global"
        filter = (f)-> f.get("region") is region && f.isExisting()
      else
        filter = ()-> true
      tojson = {thumbnail:true}
      resources = self.model.scene.project[updateType]()
      resources.comparator = "updateTime"
      resources.sort()
      if isMarathon
        resources = resources.filter (f)-> f.get("provider") is "docker::marathon"
      else
        resources = resources.filter (f)-> f.get("provider") isnt "docker::marathon"

      attr[updateType] = resources.filter(filter).map( (m)-> m.toJSON(tojson) ).reverse()

      # ops count for each region.
      attr.region = _.map data, (obj)->
        obj.count = _.groupBy(attr[updateType], "region")[obj.id]?.length || 0
        obj
      attr.globalCount = resources.length

      attr.projectId = self.model.scene.project.id
      attr.currentRegion = _.find(data, (e)-> e.id is region)||{id: "global", shortName: lang.IDE.DASH_BTN_GLOBAL}
      if isMarathon
        attr.isMarathon = isMarathon
        @$el.find(".region-app-stack-wrap.marathon .dash-region-#{updateType}-wrap").replaceWith( dataTemplate["region_" + updateType](attr))
      else
        @$el.find(".region-app-stack-wrap").not(".marathon").find(".dash-region-#{updateType}-wrap").replaceWith( dataTemplate["region_" + updateType](attr))
      return

    updateRegionTabCount : ()->
      resourceCount = @model.getResourcesCount( @region )
      $nav = @$el.find("#RegionResourceNav")
      for r, count of resourceCount
        $nav.children(".#{r}").children(".count-bubble").text( if count is "" then "-" else count )
      return


    switchResource : ( evt )->
      @$el.find("#RegionResourceNav").children().removeClass("on")
      @resourcesTab = $(evt.currentTarget).addClass("on").attr("data-type")
      @updateRegionResources()
      return

    deleteStack    : (event)->
      event.preventDefault()
      id = $( event.currentTarget ).closest("li").attr("data-id")
      (new AppAction({model: @model.scene.project.getOpsModel(id)})).deleteStack()
      false

    duplicateStack : (event)->
      event.preventDefault()
      id = $( event.currentTarget ).closest("li").attr("data-id")
      App.loadUrl @model.scene.project.stacks().get(id).duplicate().url()
      false

    startApp       : (event)->
      event.preventDefault()
      id = $( event.currentTarget ).closest("li").attr("data-id")
      (new AppAction({model: @model.scene.project.getOpsModel(id)})).startApp()
      false

    stopApp        : (event)->
      event.preventDefault()
      id = $( event.currentTarget ).closest("li").attr("data-id")
      (new AppAction({model: @model.scene.project.getOpsModel(id)})).stopApp()
      false

    terminateApp   : (event)->
      event.preventDefault()
      id = $( event.currentTarget ).closest("li").attr("data-id")
      (new AppAction({model: @model.scene.project.getOpsModel(id)})).terminateApp()
      false

    reloadResource : ()->
      if $(".refreshResource").hasClass("reloading")
        return

      $(".refreshResource").addClass("reloading").text("")
      @model.clearVisualizeData()
      CloudResources.invalidate().done ()->
        $(".refreshResource").removeClass("reloading").text(lang.IDE.DASH_TPL_JUST_NOW)
      return

    showResourceDetail : ( evt )->
      $tgt = $( evt.currentTarget )
      id   = $tgt.attr("data-id")
      type = constant.RESTYPE[ @resourcesTab ]

      resModel     = @model.getResourceData( @region, type, id )
      formattedData = @formatDetail( @resourcesTab, resModel.attributes )

      if formattedData.title
        id = formattedData.title
        delete formattedData.title

      new Modal({
        title         : id
        width         : "450"
        template      : dataTemplate.resourceDetail( formattedData )
        disableFooter : true
      })
      return

    formatDetail : ( type, data )->
      switch type
        when "SUBSCRIPTION"
          return {
          DASH_LBL_TITLE    : data.Endpoint
          DASH_LBL_ENDPOINT : data.Endpoint
          DASH_LBL_OWNER   : data.Owner
          DASH_LBL_PROTOCOL : data.Protocol
          DASH_LBL_SUBSCRIPTION_ARN : data.SubscriptionArn
          DASH_LBL_TOPIC_ARN : data.TopicArn
          }
        when "VPC"
          return {
          DASH_LBL_STATE   : data.state
          DASH_LBL_CIDR    : data.cidrBlock
          DASH_LBL_TENANCY : data.instanceTenancy
          }
        when "ASG"
          return {
          DASH_LBL_TITLE : data.Name
          DASH_BUB_NAME : data.Name
          DASH_LBL_AVAILABILITY_ZONE : data.AvailabilityZones.join(", ")
          DASH_LBL_CREATE_TIME : data.CreatedTime
          DASH_LBL_DEFAULT_COOLDOWN : data.DefaultCooldown
          DASH_LBL_DESIRED_CAPACITY : data.DesiredCapacity
          DASH_LBL_MAX_SIZE        : data.MaxSize
          DASH_LBL_MIN_SIZE       : data.MinSize
          DASH_LBL_HEALTH_CHECK_GRACE_PERIOD : data.HealthCheckGracePeriod
          DASH_LBL_HEALTH_CHECK_TYPE : data.HealthCheckType
          #Instance : data.Instances
          DASH_LBL_LAUNCH_CONFIGURATION_NAME : data.LaunchConfigurationName
          DASH_LBL_TERMINATION_POLICIES   : data.TerminationPolicies.join(", ")
          DASH_LBL_AUTOSCALING_GROUP_ARN   : data.id
          }
        when "ELB"
          return {
          DASH_LBL_AVAILABILITY_ZONE      : data.AvailabilityZones.join(", ")
          DASH_LBL_CREATE_TIME            : data.CreatedTime
          DASH_LBL_DNS_NAME               : data.DNSName
          DASH_LBL_HEALTH_CHECK           : @formatData('HealthCheck', [data.HealthCheck], "Health Check", true)
          DASH_LBL_INSTANCE               : data.Instances.join(", ")
          DASH_LBL_LISTENER_DESC          : @formatData('ListenerDescriptions', _.pluck(data.ListenerDescriptions.member,"Listener"), "Listener Descriptions", true)
          DASH_LBL_SECURITY_GROUPS        : data.SecurityGroups.join(", ")
          DASH_LBL_SUBNETS                : data.Subnets.join(", ")
          }
        when "VPN"
          return {
          DASH_LBL_STATE    : data.state
          DASH_LBL_VGW_ID : data.vpnGatewayId
          DASH_LBL_CGW_ID : data.customerGatewayId
          DASH_LBL_TYPE     : data.type
          }
        when "VOL"
          return {
          DASH_LBL_VOLUME_ID        : data.id
          DASH_LBL_DEVICE_NAME       : data.device
          DASH_LBL_SNAPSHOT_ID       : data.snapshotId
          DASH_LBL_VOLUME_SIZE  : data.size
          DASH_LBL_STATUS            : data.status
          DASH_LBL_INSTANCE_ID       : data.instanceId
          DASH_LBL_DELETE_ON_TERM : data.deleteOnTermination
          DASH_LBL_AVAILABILITY_ZONE : data.availabilityZone
          DASH_LBL_VOLUME_TYPE       : data.volumeType
          DASH_LBL_CREATE_TIME       : data.createTime
          DASH_LBL_ATTACH_TIME       : data.attachTime
          }
        when "INSTANCE"
          return {
          DASH_LBL_STATUS             : data.instanceState.name
          DASH_LBL_MONITORING         : data.monitoring.state
          DASH_LBL_PRIMARY_PRIVATE_IP : data.privateIpAddress
          DASH_LBL_PRIVATE_DNS        : data.privateDnsName
          DASH_LBL_LAUNCH_TIME        : data.launchTime
          DASH_LBL_AVAILABILITY_ZONE  : data.placement.availabilityZone
          DASH_LBL_AMI_LAUNCH_INDEX   : data.amiLaunchIndex
          DASH_LBL_INSTANCE_TYPE      : data.instanceType
          DASH_LBL_BLOCK_DEVICE_TYPE  : data.rootDeviceType
          DASH_LBL_BLOCK_DEVICES      : if data.blockDeviceMapping then @formatData "BlockDevice", data.blockDeviceMapping, "deviceName" else null
          DASH_LBL_NETWORK_INTERFACE  : if data.networkInterfaceSet then @formatData "ENI", data.networkInterfaceSet, "networkInterfaceId" else null
          }
        when 'EIP'
          result = {
            DASH_LBL_PUBLIC_IP : data.publicIp
            DASH_LBL_DOMAIN    : data.domain
            DASH_LBL_ALLOCATION_ID : data.id
            DASH_LBL_CATEGORY  : data.category
            DASH_LBL_TITLE     : data.publicIp
          }
          if data.associationId
            result.DASH_LBL_ASSOCIATION_ID = data.associationId
          if data.networkInterfaceId
            result.DASH_LBL_NETWORK_INTERFACE_ID = data.networkInterfaceId
          if data.instanceId
            result.DASH_LBL_INSTANCE_ID = data.instanceId
          if data.privateIpAddresse
            result.DASH_LBL_PRIVATE_IP_ADDRESS = data.privateIpAddresses
          return result
        when 'CW'
          return {
          DASH_LBL_ALARM_NAME        : data.Name
          DASH_LBL_COMPARISON_OPERATOR: data.ComparisonOperator
          DASH_LBL_DIMENSIONS        : @formatData 'Dimensions', data.Dimensions, 'Dimensions', true
          DASH_LBL_EVALUATION_PERIODS: data.EvaluationPeriods
          DASH_LBL_INSUFFICIENT_DATA_ACTIONS: data.InsufficientDataActions
          DASH_LBL_METRIC_NAME      : data.MetricName
          DASH_LBL_NAMESPACE        : data.Namespace
          DASH_LBL_OK_ACTIONS        : data.OKActions
          DASH_LBL_PERIOD            : data.Period
          DASH_LBL_STATE_REGION      : data.StateReason
          DASH_LBL_STATE_UPDATED_TIMESTAMP: data.StateUpdatedTimestamp
          DASH_LBL_STATE_VALUE        : data.StateValue
          DASH_LBL_STATISTIC         : data.Statistic
          DASH_LBL_THRESHOLD         : data.Threshold
          DASH_LBL_CATEGORY          : data.category
          DASH_LBL_TITLE             : data.Name
          DASH_LBL_ACTIONS_ENABLED   : if data.ActionsEnabled then "true" else 'false'
          DASH_LBL_ALARM_ACTIONS     : data.AlarmActions.member
          DASH_LBL_ALARM_ARN         : data.id
          }
        when "DBINSTANCE"
          json =  {
            DASH_LBL_STATUS    : data.DBInstanceStatus
            DASH_LBL_ENDPOINT  : data.Endpoint.Address + "" + data.Endpoint.Port
            DASH_LBL_ENGINE    : data.Engine
            DASH_LBL_DB_NAME:    data.name || data.Name || data.DBName || "None"
            DASH_LBL_OPTION_GROUP: data.OptionGroupMemberships?.OptionGroupMembership?.OptionGroupName || "None"
            DASH_LBL_PARAMETER_GROUP: data.DBParameterGroups?.DBParameterGroupName || "None"
            DASH_LBL_AVAILABILITY_ZONE : data.AvailabilityZone
            DASH_LBL_SUBNET_GROUP: data.sbgId || "None"
            DASH_LBL_PUBLICLY_ACCESSIBLE: data.PubliclyAccessible.toString()
            DASH_LBL_IOPS: data.Iops || "OFF"
            DASH_LBL_MULTI_AZ: data.MultiAZ.toString()
            DASH_LBL_AUTOMATED_BACKUP: data.AutoMinorVersionUpgrade
            DASH_LBL_LATEST_RESTORE_TIME: data.LatestRestorableTime
            DASH_LBL_AUTO_MINOR_VERSION_UPGRADE: data.AutoMinorVersionUpgrade
            DASH_LBL_MAINTENANCE_WINDOW: data.PreferredMaintenanceWindow
            DASH_LBL_BACKUP_WINDOW: data.PreferredBackupWindow
          }
          return json
    # some format to the data so it can show in handlebars template
    formatData: (type, array, key, force)->
      #resolve 'BlockDevice' AttachmentSet HealthCheck and so on.
      if (['BlockDevice', "AttachmentSet","HealthCheck", "ListenerDescriptions",'Dimensions','ENI'].indexOf type) > -1
        _.map array, (blockDevice, index)->
          # combine ebs attribute
          _.map blockDevice, (e, key)->
            if key is "ebs"
              _.extend blockDevice, e
            # remove Object value
            if _.isObject e
              delete blockDevice[key]
          # format boolean value
          _.map blockDevice, (e, key)->
            if _.isBoolean e
              blockDevice[key] = e.toString()
              null
        _.map array , (data)->
          if force then data._title = key else data._title  = data[key]
          data.bubble =
            value: if force then key else data[key] # override the value of title
            data: (JSON.stringify data)
            template: "dashboardBubbleSub"
          return data
        array.bubble = true
        return array
      else
        #resolve Other resource
        result = _.map array, (i)->
          i.bubble = {}
          i.bubble.value = i[key]
          i.bubble.data = JSON.stringify {
            type: type
            id: i[key]
          }
          return i
        result.bubble = true
        result

    dashboardBubbleSub: (data)->
      renderData = {}
      formattedData = {}
      _.each data, (value, key)->
        newKey = lang.IDE["BUBBLE_"+key.toUpperCase().split("-").join("_")] || key
        formattedData[newKey] = value
        return
      renderData.data = formattedData
      renderData.title = data.id || data.name || data._title
      delete renderData.data._title
      return dataTemplate.bubbleResourceSub renderData

    dashboardBubble : ( data )->
      # get Resource Data
      resourceData = @model.getAwsResDataById( @region, constant.RESTYPE[data.type], data.id )?.toJSON()
      formattedData = {}
      _.each resourceData, (value, key)->
        newKey = lang.IDE["BUBBLE_"+key.toUpperCase().split("-").join("_")] || key
        formattedData[newKey] = value
        return
      d = {
        id   : data.id
        data : formattedData
      }

      # Make Boolean to String to show in handlebarsjs
      _.each d.data, (e,key)->
        if _.isBoolean e
          d.data[key] = e.toString()
        if e == ""
          d.data[key] = "None"
        if (_.isArray e) and e.length is 0
          d.data[key] = ['None']
        if (_.isObject e) and (not _.isArray e)
          delete d.data[key]

      return dataTemplate.bubbleResourceInfo  d

    updateLog: (event) ->

        that = @

        # switch
        if event

            $btn = $(event.currentTarget)
            $sidebar = $btn.parents('.dashboard-sidebar')
            $sidebar.find('.dashboard-nav-log').removeClass('selected')
            $sidebar.find('.dashboard-log').addClass('hide')
            $btn.addClass('selected')
            if $btn.hasClass('dashboard-nav-activity')
                $sidebar.find('.dashboard-log-activity').removeClass('hide')
            else
                $sidebar.find('.dashboard-log-audit').removeClass('hide')

        # render
        myRole = that.model.scene.project.get('myRole')
        # App.model.fetchUserData(_.uniq(@logCol.pluck("usercode"))).then ( userDataSet )->
        that.renderLog("activity")
        if myRole is 'admin'
          that.renderLog("audit")
        else
          that.renderLog("audit", true)

    renderLog: (type, empty) ->

        that = @

        if type is 'activity'
            models = @logCol.history()
            container = '.dashboard-log-activity'
        else if type is 'audit'
            models = @logCol.audit()
            container = '.dashboard-log-audit'

        $container = @$el.find('.dashboard-sidebar').find(container)

        if empty

            $container.html Template.noActivity()
            return

        projectId = @model.scene.project.id

        # filter only success log
        dataAry = _.filter models, (data) ->
            return data.get('success')

        dataAry = _.map models, (data) ->

            action   = data.get('action') or ''
            target   = data.get('target') or ''
            type     = (data.get('type') or '').toLowerCase()
            targetId = data.get('targetId') or ''
            targetId = null if not that.model.scene.project.getOpsModel(targetId)

            _name = '<span class="name">' + data.get("username") + '</span>'
            if targetId
                _target = '<a class="target route" href="/workspace/' + projectId + '/ops/' + targetId + '">' + target + '</a>'
            else
                _target = '<span class="target">' + target + ' </span>'

            eventStr = lang.IDE["DASHBOARD_LOGS_#{type.toUpperCase()}_#{action.toUpperCase()}"]
            if eventStr
                event = sprintf(eventStr, _name, _target, '')

            {
              action_type : (action + '_' + type).toLowerCase()
              event       : event or ("#{_name} #{action} #{type} #{_target}")
              time        : MC.intervalDate(new Date(data.get('time')))
            }

        if dataAry.length
            $container.html Template.activityList(dataAry)
        else
            $container.html Template.noActivity()

  }
