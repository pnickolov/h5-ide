
define [
  "scenes/ProjectScene"
  "scenes/Settings"
  "scenes/StackStore"
  "backbone"
], ( ProjectScene, Settings, StackStore )->

  ###########
  # Routers
  ###########
  Backbone.Router.extend {

    routes :
      ""                                : "openProject"
      "project(/:project)"              : "openProject"
      "project/:project/ops(/:ops)"     : "openProject"
      "project/:project/unsaved(/:ops)" : "openProject"

      "settings(/:page)"   : "openSettings"
      "store/:sampleId"    : "openStore"

    openStore : ( id )-> new StackStore({ id : id })

    openSettings : ()->
      console.log "opening store", arguments
      theSettings = new Settings()
      theSettings.activate()
      theSettings.view.$el.find("h1").html arguments[0] || "settings"
      return

    openProject : ( projectId, opsModelId )-> new ProjectScene( projectId, opsModelId )

    start : ()->
      if not Backbone.history.start({pushState:true})
        console.warn "URL doesn't match any routes."
        @navigate("/", {replace:true, trigger:true})

      self = @
      $( document ).on "click", "a.route", ( evt )-> self.onRouteClicked( evt )
      return

    onRouteClicked : ( evt )->
      href = $(evt.currentTarget).attr("href")

      currentUrl = Backbone.history.fragment

      # Normalize href so that it won't contain trailling "/"
      lastChar = href[ href.length - 1 ]
      if lastChar is "/" or lastChar is "\\"
        href = href.substring( 0, href.length - 1 )

      result = @navigate href, { replace : true, trigger : true }

      # The `result` can be true | false | undefined
      if result is true
        $( document ).trigger "urlroute"
      else if result is false
        console.log "URL doesn't match any routes."
        @navigate currentUrl, { replace : true }

      false
  }
