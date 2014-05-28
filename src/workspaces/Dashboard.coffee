
define ["Workspace", "workspaces/DashboardView", "workspaces/DashboardModel"], ( Workspace, DashboardView, DashboardModel )->

  class Dashboard extends Workspace

    isFixed  : ()-> true
    tabClass : ()-> "icon-dashboard"
    title    : ()-> "Dashboard"


    initialize : ()->
      @model = new DashboardModel()
      @view  = new DashboardView({model:@model})

      # Watch changes in applist/stacklist
      @listenTo App.model.stackList(), "update", ()-> @view.updateOpsList()
      @listenTo App.model.appList(),   "update", ()-> @view.updateOpsList()

      @listenTo App.model.appList(), "change:state",    ( model )-> @view.updateRegionList( model )
      @listenTo App.model.appList(), "change:progress", ( model )-> @view.updateAppProgress( model )

  Dashboard
