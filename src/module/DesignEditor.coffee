
define ["Workspace"], ( Workspace )->

  class Dashboard extends Workspace

    isFixed  : ()-> false
    tabClass : ()-> "icon-stack-tabbar"
    title    : ()-> "untitled-2 - stack"

  Dashboard
