
define ["Workspace", "workspaces/dashboard/DashboardView", "workspaces/dashboard/DashboardModel"], ( Workspace, DashboardView, DashboardModel )->

  class Dashboard extends Workspace

    isFixed  : ()-> true
    tabClass : ()-> "icon-dashboard"
    title    : ()-> "Dashboard"


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

      @listenTo App.model.stackList(), "change", ()-> self.__renderControl "updateRegionList", arguments
      @listenTo App.model.appList(),   "change", ()-> self.__renderControl "updateRegionList", arguments

      @view.listenTo App.model.appList(), "change:progress", @view.updateAppProgress

      # Watch changes in aws resources
      @listenTo @model, "change:globalResources", ()->
        self.view.markUpdated()
        self.__renderControl "updateGlobalResources"

      @listenTo @model, "change:regionResources", ()->
        self.view.markUpdated()
        self.__renderControl "updateRegionResources"

      # Watch updates of visualize unmanaged vpc
      @listenTo @model, "change:visualizeData", ()-> self.__renderControl "updateVisModel"

      # Watch changes in user
      @listenTo App.user, "change:credential", ()->
        self.model.clearVisualizeData()
        self.model.fetchAwsResources()
        self.view.updateDemoView()

      @model.fetchAwsResources()

      @__renderControlMap = {}
      return

    sleep : ()->
      @__renderControlMap = {}
      @view.$el.hide()
      return

    awake : ()->
      @view[method]() for method of @__renderControlMap
      @__renderControlMap = null
      @view.$el.show()
      return

    __renderControl : ( method, args )->
      if @__renderControlMap
        console.log "DashboardView's render is throttled, method name: #{method}"
        @__renderControlMap[ method ] = true
      else
        @view[method].apply(@view, args)
      return

    isDashboard : ()-> true

  Dashboard
