
define ["Workspace", "module/DashboardView"], ( Workspace, DashboardView )->

  class Dashboard extends Workspace

    isFixed  : ()-> true
    tabClass : ()-> "icon-dashboard"
    title    : ()-> "Dashboard"


    initialize : ()->
      @view = new DashboardView()

      # Watch changes in applist/stacklist
      @listenTo App.model.stackList(), "update", ()-> @view.updateOpsList()
      @listenTo App.model.appList(),   "update", ()-> @view.updateOpsList()

      @listenTo App.model.appList(), "change:state",    ( model )-> @view.updateRegionList( model )
      @listenTo App.model.appList(), "change:progress", ( model )-> @view.updateAppProgress( model )

  Dashboard
