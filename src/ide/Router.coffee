
define ["backbone"], ()->

  ###########
  # Routers
  ###########
  Backbone.Router.extend {

    routes :
      "" : "openDashboard"

    initialize : ()->
      @route /^ops\/([^/]+$)/,   "openOps"
      @route /^store\/([^/]+$)/, "openStore"
      return

    openStore : ( id )->
      opsModel = App.model.stackList().findWhere({sampleId:id})
      if not opsModel
        opsModel = App.model.createSampleOps( id )
      Router.navigate( opsModel.url(), {replace:true} )
      App.openOps( opsModel )
      return

    openOps : ( id )->
      if not App.openOps( id )
        Router.navigate("/", {replace:true})
      return

    openDashboard : ()->
      if window.Dashboard
        window.Dashboard.activate()

    start : ()->
      if not Backbone.history.start({pushState:true})
        console.warn "URL doesn't match any routes."
        @navigate("/", {replace:true})

      # Add one more route to handle local item after we started the router.
      @route /^ops\/([^/]+)/, "openOps"
      return

    execute : ()->
      @__forceReplace = true
      Backbone.Router.prototype.execute.apply this, arguments
      @__forceReplace = false
      return

    navigate : ( fragment, options )->
      if @__forceReplace
        options = options || {}
        options.replace = true

      $( document ).trigger "urlroute"

      Backbone.Router.prototype.navigate.apply this, arguments
  }
