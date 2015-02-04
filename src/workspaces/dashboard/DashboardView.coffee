define [ "./DashboardTpl", "./ImportDialog", "./DashboardTplData", "constant", "./VisualizeDialog", "AppAction", "backbone" ], ( Template, ImportDialog, dataTemplate, constant, VisualizeDialog, AppAction )->
  Backbone.View.extend {

    events :
      "click .dashboard-header .create-stack"   : "createStack"
      "click .dashboard-header .import-stack"   : "importStack"
      "click .dashboard-header .icon-visualize" : "importApp"
      "click .dashboard-sidebar .dashboard-nav-log" : "switchLog"
      "click .dashboard-sidebar nav buttton"    : "switchLog"
      'click #region-switch-list li'    : 'switchRegion'
      'click #region-resource-tab li'   : 'switchAppStack'
      'click .resource-tab'             : 'switchResource'

    initialize : ()->
      @regionOpsTab = "stack"
      @resourcesTab = "INSTANCE"
      @region       = "global"
      data = _.map constant.REGION_LABEL, ( name, id )->
        id   : id
        name : name
        shortName : constant.REGION_SHORT_LABEL[ id ]
      @setElement $( Template.main({
        data : data
        providers : @model.supportedProviders()
      }) ).appendTo( @model.scene.spaceParentElement() )

      # listen logs change
      logCol = @model.scene.project.logs()
      @activityModels = logCol.history()
      @auditModels = logCol.audit()
      logCol.on('change', @switchLog, this)

      @render()
      return

    render : ()->
      # Update the dashboard in this method.
      @updateDemoView()
      @updateGlobalResources()
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

    updateRegionAppStack : ()->
      self = @
      attr = { apps:[], stacks:[], region : @region }
      attr[ @regionOpsTab ] = true

      region = @region
      if region isnt "global"
        filter = (f)-> f.get("region") is region && f.isExisting()
        tojson = {thumbnail:true}

        attr.stacks = self.model.scene.project.stacks().filter(filter).map (m)-> m.toJSON(tojson)
        attr.apps   = self.model.scene.project.apps().filter(filter).map   (m)-> m.toJSON(tojson)

      $('#region-app-stack-wrap').html( dataTemplate.region_app_stack(attr) )
      return


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
        # Ask model to get data for us.
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


    updateRegionResources : ()->
      if @region is "global" then return
      @updateRegionTabCount()
      type = constant.RESTYPE[ @resourcesTab ]
      if not @model.isAwsResReady( @region, type )
        tpl = '<div class="dashboard-loading"><div class="loading-spinner"></div></div>'
      else
        tpl = dataTemplate["resource#{@resourcesTab}"]( @model.getAwsResData( @region, type ) )
      $("#RegionResourceData").html( tpl )


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

    switchLog: (event) ->

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

        # render activity
        activitys = _.map @activityModels, (activity) ->

            email = Base64.decode(activity.email)
            return {
                avatar: CryptoJS.MD5(email.trim().toLowerCase()).toString(),
                username: Base64.decode(activity.get('usercode')),
                event: activity.get('detail'),
                time: new Date(activity.get('time'))
            }

        if activitys.length
            $sidebar.find('.dashboard-log-activity').html Template.activityList(activitys)
        else
            $sidebar.find('.dashboard-log-activity').html Template.noActivity()

        # render audit
        audits = _.map @auditModels, (audit) ->

            email = Base64.decode(audit.email)
            return {
                avatar: CryptoJS.MD5(email.trim().toLowerCase()).toString(),
                username: Base64.decode(audit.get('usercode')),
                event: audit.get('detail'),
                time: new Date(audit.get('time'))
            }

        if audits.length
            $sidebar.find('.dashboard-log-audit').html Template.activityList(audits)
        else
            $sidebar.find('.dashboard-log-audit').html Template.noActivity(audits)

  }
