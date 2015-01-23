

define [ "./ProjectTpl", "i18n!/nls/lang.js", "constant", "backbone", "jquerysort" ], ( ProjectTpl, lang, constant )->

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

    render : ()->
      @$el.find(".project-list").text( @scene.project.get("name") )
      @$el.find(".user-menu").text( App.user.get("username") )
      return

    ### -----------------
    # Header Related
    ----------------- ###
    showPopup : ( template, ignoreClicked )->
      $overlay = $( template ).appendTo( "body" )

      oneTimeClicked = ( evt )->
        if ignoreClicked and ignoreClicked( evt.target ) then return

        console.log "popupclosed"
        $("body")[0].removeEventListener("click", oneTimeClicked, true)
        $overlay.remove()

      $("body")[0].addEventListener("click", oneTimeClicked, true)
      return $overlay

    popupProject : ()->
      projects = []
      for p in App.model.projects().models
        if p is @scene.project
          projects.push { id : p.id, name : p.get("name") }

      projects = _.sortBy projects, ( p )-> p.name

      $popup = @showPopup( ProjectTpl.projectList( projects ) )
      $popup.on "click", "createNewProject", ()-> # TODO : Create new project
      return

    popupAsset  : ()->
      $popup = @showPopup( ProjectTpl.assetList({
        apps   : @scene.project.apps().groupByRegion()
        stacks : @scene.project.stacks().groupByRegion()
      }), ( target )->
        $target = $( target )
        if $target.closest(".hp-asset-list").length
          return !$target.hasClass("route")
        false
      )

      $popup.children("nav").on("click", ".off-canvas-tab", ( evt )->
        $tgt = $(evt.currentTarget)
        $tgt.parent().children().removeClass("selected")
        $tgt.addClass("selected")
        $popup.children(".hp-asset-list-wrap").children().hide().filter( "[data-id='#{$tgt.attr('data-id')}']" ).show()
      )
      return

    popupUser : ()->
      @showPopup( ProjectTpl.usermenu() ).on "mouseup", ".logout", ()-> App.logout()
      return

    popupNotify : ()->



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
