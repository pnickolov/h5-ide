
define [
  './DashboardTpl'
  './DashboardTplData'
  './VisualizeVpcTpl'
  "UI.modalplus"
  "constant"
  "backbone"
  "UI.scrollbar"
  "UI.tooltip"
  "UI.table"
], ( template, tplPartials, VisualizeVpcTpl, Modal, constant )->

  Helper = {
    scrollToResource: ->
      scrollContent = $( '#global-region-wrap .scroll-content' )
      scrollContent.addClass 'scroll-transition'
      setTimeout ->
        scrollContent.removeClass( 'scroll-transition' )
        null
      , 100

      scrollTo = $('#global-region-map-wrap').height() + 7
      scrollbar.scrollTo( $( '#global-region-wrap' ), { 'top': scrollTo } )
  }

  Backbone.View.extend {

    events :
      "click .global-map-item"                                       : "gotoRegionFromMap"
      "click .global-map-item .app"                                  : "gotoRegionFromMap"
      'click .recent-list-item, .region-resource-list li'            : 'openItem'
      'click .table-app-link-clickable'                              : 'openItem'
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

      'click #ImportStack'     : 'importJson'
      'click #VisualizeVPC'    : 'visualizeVPC'
      'click .show-credential' : 'showCredential'
      'click #RefreshResource' : 'reloadResource'




    initialize : ()->
      @regionOpsTab = "stack"
      @region       = "global"
      @resourcesTab = "INSTANCE"

      data = _.map constant.REGION_LABEL, ( name, id )->
        id   : id
        name : name
        shortName : constant.REGION_SHORT_LABEL[ id ]

      @setElement( $(template(data)).appendTo("#main") )

      # Need to do a init update because the data might arrive first
      @updateOpsList()
      @updateDemoView()

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
      $tabs.eq(0).children("span").text apps.length
      $tabs.eq(1).children("span").text stacks.length

      $( '#global-region-recent-list' ).html tplPartials.recent { stacks:stacks, apps:apps }

      @updateRegionAppStack()
      return

    updateRegionList  : ( model )->
      console.log "Dashboard Updated due to state changes in app list."

      if model.get("region") is @region and @regionOpsTab is "app"
        @updateRegionAppStack()

    updateAppProgress : ( model )->
      if model.get("region") is @region and @regionOpsTab is "app"

        console.log "Dashboard Updated due to app progress changes."

        $li = $("#region-resource-app-wrap").children("[data-appid='#{model.id}']")
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
    gotoRegionFromMap : ( evt )->
      $tgt = $( evt.currentTarget )
      region = $( evt.currentTarget ).closest("li").attr("id")

      $( "#region-switch-list li[data-region=#{region}]" ).click()
      Helper.scrollToResource()

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
      @region = region

      $( '#region-switch').find('span').text( target.text() )

      if region is "global"
        isDataReady = @model.isAwsResReady()
        $("#region-view" ).hide()
        $("#global-view" ).toggle( isDataReady )
        $("#dashboard-loading").toggle( not isDataReady )
      else
        # Ask model to get datas for us.
        @model.fetchAwsResources( region )
        $("#region-view" ).show()
        $("#global-view" ).hide()
        @updateRegionAppStack()
        @updateRegionResources()
      return

    switchAppStack: ( evt ) ->
      $target = $(evt.currentTarget)
      if $target.hasClass("on") then return
      $target.addClass("on").siblings().removeClass("on")

      @regionOpsTab = if $target.hasClass("stack") then "stack" else "app"
      $("#region-view").find(".region-resource-list").hide().eq( $target.index() ).show()
      return

    switchResource : ( evt )->
      $("#region-resource-wrap").children("nav").children().removeClass("on")
      @resourcesTab = $(evt.currentTarget).addClass("on").attr("data-type")
      data = @model.getAwsResData( @region )
      $("#region-aws-resource-data").html( tplPartials["resource#{@resourcesTab}"](data) )
      console.log data
      return

    importJson : ()->
      modal MC.template.importJSON()

      reader = new FileReader()
      reader.onload = ( evt )->
        error = App.importJson( reader.result )
        if error
          $("#import-json-error").html error
        else
          modal.close()
          reader = null
        null

      reader.onerror = ()->
        $("#import-json-error").html lang.ide.POP_IMPORT_ERROR
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
    createStack : ( event )-> App.createOps( $(event.currentTarget).attr("data-id") )

    markUpdated    : ()-> $("#RefreshResource").removeClass("reloading").text("just now")
    reloadResource : ()->
      $("#RefreshResource").addClass("reloading").text("")
      @model.reloadResource()

    deleteStack    : (event)-> App.deleteStack $( event.currentTarget ).closest("li").attr("data-id"); false
    duplicateStack : (event)-> App.duplicateStack $( event.currentTarget ).closest("li").attr("data-id"); false
    startApp       : (event)-> App.startApp $( event.currentTarget ).closest("li").attr("data-id"); false
    stopApp        : (event)-> App.stopApp $( event.currentTarget ).closest("li").attr("data-id"); false
    terminateApp   : (event)-> App.terminateApp $( event.currentTarget ).closest("li").attr("data-id"); false

    updateVisModel : ()->
      if not @visModal then return
      @visModal.tpl.find(".modal-body").html VisualizeVpcTpl({
        ready : @model.isVisualizeReady()
        fail  : @model.isVisualizeTimeout() || @model.isVisualizeFailed()
        data  : @model.get("visualizeData")
      })
      return

    visualizeVPC : ()->
      @model.visualizeVpc()
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
        title         : "Select a VPC to be visualized:"
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

    updateGlobalResources : ( isDataReady )->
      if not isDataReady
        if @region is "global" then $("#dashboard-loading").show()
        $("#global-view").empty().hide()
      else
        @markUpdated()
        $("#global-view").html( tplPartials.globalResources( @model.getAwsResData() ) )
        if @region is "global"
          $("#dashboard-loading").hide()
          $("#global-view").show()
      return

    updateRegionResources : ()->
      if @region is "global" then return

      if not @model.isAwsResReady( @region )
        $("#dashboard-loading").show()
        $("#region-resource-wrap").empty().hide()
      else
        @markUpdated()
        $("#dashboard-loading").hide()
        data = @model.getAwsResData( @region )
        $("#region-resource-wrap").html(tplPartials.regionResourceTab( data )).show()
        $("#region-resource-wrap").children("nav").children("[data-type='#{@resourcesTab}']").addClass("on")
        $("#region-aws-resource-data").html( tplPartials["resource#{@resourcesTab}"](data) )
  }
