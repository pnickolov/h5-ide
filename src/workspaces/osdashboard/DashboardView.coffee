
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
  "UI.bubble"
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

      window.CloudResources = CloudResources
      window.constant = constant

      self = @
      setInterval ()->
        if not $("#OsReloadResource").hasClass("reloading")
          $("#OsReloadResource").text( MC.intervalDate(self.lastUpdate/1000) )
        return
      , 1000 * 60

      # Add a custom template to the MC.template, so that the UI.bubble can use it to render.
      MC.template.osDashboardBubble = _.bind @osDashboardBubble, @
      return

    awake : ()-> @$el.show().children(".nano").nanoScroller(); return
    sleep : ()-> @$el.hide()

    osDashboardBubble : ( data )->
      # get Resource Data
      d = {
        id   : data.id
        data : @model.getOsResDataById( @region, constant.RESTYPE[data.type], data.id )?.toJSON()
      }
      d.data = d.data.system_metadata

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

      return TemplateData.bubbleResourceInfo  d

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
        @animateResourceCount(r)
      return

    animateResourceCount: (r)->
      nav = $(".resource-list-nav").children(".#{r}").append("""
      <svg class="rotate" viewbox="0 0 250 250">
        <path class="loader usage-quota" fill="#0099ff" transform="translate(125, 125)"/>
        <path class="loader usage-active" fill="#0099ff" transform="translate(125, 125)"/>
      </svg>""")
      console.log nav
      @animateUsage.bind(nav).call(nav,17, 23)


    animateUsage: (active, quota)->
      seconds = 40
      loaderBg = @find('.usage-quota')
      loader = @find('.usage-active')
      countUsage = @find ".count-usage"
      @a = 0
      pi = Math.PI
      t = (seconds / 360 * 1000)
      num = 0
      maxAngle = 270
      if @chartTimeOut then window.clearTimeout(@chartTimeOut)
      @chartTimeOut = null
      draw = (element,angle,direct)->
        #if element then a = 0
        @a++
        num += ((active) / maxAngle)
        tempAngle = (if direct then angle else @a)
        r = tempAngle * pi / 180
        x = Math.sin(r) * 125
        y = Math.cos(r) * - 125
        mid = if (tempAngle > 180) then 1 else 0
        anim = "M 0 0 v -125 A 125 125 1 #{mid} 1 #{x} #{y} z" #Magic, don't touch.
        element.attr( 'd' , anim)
        if not direct then countUsage.text Math.round(if num > quota then quota else num)
        if(@a < angle and not direct)
          @chartTimeOut = window.setTimeout ->
            draw(element, angle)
          , t
      draw = _.bind draw, @
      if active
        loaderBg.attr( 'fill' , "#4b4f8c")
        loader.attr( 'fill' , "#30bc00")
        draw(loaderBg, 270, true)
        draw(loader, (active/quota) * 270)
      else
        loaderBg.attr( 'fill' , "#5f5f5f")
        draw(loaderBg, 270, true)
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
