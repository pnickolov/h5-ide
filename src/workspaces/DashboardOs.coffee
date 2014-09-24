
define ["Workspace", "workspaces/osdashboard/DashboardView", "workspaces/osdashboard/DashboardModel", 'i18n!/nls/lang.js'], ( Workspace, DashboardView, DashboardModel, lang )->

  class Dashboard extends Workspace

    isFixed  : ()-> true
    tabClass : ()-> "icon-dashboard"
    title    : ()-> lang.IDE.NAV_TIT_DASHBOARD
    url      : ()-> "/"


    initialize : ()->
      @model = new DashboardModel()
      @view  = new DashboardView({model:@model})

      # For consistent, put every event listening here.
      # So that the view doesn't depend on any other modules.
      # Notice that the dependencies are not reduced, just transferred.

      # Watch changes in applist/stacklist
      self = @
      @listenTo App.model.stackList(), "update", ()-> self.__renderControl "updateOpsList"
      @listenTo App.model.appList(),   "update", ()-> self.__renderControl "updateOpsList"

      @listenTo App.model.stackList(), "change", ()-> self.__renderControl "updateOpsList", arguments
      @listenTo App.model.appList(),   "change", ()-> self.__renderControl "updateOpsList", arguments

      @listenTo @model, "change:regionResources", ( type ) ->
        self.view.markUpdated()
        self.__renderControl "updateRegionResources", arguments

      @view.listenTo App.model.appList(), "change:progress", @view.updateAppProgress

      @model.fetchOsResources()

      @__renderControlMap = {}
      return

    sleep : ()->
      @__renderControlMap = {}
      @view.sleep()
      return

    awake : ()->
      @view[method]() for method of @__renderControlMap
      @__renderControlMap = null
      @view.awake()
      return

    __renderControl : ( method, args )->
      if @__renderControlMap
        console.log "DashboardView's render is throttled, method name: #{method}"
        @__renderControlMap[ method ] = true
      else
        @view[method].apply(@view, args)
      return

  Dashboard
