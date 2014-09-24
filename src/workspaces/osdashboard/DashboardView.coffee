
define [
  './DashboardTpl'
  './DashboardTplData'
  "constant"
  "i18n!/nls/lang.js"
  "CloudResources"
  'appAction'
  "backbone"
  "UI.tooltip"
  "UI.table"
  "UI.nanoscroller"
], ( Template, TemplateData, constant, lang, CloudResources, appAction )->

  Backbone.View.extend {

    events :
      'click #OsReloadResource' : 'reloadResource'
      'click .icon-new-stack'   : 'createStack'

      'click .ops-list-switcher'              : 'switchAppStack'
      "click .dash-ops-list > li"             : "openItem"
      "click .dash-ops-list .delete-stack"    : "deleteStack"
      'click .dash-ops-list .duplicate-stack' : 'duplicateStack'
      "click .dash-ops-list .start-app"       : "startApp"
      'click .dash-ops-list .stop-app'        : 'stopApp'
      'click .dash-ops-list .terminate-app'   : 'terminateApp'

      'click .resource-tab'                   : 'switchResource'

    resourcesTab: 'OSSERVER'

    initialize : ()->
      @opsListTab = "stack"
      @region     = "guangzhou"
      @lastUpdate = +(new Date())

      @setElement( $(Template.frame()).eq(0).appendTo("#main") )

      @updateOpsList()
      @updateResList()
      @updateRegionResources()

      #window.CloudResources = CloudResources
      #window.constant = constant

      self = @
      setInterval ()->
        if not $("#OsReloadResource").hasClass("reloading")
          $("#OsReloadResource").text( MC.intervalDate(self.lastUpdate/1000) )
        return
      , 1000 * 60

      # Add a custom template to the MC.template, so that the UI.bubble can use it to render.
      # MC.template.dashboardBubble = _.bind @dashboardBubble, @
      # MC.template.dashboardBubbleSub = _.bind @dashboardBubbleSub, @
      return

    awake : ()-> @$el.show().children(".nano").nanoScroller(); return
    sleep : ()-> @$el.hide()

    ###
      rendering
    ###
    updateOpsList : ()->
      $opsListView = @$el.find(".dash-ops-list-wrapper")

      tojson = {thumbnail:true}
      filter = (m)-> m.isExisting()
      mapper = (m)-> m.toJSON(tojson)
      stacks = App.model.stackList().filter( filter )
      apps   = App.model.appList().filter( filter )

      # Update count
      $switcher = $opsListView.children("nav")
      $switcher.find(".count").text( apps.length )
      $switcher.find(".stack").find(".count").text( stacks.length )

      # Update list
      if @opsListTab is "stack"
        html = Template.stackList( stacks.map(mapper) )
      else
        html = Template.appList( apps.map(mapper) )

      $opsListView.children("ul").html html
      return

    updateResList: () ->
      @$('.dash-ops-resource-list').html Template.resourceList {}

    updateAppProgress : ( model )->
      if model.get("region") is @region and @regionOpsTab is "app"

        console.log "Dashboard Updated due to app progress changes."

        $li = $el.find(".dash-ops-list").children("[data-id='#{model.id}']")
        if not $li.length then return
        $li.children(".region-resource-progess").show().css({width:model.get("progress")+"%"})
        return

    ###
      View logics
    ###
    switchAppStack: ( evt ) ->
      $target = $(evt.currentTarget)
      if $target.hasClass("on") then return
      $target.addClass("on").siblings().removeClass("on")

      @opsListTab = if $target.hasClass("stack") then "stack" else "app"
      @updateOpsList()
      return

    switchResource : ( evt )->
      @$(".resource-list-nav").children().removeClass("on")
      @resourcesTab = $(evt.currentTarget).addClass("on").attr("data-type")
      @updateRegionResources()
      return

    updateResourceCount : ()->
      resourceCount = @model.getResourcesCount( @region )
      $nav = $(".resource-list-nav")
      for r, count of resourceCount
        $nav.children(".#{r}").children(".count-bubble").text( if count is "" then "-" else count )
      return

    updateRegionResources : ( type )->
      @updateResourceCount()
      if type and type isnt @resourcesTab then return

      type = constant.RESTYPE[ @resourcesTab ]
      if not @model.isOsResReady( @region, type )
        tpl = '<div class="dashboard-loading"><div class="loading-spinner"></div></div>'
      else
        tpl = TemplateData["resource_#{@resourcesTab}"]( @model.getOsResData( @region, type ) )

      $(".resource-list-body").html( tpl )

    openItem    : ( event )-> App.openOps( $(event.currentTarget).attr("data-id") )
    createStack : ( event )-> App.createOps( "guangzhou", "openstack", "awcloud" )

    markUpdated : ()-> @lastUpdate = +(new Date()); return

    reloadResource : ()->
      if $("#OsReloadResource").hasClass("reloading")
        return

      $("#OsReloadResource").addClass("reloading").text("")
      App.discardAwsCache().done ()->
        $("#OsReloadResource").removeClass("reloading").text("just now")
      return

    deleteStack    : (event)-> appAction.deleteStack $( event.currentTarget ).closest("li").attr("data-id"); false
    duplicateStack : (event)-> appAction.duplicateStack $( event.currentTarget ).closest("li").attr("data-id"); false
    startApp       : (event)-> appAction.startApp $( event.currentTarget ).closest("li").attr("data-id"); false
    stopApp        : (event)-> appAction.stopApp $( event.currentTarget ).closest("li").attr("data-id"); false
    terminateApp   : (event)-> appAction.terminateApp $( event.currentTarget ).closest("li").attr("data-id"); false
  }
