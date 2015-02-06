
define [
  "scenes/ProjectScene"
  "scenes/Settings"
  "scenes/StackStore"
  "scenes/Cheatsheet"
  "backbone"
], ( ProjectScene, Settings, StackStore, Cheatsheet )->

  ###########
  # Routers
  ###########
  Backbone.Router.extend {

    routes :
      ""                               : "openProject"
      "team(/:project)"                : "openProject"
      "team/:project/ops(/:ops)"       : "openProject"

      "settings"                       : "openSettings"
      "settings/:projectId(/:tab)"     : "openSettings"
      "store/:sampleId"                : "openStore"

      "cheatsheet"                     : "openCheatsheet"

    openStore : ( id )-> new StackStore({ id : id })

    openSettings : ( projectId, tab )-> new Settings { tab: tab, projectId: projectId }

    openProject : ( projectId, opsModelId )-> new ProjectScene( projectId, opsModelId )

    openCheatsheet : ()-> new Cheatsheet()

    start : ()->
      if not Backbone.history.start({pushState:true})
        console.warn "URL doesn't match any routes."
        @navigate("/", {replace:true, trigger:true})

      self = @
      $( document ).on "click", "a.route", ( evt )-> self.onRouteClicked( evt )

      # Add additional routes here.
      # These routes are diabled when the IDE is loading.
      @route "team/:project/unsaved(/:ops)", "openProject"
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
