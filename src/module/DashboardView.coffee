
define ['module/dashboard/template', 'module/dashboard/template_data',"constant", "backbone", "UI.scrollbar"], ( template, tplPartials, constant )->

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

    el : $("#tab-content-dashboard")[0]

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

      'click #global-import-stack'      : 'importJson'

      'click #global-refresh' : 'reloadResource'

      'click .region-resource-tab-item'           : 'switchResource'
      'click .global-region-resource-content a'   : 'switchRegionAndResource'

      'click .show-credential'             : 'showCredential'
      'click #global-region-visualize-VPC' : 'unmanagedVPCClick'


    initialize : ()->
      @regionOpsTab = "stack"
      @region = "global"

      data = _.map constant.REGION_LABEL, ( name, id )->
        id   : id
        name : name
        shortName : constant.REGION_SHORT_LABEL[ id ]

      @$el.html template data

      # Need to do a init update because the data might arrive first
      @updateOpsList()

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

      $( '#region-switch').find( 'span' )
          .text( target.text() )
          .data 'region', region

      isntGlobal = region isnt 'global'
      @$el.find( '#global-view' ).toggle( not isntGlobal )
      @$el.find( '#region-view' ).toggle( isntGlobal )
      if isntGlobal then @updateRegionAppStack()
      return

    switchAppStack: ( evt ) ->
      $target = $(evt.currentTarget)
      if $target.hasClass("on") then return
      $target.addClass("on").siblings().removeClass("on")

      @regionOpsTab = if $target.hasClass("stack") then "stack" else "app"
      $("#region-view").find(".region-resource-list").hide().eq( $target.index() ).show()

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
      zone.on "dragenter", ()->
          console.log "dragenter"
          $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", true)
      zone.on "dragleave", ()->
          console.log "dragleave"
          $(this).closest("#modal-import-json-dropzone").toggleClass("dragover", false)
      zone.on "dragover", ( evt )->
          dt = evt.originalEvent.dataTransfer
          if dt then dt.dropEffect = "copy"
          evt.stopPropagation()
          evt.preventDefault()
          null
      null

    openItem    : ( event )-> App.openOps( $(event.currentTarget).attr("data-id") )
    createStack : ( event )-> App.createOps( $(event.currentTarget).attr("data-id") )

    reloadResource : ()->
      $("#global-refresh").addClass "loading"
      @trigger "reloadResource"

    deleteStack : (event) ->
        App.deleteStack $( event.currentTarget ).closest("li").attr("data-id")
        false

    duplicateStack : (event) ->
        App.duplicateStack $( event.currentTarget ).closest("li").attr("data-id")
        false

    startApp : ( event )->
        App.startApp $( event.currentTarget ).closest("li").attr("data-id")
        false

    stopApp : ( event )->
        App.stopApp $( event.currentTarget ).closest("li").attr("data-id")
        false

    terminateApp : ( event )->
        App.terminateApp $( event.currentTarget ).closest("li").attr("data-id")
        false

  }
