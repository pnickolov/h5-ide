
define ["Workspace", "workspaces/DashboardView", "workspaces/DashboardModel"], ( Workspace, DashboardView, DashboardModel )->

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
      @view.listenTo App.model.stackList(), "update", @view.updateOpsList
      @view.listenTo App.model.appList(),   "update", @view.updateOpsList

      @view.listenTo App.model.appList(), "change:state",    @view.updateRegionList
      @view.listenTo App.model.appList(), "change:progress", @view.updateAppProgress

      # Watch changes in user
      @listenTo App.user, "change:credential", ()->
        self.fetchAwsResources()
        self.view.updateDemoView()

      fetchAwsResources()
      return

    fetchAwsResources : ()->

  Dashboard
