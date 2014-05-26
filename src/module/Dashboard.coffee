
define ["Workspace", "module/DashboardView", "event"], ( Workspace, DashboardView, ide_event )->

  class Dashboard extends Workspace

    isFixed  : ()-> true
    tabClass : ()-> "icon-dashboard"
    title    : ()-> "Dashboard"


    initialize : ()->

      # LEGACY CODE, would remove this stupid code.
      ide_event.trigger ide_event.DASHBOARD_COMPLETE
      ide_event.trigger ide_event.IDE_AVAILABLE
      ide_event.trigger ide_event.SWITCH_MAIN

      @view = new DashboardView()

      # Watch changes in applist/stacklist
      @listenTo App.model.stackList(), "update", ()-> @view.updateOpsList()
      @listenTo App.model.appList(),   "update", ()-> @view.updateOpsList()

      @listenTo App.model.appList(), "change:state",    ( model )-> @view.updateRegionList( model )
      @listenTo App.model.appList(), "change:progress", ( model )-> @view.updateAppProgress( model )

  Dashboard
