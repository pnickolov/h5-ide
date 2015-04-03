

define [ "ApiRequest",
    "./ProjectTpl",
    "OpsModel"
    "UI.modalplus",
    "i18n!/nls/lang.js",
    "constant",
    "backbone",
    "jquerysort"
    "UI.parsley",
    "UI.errortip",
    "MC.validate"
], ( ApiRequest, ProjectTpl, OpsModel, Modal, lang, constant )->

  ProjectCreation = Backbone.View.extend {

    events:
      "click .new-project-cancel" : "cancel"
      "click .new-project-create" : "create"

    initialize : ()->
      @modal = new Modal {
        template      : ProjectTpl.newProject()
        title         : lang.IDE.SETTINGS_CREATE_PROJECT_TITLE
        disableClose  : true
        disableFooter : true
        width         : "500px"
      }
      @setElement @modal.tpl
      return

    cancel : ()-> @modal.close()
    create : ()->
      # credit: song
      modal = @modal
      modal.tpl.find(".billing-info-err").hide()

      $create = modal.tpl.find(".new-project-create")

      $name = modal.tpl.find("#new-project-name")
      $firstname = modal.tpl.find("#new-project-fn")
      $lastname = modal.tpl.find("#new-project-ln")
      $email = modal.tpl.find("#new-project-email")
      $number = modal.tpl.find("#new-project-card")
      $expire = modal.tpl.find("#new-project-date")
      $cvv = modal.tpl.find("#new-project-cvv")
      valid = true

      # deal expire
      $expire.parsley 'custom', (val) -> null
      expire = $expire.val()
      expireAry = expire.split('/')
      if expire.match(/^\d\d\/\d\d$/g) # MM/YYYY -> MM/20YY
        expire = "#{expireAry[0]}/20#{expireAry[1]}"
      else if expire.match(/^\d\d\d\d$/g) # MM/YY -> MM/20YY
        expire = "#{expire.substr(0,2)}/20#{expire.substr(2,2)}"
      else if expire.match(/^\d\d\/\d\d\d\d$/g) # MM/YYYY -> MM/YYYY
        expire = expire
      else if expire.match(/^\d\d\d\d\d\d$/g) # MMYYYY -> MM/YYYY
        expire = "#{expire.substr(0,2)}/#{expire.substr(2,4)}"
      else if expire.match(/^\d\d\d$/g) # MYY -> 0M/20YY
        expire = "0#{expire.substr(0,1)}/20#{expire.substr(1,2)}"
      else
        $expire.parsley 'custom', (val) ->
          return lang.IDE.SETTINGS_CREATE_PROJECT_EXPIRE_FORMAT if val.indexOf('/') is -1
          return null

      modal.tpl.find("input").each (idx, dom) ->
        # if not $(dom).hasClass('new-project-cvv')
        if not $(dom).parsley('validate')
          valid = false
          return false

      if valid
        $create.prop 'disabled', true
        App.model.createProject({
          name      : $name.val()
          firstname : $firstname.val()
          lastname  : $lastname.val()
          email     : $email.val()
          card      : {
            number : $number.val()
            expire : expire
            cvv    : $cvv.val()
          }
        }).then ( project )->
          modal.close -> App.loadUrl( project.url() )
        .fail ( error )->
          try
            msgObj = JSON.parse(error.result)
            if _.isArray(msgObj.errors)
              modal.tpl.find(".billing-info-err").show().html msgObj.errors.join('<br/>')
          catch err
            notification 'error', error.result or error.msg
          # modal.tpl.find(".new-project-info").toggleClass("error", true).html( error.msg )
          return
        .done () ->
          $create.prop 'disabled', false
  }

  HeaderPopup = Backbone.View.extend {
    constructor : ( attr )->
      @[key] = value for key, value of attr

      @setElement $( "<div class='hp-popup-overlay'></div>" ).appendTo( "body" ).on("click", (evt)=> @closeOnClick(evt))
      @render()

      Backbone.View.call this
      return
    closeOnEvent : ()-> true
    closeOnClick : ( evt )->
      if evt.target is @el or ( @closeOnEvent and @closeOnEvent( evt ) )
        @close()
    close : ()->
      @remove()
      if @onClose then @onClose( @ )
      return
  }

  UserPopup = HeaderPopup.extend {
    events : { "click .logout" : "logout" }
    render : ()-> @$el.html ProjectTpl.usermenu()
    logout : ()-> App.logout()
  }

  AssetListPopup = HeaderPopup.extend {
    events :
      "click .off-canvas-tab" : "switchTab"

    initialize : ()->
      @listenTo @project, "change:stack", @render
      @listenTo @project, "change:app",   @render
      @listenTo @project, "update:stack", @render
      @listenTo @project, "update:app",   @render
      return

    closeOnEvent : ( evt )-> $(evt.target).hasClass("route")

    switchTab : ( evt )->
      $tgt = $(evt.currentTarget)
      $tgt.parent().children().removeClass("selected")
      $tgt.addClass("selected")
      id = $tgt.attr("data-id")
      @$el.find(".ph-asset-list-wrap").children().hide().filter( "[data-id='#{id}']" ).show()
      @showApp = id is "app"
      return

    render : ()->
      @$el.html ProjectTpl.assetList({
        apps    : @project.apps().groupByRegion()
        stacks  : @project.stacks().groupByRegion()
        showApp : @showApp
      })
  }

  ProjectListPopup = HeaderPopup.extend {

    render : ()->
      projects = []
      for p in App.model.projects().models
        projects.push {
          id   : p.id
          url  : p.url()
          name : p.get("name")
          selected : p is @project
          private : p.isPrivate()
        }
      @$el.html ProjectTpl.projectList( projects )
      @$el.find(".create-new-project").on "click", (_.bind @createProject, @)
      @

    createProject : ()-> new ProjectCreation()
  }

  NotificationPopup = HeaderPopup.extend {

    initialize : ()->
      @listenTo App.model.notifications(), "change", @renderPiece
      @listenTo App.model.notifications(), "add",    @renderPiece

    pieceTpl : ( m )->
      target  = m.target()
      project = m.targetProject()

      duration = m.get("duration")
      if duration
        if duration < 60
          duration = sprintf lang.TOOLBAR.TOOK_XXX_SEC, duration
        else
          duration = sprintf lang.TOOLBAR.TOOK_XXX_MIN, Math.round(duration/60)

      ProjectTpl.notifyListItem({
        name     : target.get("name")
        id       : target.id
        pname    : project.get("name")
        pid      : project.id
        time     : MC.dateFormat( new Date( m.get("startTime") * 1000 ) , "hh:mm yyyy-MM-dd")
        duration : duration
        error    : m.get("error")
        desc     : @getNotifyDesc( m )
        isNew    : m.isNew()
        klass    : [ "processing", "success", "failure", "rollingback" ][m.get("state")]
      })

    renderPiece : ( m )->
      if not m
        @render()
        return

      tgt  = @$el.find("ul")
      item = tgt.children("[data-id='#{m.id}']")
      if not item.length
        tgt.prepend( @pieceTpl(m) )
      else
        item.after( @pieceTpl(m) ).remove()
      return

    render : ()->
      tpl = ""
      for m in App.model.notifications().models
        tpl += @pieceTpl( m )

      @$el.html ProjectTpl.notifyList()
      if tpl
        @$el.find( "ul" ).html( tpl )
      return

    getNotifyDesc : ( n )->
      switch n.get("action")
        when constant.OPS_CODE_NAME.LAUNCH
          desc = [
            "is launching"
            "launched successfully"
            "failed to launch"
            "is rolling back"
          ]
        when constant.OPS_CODE_NAME.STOP
          desc = [
            "is stopping"
            "stopped successfully"
            "failed to stop"
            "is rolling back"
          ]
        when constant.OPS_CODE_NAME.START
          desc = [
            "is starting"
            "started successfully"
            "failed to start"
            "is rolling back"
          ]
        when constant.OPS_CODE_NAME.TERMINATE
          desc = [
            "is terminating"
            "terminated successfully"
            "failed to terminate"
            "is rolling back"
          ]
        when constant.OPS_CODE_NAME.UPDATE, constant.OPS_CODE_NAME.STATE_UPDATE
          desc = [
            "is updating"
            "updated successfully"
            "failed to update"
            "is rolling back"
          ]
      desc[ n.get("state") ]


    close : ()->
      @stopListening()
      App.model.notifications().markAllAsRead()
      HeaderPopup.prototype.close.call this
  }

  Backbone.View.extend {

    # Don't use backbone.view's event here. Because we should bind the event handler
    # directly to the header.

    initialize : ( attr )->

      @scene = attr.scene

      @tabsWidth = 0

      @setElement $( ProjectTpl.frame() ).appendTo( "#scenes" )
      @render()

      @$tabbar   = @$el.find(".ws-tabbar")
      @$wsparent = @$el.find(".ws-content")

      self = @
      @$el.find(".ws-tabs").dragsort {
        horizontal : true
        dragSelectorExclude : ".fixed, .icon-close"
        dragEnd : ()->
          self.updateTabOrder()
      }

      $header = @$header = @$el.find(".project-header")
      $header.on "click", ".ws-tabbar li",          ( evt )-> self.onTabClick( evt )
      $header.on "click", ".ws-tabbar .icon-close", ( evt )-> self.onTabClose( evt )
      $header.on "click", ".popuptrigger", ( evt )-> self[ $( evt.currentTarget ).attr("data-popup") ]( evt.currentTarget )

      $header.on "click", ".icon-support", ()->
        if window.Intercom
          window.Intercom('showNewMessage')
          return false
        return

      nfs = App.model.notifications()
      @listenTo nfs, "change", @updateNotify
      @listenTo nfs, "add", @updateNotify
      @listenTo nfs, "remove", @updateNotify
      @updateNotify()

      @listenTo @scene, "switchWorkspace", @updateNotify
      return

    render : ()->
      @$el.find(".project-list").text( @scene.project.get("name") )
      @$el.find(".user-menu").text( App.user.get("username") )
      return

    ### -----------------
    # Header Related
    ----------------- ###
    showPopup : ( template, ignoreClicked )->
      $overlay = $( "<div class='hp-popup-overlay'>#{template}</div>" ).appendTo( "body" )

      oneTimeClicked = ( evt )->
        if ignoreClicked and ignoreClicked( evt.target ) then return

        console.log "popupclosed"
        $("body")[0].removeEventListener("click", oneTimeClicked, true)
        $overlay.remove()

      $("body")[0].addEventListener("click", oneTimeClicked, true)
      return $overlay

    popupProject : ()-> new ProjectListPopup({project:@scene.project})
    popupAsset   : ()-> new AssetListPopup({project:@scene.project})
    popupUser    : ()-> new UserPopup()
    popupNotify  : ()-> new NotificationPopup()

    updateNotify : ()->
      unread = App.model.notifications().where {isNew:true}

      ws   = @scene.getAwakeSpace()
      data = {opsModel:null}
      for n, idx in unread
        data.opsModel = n.target()
        if ws and ws.isWorkingOn( data )
          n.markAsRead()
          unread.splice( idx, 1 )
          break

      @$header.find(".icon-notification").attr("data-count", unread.length || "")
      return

    ### ------------------
    # Workspace Related
    ------------------ ###
    getTabElementById : ( id )-> @$tabbar.find("[data-id='#{id}']")

    updateTabOrder : ()-> @trigger "wsOrderChanged"
    spaceOrder     : ()-> _.map @$tabbar.find("li"), ( li )-> $( li ).attr("data-id")

    moveSpace : ( id, isFixed, idx )->
      $tgt = @getTabElementById(id)
      if not $tgt.length then return

      if isFixed
        $group = @$tabbar.children(".ws-fixed-tabs")
      else
        $group = @$tabbar.children(".ws-tabs")
        idx   -= @$tabbar.children().length

      $after = $group.children().eq( idx )
      if $after.length
        $tgt.insertBefore( $after )
      else
        $group.append( $tgt )
      return

    awakeSpace : ( id )->
      @$tabbar.find(".active").removeClass("active")
      @getTabElementById(id).addClass("active")
      return

    updateSpace : ( id, title, klass )->
      $tgt = @getTabElementById( id )

      if title isnt undefined or title isnt null
        @tabsWidth -= $tgt.outerWidth()
        $tgt.attr("title", title)
        $tgt.children("span").text( title )
        @tabsWidth += $tgt.outerWidth()
        @ensureTabSize()

      if klass isnt undefined or klass isnt null
        if $tgt.hasClass("active")
          klass += " active"
        $tgt.attr("class", klass )
      return

    onTabClick : ( evt )->
      @trigger "wsClicked", $( evt.currentTarget ).attr("data-id")
      return

    onTabClose : ( evt )->
      @trigger "wsClosed", $( evt.currentTarget ).closest("li").attr("data-id")
      false

    removeSpace : ( id )->
      $tgt = @getTabElementById(id)
      @tabsWidth -= $tgt.outerWidth()
      $tgt.remove()
      @ensureTabSize()
      $tgt

    showLoading : ()-> $("#GlobalLoading").show()
    hideLoading : ()-> $("#GlobalLoading").hide()

    ensureTabSize : ()->
      flexibleTB = @$tabbar.children(".ws-tabs")

      windowWidth = $(window).width()
      availableSpace = windowWidth - flexibleTB.offset().left - @$tabbar.siblings("nav").width()

      children = flexibleTB.children()
      if @tabsWidth < availableSpace
        children.css("max-width", "auto")
      else
        availableSpace = Math.floor( availableSpace / children.length )
        children.css("max-width", availableSpace)
      return

    addSpace : ( data, index = -1, fixed = false )->
      # data = {
      #   title    : ""
      #   id       : ""
      #   closable : false
      #   klass    : ""
      # }

      if fixed
        $parent = @$tabbar.children(".ws-fixed-tabs")
      else
        $parent = @$tabbar.children(".ws-tabs")

      tpl = "<li class='#{data.klass}' data-id='#{data.id}' title='#{data.title}'><span class='truncate'>#{data.title}</span>"
      if data.closable
        tpl += '<i class="icon-close" title="' + lang.TOOLBAR.TIT_CLOSE_TAB + '"></i>'

      $tgt = $parent.children().eq( index )
      if $tgt.length
        $tgt = $( tpl + "</li>" ).insertAfter $tgt
      else
        $tgt = $( tpl + "</li>" ).appendTo $parent

      @tabsWidth += $tgt.outerWidth()
      @ensureTabSize()
      $tgt
  }
