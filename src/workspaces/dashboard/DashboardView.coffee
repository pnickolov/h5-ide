
define [
  './DashboardTpl'
  './DashboardTplData'
  './VisualizeVpcTpl'
  "UI.modalplus"
  "constant"
  "i18n!/nls/lang.js"
  'AppAction'
  "CloudResources"
  "backbone"
  "UI.scrollbar"
  "UI.tooltip"
  "UI.table"
  "UI.bubble"
  "UI.nanoscroller"
], ( template, tplPartials, VisualizeVpcTpl, Modal, constant, lang, appAction, CloudResources )->

  Handlebars.registerHelper "awsAmiIcon", ( amiId, region )->
    ami = CloudResources( constant.RESTYPE.AMI, region ).get( amiId )
    if ami
      ami = ami.attributes
      return ami.osType + "." + ami.architecture + "." + ami.rootDeviceType + ".png"
    else
      return "empty.png"

  Handlebars.registerHelper "awsIsEip", ( ip, region, options )->
    if not ip then return ""
    for eip in CloudResources( constant.RESTYPE.EIP, region ).models
      if eip.get("publicIp") is ip
        return options.fn this

    ""

  Backbone.View.extend {

    events :
      "click .global-map-item"                                       : "gotoRegionFromMap"
      "click .global-map-item .app"                                  : "gotoRegionFromMap"
      'click .recent-list-item, .region-resource-list li'            : 'openItem'
      'click .table-app-link'                                        : 'openItem'
      'click #global-region-create-stack-list li, #btn-create-stack' : 'createStack'

      "click .region-resource-list .delete-stack"    : "deleteStack"
      'click .region-resource-list .duplicate-stack' : 'duplicateStack'
      "click .region-resource-list .start-app"       : "startApp"
      'click .region-resource-list .stop-app'        : 'stopApp'
      'click .region-resource-list .terminate-app'   : 'terminateApp'

      'click .global-region-status-tab' : 'switchRecent'
      'click #region-switch-list li'    : 'switchRegion'
      'click #region-resource-tab li'   : 'switchAppStack'
      'click .resource-tab'             : 'switchResource'
      "click .global-resource-li"       : "gotoRegionResource"

      'click #ImportStack'     : 'importJson'
      'click #VisualizeVPC'    : 'visualizeVPC'
      'click .show-credential' : 'showCredential'
      'click #RefreshResource' : 'reloadResource'
      "click .icon-detail"     : "showResourceDetail"


    initialize : ()->
      @regionOpsTab = "stack"
      @region       = "global"
      @resourcesTab = "INSTANCE"
      @lastUpdate   = +(new Date())

      data = _.map constant.REGION_LABEL, ( name, id )->
        id   : id
        name : name
        shortName : constant.REGION_SHORT_LABEL[ id ]

      @setElement( $(template(data)).eq(0).appendTo("#main") )

      # Need to do a init update because the data might arrive first
      @updateOpsList()
      @updateDemoView()
      @updateGlobalResources()

      self = @
      setInterval ()->
        if not $("#RefreshResource").hasClass("reloading")
          $("#RefreshResource").text( MC.intervalDate(self.lastUpdate/1000) )
        return
      , 1000 * 60

      # Add a custom template to the MC.template, so that the UI.bubble can use it to render.
      MC.template.dashboardBubble = _.bind @dashboardBubble, @
      MC.template.dashboardBubbleSub = _.bind @dashboardBubbleSub, @
      return

    awake : ()->
      @$el.show().children("#global-region-wrap").nanoScroller()
      return

    sleep : ()->
      @$el.hide()

    dashboardBubbleSub: (data)->
        renderData = {}
        renderData.data = _.clone data
        renderData.title = data.id || data.name || data._title
        delete renderData.data._title
        return tplPartials.bubbleResourceSub renderData

    dashboardBubble : ( data )->
      # get Resource Data
      d = {
        id   : data.id
        data : @model.getAwsResDataById( @region, constant.RESTYPE[data.type], data.id )?.toJSON()
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

      return tplPartials.bubbleResourceInfo  d

    ###
      rendering
    ###
    updateOpsList : ()->
      # Update Map.
      regionsMap = {}
      for r in App.model.stackList().groupByRegion()
          regionsMap[ r.region ] = r
          r.stack = r.data.length
          r.app   = 0
      for r in App.model.appList().groupByRegion()
          if not regionsMap[ r.region ]
              regionsMap[ r.region ] = r
              r.stack = 0
          regionsMap[ r.region ].app = r.data.length

      $("#global-region-spot").html tplPartials.globalMap regionsMap

      # Update Recent List
      stacks = App.model.stackList().filterRecent(true)
      apps   = App.model.appList().filterRecent(true)

      if stacks.length > 5 then stacks.length = 5
      if apps.length > 5   then apps.length = 5

      $tabs = $("#global-region-status-widget").find(".global-region-status-tab")
      $tabs.eq(0).children("span").text App.model.appList().length
      $tabs.eq(1).children("span").text App.model.stackList().length

      isStack = $tabs.filter(".on").hasClass("stack")

      $( '#global-region-recent-list' ).html tplPartials.recent { stacks, apps, isStack }

      @updateRegionAppStack()
      return

    updateRegionList  : ( model )->
      console.log "Dashboard Updated due to state changes in app list."

      if not model or model.get("region") is @region
        @updateRegionAppStack()

    updateAppProgress : ( model )->
      if model.get("region") is @region and @regionOpsTab is "app"

        console.log "Dashboard Updated due to app progress changes."

        $li = $("#region-resource-app-wrap").children("[data-id='#{model.id}']")
        if not $li.length then return
        $li.children(".region-resource-progess").show().css({width:model.get("progress")+"%"})
        return

    updateRegionAppStack : ()->
      attr = { apps:[], stacks:[], region : @region }
      attr[ @regionOpsTab ] = true

      region = @region
      if region isnt "global"
        filter = (f)-> f.get("region") is region && f.isExisting()
        tojson = {thumbnail:true}

        attr.stacks = App.model.stackList().filter(filter).map (m)-> m.toJSON(tojson)
        attr.apps   = App.model.appList().filter(filter).map   (m)-> m.toJSON(tojson)

      $('#region-app-stack-wrap').html( tplPartials.region_app_stack(attr) )
      return

    ###
      View logics
    ###
    gotoRegionResource : ( evt )->
      @gotoRegionFromMap( evt )
      type = $(evt.currentTarget).parent().parent().attr("data-type")
      $("#RegionResourceNav").children("[data-type='#{type}']").click()
      return false

    gotoRegionFromMap : ( evt )->
      $tgt = $( evt.currentTarget )
      $li  = $( evt.currentTarget ).closest("li")
      region = $li.attr("id") || $li.attr("data-region")

      $( "#region-switch-list li[data-region=#{region}]" ).click()
      $("#global-region-wrap").nanoScroller({ scrollTop : $('#global-region-map-wrap').height() })

      $("#region-resource-tab").children().eq( if $tgt.hasClass("app") then 0 else 1 ).click()
      return false

    switchRecent : ( evt )->
      $tgt = $(evt.currentTarget)
      if $tgt.hasClass("on") then return
      $tgt.addClass("on").siblings().removeClass("on")
      $("#global-region-recent-list").children().hide().eq( $tgt.index() ).show()

    switchRegion : ( evt )->
      target = $(evt.currentTarget)
      region = target.attr 'data-region'
      if @region is region then return

      if @region is "global" or region is "global"
        resetScroller = true

      @region = region

      $( '#region-switch').find('span').text( target.text() )

      if region is "global"
        $("#RegionView" ).hide()
        $("#GlobalView" ).show()
      else
        # Ask model to get datas for us.
        @model.fetchAwsResources( region )
        $("#RegionView" ).show()
        $("#GlobalView" ).hide()
        @updateRegionAppStack()
        @updateRegionResources()

      if resetScroller
        $("#global-region-wrap").nanoScroller("reset")
      return

    switchAppStack: ( evt ) ->
      $target = $(evt.currentTarget)
      if $target.hasClass("on") then return
      $target.addClass("on").siblings().removeClass("on")

      @regionOpsTab = if $target.hasClass("stack") then "stack" else "app"
      $("#RegionView").find(".region-resource-list").hide().eq( $target.index() ).show()
      return

    switchResource : ( evt )->
      $("#RegionResourceNav").children().removeClass("on")
      @resourcesTab = $(evt.currentTarget).addClass("on").attr("data-type")
      @updateRegionResources()
      return

    importJson : ()->
      modal = new Modal {
        title         : lang.IDE.POP_IMPORT_JSON_TIT
        template      : tplPartials.importJSON()
        width         : "470"
        disableFooter : true
      }

      reader = new FileReader()
      reader.onload = ( evt )->
        error = App.importJson( reader.result )
        if _.isString error
          $("#import-json-error").html error
        else
          modal.close()
          reader = null
        null

      reader.onerror = ()->
        $("#import-json-error").html lang.IDE.POP_IMPORT_ERROR
        null

      hanldeFile = ( evt )->
        evt.stopPropagation()
        evt.preventDefault()

        $("#modal-import-json-dropzone").removeClass("dragover")
        $("#import-json-error").html("")

        evt = evt.originalEvent
        files = (evt.dataTransfer || evt.target).files
        if not files or not files.length then return
        reader.readAsText( files[0] )
        null

      $("#modal-import-json-file").on "change", hanldeFile
      zone = $("#modal-import-json-dropzone").on "drop", hanldeFile
      zone.on "dragenter", ()-> $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", true)
      zone.on "dragleave", ()-> $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", false)
      zone.on "dragover", ( evt )->
        dt = evt.originalEvent.dataTransfer
        if dt then dt.dropEffect = "copy"
        evt.stopPropagation()
        evt.preventDefault()
        null
      null

    openItem    : ( event )-> App.openOps( $(event.currentTarget).attr("data-id") )
    createStack : ( event )->
      $tgt = $( event.currentTarget )
      App.createOps( $tgt.attr("data-region") || @region, $tgt.attr("data-cloud"), $tgt.attr("data-provider") )

    markUpdated : ()-> @lastUpdate = +(new Date()); return

    reloadResource : ()->
      if $("#RefreshResource").hasClass("reloading")
        return

      $("#RefreshResource").addClass("reloading").text("")
      @model.clearVisualizeData()
      App.discardAwsCache().done ()->
        $("#RefreshResource").removeClass("reloading").text("just now")
      return

    deleteStack    : (event)-> appAction.deleteStack $( event.currentTarget ).closest("li").attr("data-id"); false
    duplicateStack : (event)-> appAction.duplicateStack $( event.currentTarget ).closest("li").attr("data-id"); false
    startApp       : (event)-> appAction.startApp $( event.currentTarget ).closest("li").attr("data-id"); false
    stopApp        : (event)-> appAction.stopApp $( event.currentTarget ).closest("li").attr("data-id"); false
    terminateApp   : (event)-> appAction.terminateApp $( event.currentTarget ).closest("li").attr("data-id"); false

    updateVisModel : ()->
      if not @visModal then return
      @visModal.tpl.find(".modal-body").html VisualizeVpcTpl({
        ready : @model.isVisualizeReady()
        fail  : @model.isVisualizeTimeout() || @model.isVisualizeFailed()
        data  : @model.get("visualizeData")
      })
      return

    visualizeVPC : ()->
      @model.visualizeVpc(true)
      attributes = {
        ready : @model.isVisualizeReady()
        fail  : @model.isVisualizeTimeout() || @model.isVisualizeFailed()
        data  : @model.get("visualizeData")
      }

      self = @
      TO = setTimeout ()->
        self.updateVisModel()
      , 60*8*1000 + 1000

      @visModal = new Modal {
        title         : lang.IDE.DASH_IMPORT_VPC_AS_APP
        width         : "770"
        template      : VisualizeVpcTpl( attributes )
        disableFooter : true
        compact       : true
        onClose       : ()->
          self.visModal = null
          clearTimeout(TO)
          return
      }

      @visModal.tpl.on "click", "#VisualizeReload", ()->
        self.model.visualizeVpc(true)
        self.visModal.tpl.find(".unmanaged-vpc-empty").hide()
        self.visModal.tpl.find(".loading-spinner").show()
        false

      @visModal.tpl.on "click", ".visualize-vpc-btn", (event)->
        if $(event.currentTarget).hasClass('disabled') then return false
        $tgt = $(this)
        if $tgt.hasClass(".disabled") then return false
        id = $tgt.attr("data-vpcid")
        region = $tgt.closest("ul").attr("data-region")
        self.visModal.close()
        App.openOps App.model.createImportOps( region, id )
        false
      return

    updateDemoView : ()->
      if App.user.hasCredential()
        $("#dashboard-data-wrap").removeClass("demo")
        $("#VisualizeVPC").removeAttr "disabled"
      else
        $("#VisualizeVPC").attr "disabled", "disabled"
        $("#dashboard-data-wrap").toggleClass("demo", true)
      return

    showCredential : ()-> App.showSettings App.showSettings.TAB.Credential

    updateGlobalResources : ()->
      if not @model.isAwsResReady()
        if @__globalLoading then return
        @__globalLoading = true # Avoid re-rendering the global resource view.
        data = { loading : true }
      else
        @__globalLoading = false
        data = @model.getAwsResData()

      $("#GlobalView").html( tplPartials.globalResources( data ) )
      if @region is "global"
        $("#GlobalView").show()
      return

    updateRegionTabCount : ()->
      resourceCount = @model.getResourcesCount( @region )
      $nav = $("#RegionResourceNav")
      for r, count of resourceCount
        $nav.children(".#{r}").children(".count-bubble").text( if count is "" then "-" else count )
      return

    updateRegionResources : ()->
      if @region is "global" then return

      @updateRegionTabCount()

      type = constant.RESTYPE[ @resourcesTab ]
      if not @model.isAwsResReady( @region, type )
        tpl = '<div class="dashboard-loading"><div class="loading-spinner"></div></div>'
      else
        tpl = tplPartials["resource#{@resourcesTab}"]( @model.getAwsResData( @region, type ) )

      $("#RegionResourceData").html( tpl )

    formateDetail : ( type, data )->
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
            DASH_LBL_HEALTH_CHECK           : @formartDetail('HealthCheck', [data.HealthCheck], "Health Check", true)
            DASH_LBL_INSTANCE               : data.Instances.join(", ")
            DASH_LBL_LISTENER_DESC          : @formartDetail('ListenerDescriptions', _.pluck(data.ListenerDescriptions.member,"Listener"), "Listener Descriptions", true)
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
            DASH_LBL_BLOCK_DEVICES      : if data.blockDeviceMapping then @formartDetail "BlockDevice", data.blockDeviceMapping, "deviceName" else null
            DASH_LBL_NETWORK_INTERFACE  : if data.networkInterfaceSet then @formartDetail "ENI", data.networkInterfaceSet, "networkInterfaceId" else null
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
                DASH_LBL_DIMENSIONS        : @formartDetail 'Dimensions', data.Dimensions, 'Dimensions', true
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
    formartDetail: (type, array, key, force)->
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

    showResourceDetail : ( evt )->
      $tgt = $( evt.currentTarget )
      id   = $tgt.attr("data-id")
      type = constant.RESTYPE[ @resourcesTab ]

      resModel     = @model.getResourceData( @region, type, id )
      formatedData = @formateDetail( @resourcesTab, resModel.attributes )

      if formatedData.title
        id = formatedData.title
        delete formatedData.title

      new Modal({
        title         : id
        width         : "450"
        template      : tplPartials.resourceDetail( formatedData )
        disableFooter : true
      })
      return
  }
