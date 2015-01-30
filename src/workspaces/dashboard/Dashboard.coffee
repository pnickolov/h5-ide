
define [ "Workspace", "./DashboardView", 'i18n!/nls/lang.js' ], ( Workspace, DashboardView, lang )->

  Workspace.extend {

    type : "Dashboard"

    isFixed  : ()-> true
    tabClass : ()-> "icon-dashboard"
    title    : ()-> lang.IDE.NAV_TIT_DASHBOARD
    url      : ()-> "/"

    initialize : ()->
      @view = new DashboardView({model:@})
      return

    isReadOnly : ()-> @scene.project.amIObserver()

    isWorkingOn : ( attr )-> attr.type is "Dashboard"

    supportedProviders : ()->
      [{
        id : "aws::global"
        regions : [
          {
            id    : "us-east-1"
            name  : lang.IDE[ 'IDE_LBL_REGION_NAME_us-east-1']
            alias : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_us-east-1']
          }
          {
            id    : "us-west-1"
            name  : lang.IDE[ 'IDE_LBL_REGION_NAME_us-west-1']
            alias : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_us-west-1']
          }
          {
            id    : "us-west-2"
            name  : lang.IDE[ 'IDE_LBL_REGION_NAME_us-west-2']
            alias : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_us-west-2']
          }
          {
            id    : "eu-west-1"
            name  : lang.IDE[ 'IDE_LBL_REGION_NAME_eu-west-1']
            alias : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_eu-west-1']
          }
          {
            id    : 'eu-central-1'
            name  : lang.IDE[ 'IDE_LBL_REGION_NAME_eu-central-1']
            alias : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_eu-central-1']
          }
          {
            id    : 'ap-southeast-2'
            name  : lang.IDE[ 'IDE_LBL_REGION_NAME_ap-southeast-2']
            alias : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_ap-southeast-2']
          }
          {
            id    : 'ap-northeast-1'
            name  : lang.IDE[ 'IDE_LBL_REGION_NAME_ap-northeast-1']
            alias : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_ap-northeast-1']
          }
          {
            id    : 'ap-southeast-1'
            name  : lang.IDE[ 'IDE_LBL_REGION_NAME_ap-southeast-1']
            alias : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_ap-southeast-1']
          }
          {
            id    : 'sa-east-1'
            name  : lang.IDE[ 'IDE_LBL_REGION_NAME_sa-east-1']
            alias : lang.IDE[ 'IDE_LBL_REGION_NAME_SHORT_sa-east-1']
          }
        ]
      }]

  }, {

    canHandle : ( attr )-> attr.type is "Dashboard"

  }
