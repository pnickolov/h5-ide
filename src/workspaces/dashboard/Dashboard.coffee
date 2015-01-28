
define [ "Workspace", "./DashboardView", 'i18n!/nls/lang.js', "CloudResources", "constant" ], ( Workspace, DashboardView, lang, CloudResources, constant )->

  Workspace.extend {

    type : "WS_Dashboard"

    isFixed  : ()-> true
    tabClass : ()-> "icon-dashboard"
    title    : ()-> lang.IDE.NAV_TIT_DASHBOARD
    url      : ()-> "/"

    initialize : ()->
      @view = new DashboardView({model:@})
      return

    isReadOnly : ()-> false

    isWorkingOn : ( attr )-> attr.type is "Dashboard"

    isAwsResReady : ( region, type )->
      if not region
        globalReady = true
        datasource = [
          CloudResources( constant.RESTYPE.INSTANCE )
          CloudResources( constant.RESTYPE.EIP )
          CloudResources( constant.RESTYPE.VOL )
          CloudResources( constant.RESTYPE.ELB )
          CloudResources( constant.RESTYPE.VPN )
        ]
        for e in constant.REGION_KEYS
          globalReady = false unless CloudResources( constant.RESTYPE.DBINSTANCE, e).isReady()

        for i in datasource
          globalReady = false unless i.isReady()
        return globalReady

      switch type
        when constant.RESTYPE.SUBSCRIPTION
          return CloudResources( type, region ).isReady()
        when constant.RESTYPE.VPC
          return CloudResources( type ).isReady() && CloudResources( constant.RESTYPE.DHCP, region ).isReady()
        when constant.RESTYPE.INSTANCE
          return CloudResources( type ).isReady() && CloudResources( constant.RESTYPE.EIP, region ).isReady()
        when constant.RESTYPE.VPN
          return CloudResources( type ).isReady() && CloudResources( constant.RESTYPE.VGW , region ).isReady() && CloudResources( constant.RESTYPE.CGW , region).isReady()
        when constant.RESTYPE.DBINSTANCE
          return CloudResources( type, region ).isReady()
        else
          return CloudResources( type ).isReady()
      return

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
