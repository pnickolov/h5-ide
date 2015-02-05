define [ "./DashboardTpl", "./ImportDialog", "./DashboardTplData", "constant", "./VisualizeDialog", "AppAction", "i18n!/nls/lang.js", "ide/settings/projectSubModels/MemberCollection" ,"backbone"
], ( Template, ImportDialog, dataTemplate, constant, VisualizeDialog, AppAction, lang, MemberCollection )->
  Backbone.View.extend {

    events :
      "click .dashboard-header .create-stack"   : "createStack"
      "click .dashboard-header .import-stack"   : "importStack"
      "click .dashboard-header .icon-visualize" : "importApp"
      "click .dashboard-sidebar .dashboard-nav-log" : "switchLog"
      "click .dashboard-sidebar nav buttton"    : "switchLog"
      'click #region-switch-list li'    : 'switchRegion'
      'click .resource-tab'             : 'switchResource'

      "click .region-resource-list .delete-stack"    : "deleteStack"
      'click .region-resource-list .duplicate-stack' : 'duplicateStack'
      "click .region-resource-list .start-app"       : "startApp"
      'click .region-resource-list .stop-app'        : 'stopApp'
      'click .region-resource-list .terminate-app'   : 'terminateApp'
      'click .region-resource-list>li>a'             : 'openOps'


    initialize : ()->
      @regionOpsTab = "stack"
      @resourcesTab = "INSTANCE"
      @region       = "global"
      @setElement $( Template.main({
        providers : @model.supportedProviders()
      }) ).appendTo( @model.scene.spaceParentElement() )

      # listen logs change
      @logCol = @model.scene.project.logs()
      @logCol.on('change', @switchLog, this)

      @render()
      console.log @
      return

    render : ()->
      # Update the dashboard in this method.
      @updateDemoView()
      @updateGlobalResources()
      @initRegion()
      setInterval ()->
        if not $("#RefreshResource").hasClass("reloading")
          $("#RefreshResource").text(MC.intervalDate(self.lastUpdate/ 1000))
        return
      , 1000 * 60

      MC.template.dashboardBubble = _.bind @dashboardBubble, @
      MC.template.dashboardBubble = _.bind @dashboardBubble, @

      @$el.toggleClass "observer", @model.isReadOnly()
      @switchLog()
      return

    createStack : ( evt )->
      $tgt = $( evt.currentTarget )
      provider = $tgt.closest("ul").attr("data-provider")
      region   = $tgt.attr("data-region")

      opsModel = @model.scene.project.createStack( region, provider )

      @model.scene.loadSpace( opsModel )
      return

    importStack : ( evt )->
      new ImportDialog({
        type    : $(evt.currentTarget).attr("data-type")
        project : @model.scene.project
      })
      false

    importApp : ()-> new VisualizeDialog({model:@model.scene.project})


    updateDemoView : ()->
      if @model.scene.project.hasCredential()
        $("#dashboard-data-wrap").removeClass("demo")
        $("#VisualizeVPC").removeAttr "disabled"
      else
        $("#VisualizeVPC").attr "disabled", "disabled"
        $("#dashboard-data-wrap").toggleClass("demo", true)
      return


    updateGlobalResources : ()->
      if not @model.isAwsResReady()
        if @__globalLoading then return
        @__globalLoading = true # Avoid re-rendering the global resource view.
        data = { loading : true }
      else
        @__globalLoading = false
        data = @model.getAwsResData()

      $("#GlobalView").html( dataTemplate.globalResources( data ) )
      if @region is "global"
        $("#GlobalView").show()
        $("#RegionViewWrap").hide()
      return


    dashboardBubbleSub: (data)->
      renderData = {}
      formattedData = {}
      _.each data, (value, key)->
        newKey = lang.IDE["BUBBLE_"+key.toUpperCase().split("-").join("_")] || key
        formattedData[newKey] = value
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
      d = {
        id   : data.id
        data : formattedData
      }

      # Make Boolean to String to show in handlebars.js
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

    initRegion : ( )->
      @updateRegionAppStack("stacks", "global")
      @updateRegionAppStack("apps", "global")
      @updateRegionResources()

    switchRegion: (evt)->
      if evt and evt.currentTarget
        target = evt.currentTarget
        region = $(target).data("region")
        if region isnt "global"
          @model.fetchAwsResources( region )
        updateType = $(evt.currentTarget).parents(".dash-region-navigation").data("type")
        if updateType in ["stacks", "apps"]
          @updateRegionAppStack(updateType, region)
        else if updateType is "resource"
          @region = region
          @updateRegionResources(region)

    updateRegionResources : ()->
      if @region is "global"
        @updateGlobalResources()
        return
      $(".dash-resource-wrap .js-toggle-dropdown span").text(constant.REGION_SHORT_LABEL[ @region ] || lang.IDE.DASH_BTN_GLOBAL)

      $("#RegionViewWrap" ).show()
      $("#GlobalView" ).hide()
      @updateRegionTabCount()
      type = constant.RESTYPE[ @resourcesTab ]
      if not @model.isAwsResReady( @region, type )
        tpl = '<div class="dashboard-loading"><div class="loading-spinner"></div></div>'
      else
        tpl = dataTemplate["resource#{@resourcesTab}"]( @model.getAwsResData( @region, type ) )
      $("#RegionResourceData").html( tpl )

    updateRegionAppStack : (updateType="stack", region)->
      if updateType not in ["stacks", "apps"]
        return false
      self = @
      attr = { apps:[], stacks:[], region : @region }
      attr[ @regionOpsTab ] = true
      data = _.map constant.REGION_LABEL, ( name, id )->
        id   : id
        name : name
        shortName : constant.REGION_SHORT_LABEL[ id ]
      if region isnt "global"
        filter = (f)-> f.get("region") is region && f.isExisting()
      else
        filter = ()-> true
      tojson = {thumbnail:true}
      attr[updateType] = self.model.scene.project[updateType]().filter(filter).map (m)-> m.toJSON(tojson)
      attr.region = data
      attr.projectId = self.model.scene.project.id
      attr.currentRegion = _.find(data, (e)-> e.id is region)||{id: "global", shortName: lang.IDE.DASH_BTN_GLOBAL}
      $("#region-app-stack-wrap .dash-region-#{updateType}-wrap").replaceWith( dataTemplate["region_" + updateType](attr))
      return

    updateRegionTabCount : ()->
      resourceCount = @model.getResourcesCount( @region )
      $nav = $("#RegionResourceNav")
      for r, count of resourceCount
        $nav.children(".#{r}").children(".count-bubble").text( if count is "" then "-" else count )
      return


    switchResource : ( evt )->
      $("#RegionResourceNav").children().removeClass("on")
      @resourcesTab = $(evt.currentTarget).addClass("on").attr("data-type")
      @updateRegionResources()
      return

    deleteStack    : (event)->
      event.preventDefault();
      id = $( event.currentTarget ).closest("li").attr("data-id");
      (new AppAction({model: @model.scene.project.getOpsModel(id)})).deleteStack();
      false

    duplicateStack : (event)->
      event.preventDefault();
      id = $( event.currentTarget ).closest("li").attr("data-id");
      (new AppAction({model: @model.scene.project.getOpsModel(id)})).duplicateStack();
      false

    startApp       : (event)->
      event.preventDefault();
      id = $( event.currentTarget ).closest("li").attr("data-id");
      (new AppAction({model: @model.scene.project.getOpsModel(id)})).startApp();
      false

    stopApp        : (event)->
      event.preventDefault();
      id = $( event.currentTarget ).closest("li").attr("data-id");
      (new AppAction({model: @model.scene.project.getOpsModel(id)})).stopApp();
      false

    terminateApp   : (event)->
      event.preventDefault();
      id = $( event.currentTarget ).closest("li").attr("data-id");
      (new AppAction({model: @model.scene.project.getOpsModel(id)})).terminateApp();
      false

    openOps: (event)->
      event.preventDefault()
      url = $(event.currentTarget).attr("href")
      App.loadUrl url
      false

    switchLog: (event) ->

        that = @

        # switch
        if not event
            $btn = @$el.find('.dashboard-sidebar .dashboard-nav-activity')
        else
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
        memCol = new MemberCollection({projectId: @model.scene.project.id})
        memCol.fetch().done () ->
            that.renderLog('activity')
            that.renderLog('audit')

    renderLog: (type) ->

        activityModels = @logCol.history()
        auditModels = @logCol.audit()

        if type is 'activity'
            models = activityModels
            container = '.dashboard-log-activity'
        else if type is 'audit'
            models = auditModels
            container = '.dashboard-log-audit'

        renderMap = (origin) ->

            wordMap = {
                'create': 'created',
                'add': 'added',
                'save': 'saved',
                'remove': 'removed'
            }
            return wordMap[origin] if wordMap[origin]
            return origin

        dataAry = _.map models, (data) ->

            try

                email = Base64.decode(data.get('email'))?.email?.trim().toLowerCase() if data.get('email')
                avatar = "https://www.gravatar.com/avatar/#{CryptoJS.MD5(email).toString()}" if email
                action = data.get('action')?.toLowerCase()
                return {
                    name: Base64.decode(data.get('usercode')),
                    action: renderMap(action),
                    type: data.get('type')?.toLowerCase(),
                    target: data.get('target'),
                    avatar: avatar,
                    time: MC.intervalDate(new Date(data.get('time')))
                }

            catch err

                return null

        $container = @$el.find('.dashboard-sidebar').find(container)

        if dataAry.length
            $container.html Template.activityList(dataAry)
        else
            $container.html Template.noActivity()

  }
