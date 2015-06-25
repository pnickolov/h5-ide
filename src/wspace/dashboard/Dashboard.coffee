
define [ "Workspace", "./DashboardView", 'i18n!/nls/lang.js', "CloudResources", "constant", "ApiRequest", "Credential", "component/userguide/userguide" ], ( Workspace, DashboardView, lang, CloudResources, constant, ApiRequest, Credential, UserGuide )->

  Workspace.extend {

    type : "Dashboard"

    isFixed  : ()-> true
    tabClass : ()-> "icon-dashboard"
    title    : ()-> lang.IDE.NAV_TIT_DASHBOARD
    url      : ()-> "/"

    initialize : ()->
      @view = new DashboardView({model:@})
      @listenTo @scene.project, "change:myRole", ()-> @view.render()
      @userGuide = new UserGuide()
      @userGuide.render()
      return

    isReadOnly : ()-> @scene.project.amIObserver()
    isWorkingOn : ( attr )-> attr.type is "Dashboard"

    fetchAwsResources : ( region )->
      credentialId = @scene.project.credIdOfProvider( Credential.PROVIDER.AWSGLOBAL )
      self = @
      if not region
        CloudResources(credentialId, constant.RESTYPE.INSTANCE ).fetch()
        CloudResources(credentialId, constant.RESTYPE.EIP ).fetch()
        CloudResources(credentialId, constant.RESTYPE.VOL ).fetch()
        CloudResources(credentialId, constant.RESTYPE.ELB ).fetch()
        CloudResources(credentialId, constant.RESTYPE.VPN ).fetch()
        _.each constant.REGION_KEYS, (e)->
          CloudResources(credentialId, constant.RESTYPE.DBINSTANCE, e).fetch()
        return

      CloudResources(credentialId, constant.RESTYPE.SUBSCRIPTION, region ).fetch()
      CloudResources(credentialId, constant.RESTYPE.VPC ).fetch()
      CloudResources(credentialId, constant.RESTYPE.DHCP, region ).fetch()
      CloudResources(credentialId, constant.RESTYPE.ASG ).fetch()
      CloudResources(credentialId, constant.RESTYPE.CW ).fetch()
      CloudResources(credentialId, constant.RESTYPE.ENI, region ).fetch()
      CloudResources(credentialId, constant.RESTYPE.CGW, region ).fetch()
      CloudResources(credentialId, constant.RESTYPE.VGW, region ).fetch()
      return


    isAwsResReady : ( region, type )->
      credentialId = @scene.project.credIdOfProvider( Credential.PROVIDER.AWSGLOBAL )
      if not region
        globalReady = true
        datasource = [
          CloudResources(credentialId, constant.RESTYPE.INSTANCE )
          CloudResources(credentialId, constant.RESTYPE.EIP )
          CloudResources(credentialId, constant.RESTYPE.VOL )
          CloudResources(credentialId, constant.RESTYPE.ELB )
          CloudResources(credentialId, constant.RESTYPE.VPN )
        ]
        for e in constant.REGION_KEYS
          globalReady = false unless CloudResources(credentialId, constant.RESTYPE.DBINSTANCE, e).isReady()

        for i in datasource
          globalReady = false unless i.isReady()
        return globalReady

      switch type
        when constant.RESTYPE.SUBSCRIPTION
          return CloudResources(credentialId, type, region ).isReady()
        when constant.RESTYPE.VPC
          return CloudResources(credentialId, type ).isReady() && CloudResources(credentialId, constant.RESTYPE.DHCP, region ).isReady()
        when constant.RESTYPE.INSTANCE
          return CloudResources(credentialId, type ).isReady() && CloudResources(credentialId, constant.RESTYPE.EIP, region ).isReady()
        when constant.RESTYPE.VPN
          return CloudResources(credentialId, type ).isReady() && CloudResources(credentialId, constant.RESTYPE.VGW , region ).isReady() && CloudResources(credentialId, constant.RESTYPE.CGW , region).isReady()
        when constant.RESTYPE.DBINSTANCE
          return CloudResources(credentialId, type, region ).isReady()
        else
          return CloudResources(credentialId, type ).isReady()
      return

    getAwsResData : ( region, type )->
      credentialId = @scene.project.credIdOfProvider( Credential.PROVIDER.AWSGLOBAL )
      if not region
        filter = ( m )-> if m.attributes.instanceState then m.attributes.instanceState.name is "running" else false
        DBInstancesCount = 0
        DBInstances =[]
        for e in constant.REGION_KEYS
          data =
            region: e
            data: CloudResources(credentialId, constant.RESTYPE.DBINSTANCE, e ).models || []
            regionName: constant.REGION_SHORT_LABEL[ e ]
            regionArea: constant.REGION_LABEL[ e ]
          DBInstancesCount += data.data.length
          DBInstances.push data
        DBInstances.totalCount = DBInstancesCount
        return {
        instances : CloudResources(credentialId, constant.RESTYPE.INSTANCE ).groupByCategory(undefined, filter)
        eips      : CloudResources(credentialId, constant.RESTYPE.EIP ).groupByCategory()
        volumes   : CloudResources(credentialId, constant.RESTYPE.VOL ).groupByCategory()
        elbs      : CloudResources(credentialId, constant.RESTYPE.ELB ).groupByCategory()
        vpns      : CloudResources(credentialId, constant.RESTYPE.VPN ).groupByCategory()
        rds       : DBInstances
        }

      if type is constant.RESTYPE.SUBSCRIPTION
        return CloudResources(credentialId, type, region ).models
      else
        return CloudResources(credentialId, type, region ).where({ category : region })

    getAwsResDataById : ( region, type, id )->
      CloudResources(@scene.project.credIdOfProvider( Credential.PROVIDER.AWSGLOBAL ), type, region ).get(id)

    getResourceData : ( region, type, id )-> CloudResources( @scene.project.credIdOfProvider( Credential.PROVIDER.AWSGLOBAL ), type, region ).get( id )

    clearVisualizeData : ()->
      @set "visualizeData", []
      @__visRequest = null
      return

    getResourcesCount : ( region )->
      filter = { category : region }
      data = {
        instances    : "INSTANCE"
        eips         : "EIP"
        volumes      : "VOL"
        elbs         : "ELB"
        vpns         : "VPN"
        vpcs         : "VPC"
        asgs         : "ASG"
        cloudwatches : "CW"
      }
      d = {}

      credentialId = @scene.project.credIdOfProvider( Credential.PROVIDER.AWSGLOBAL )
      for key, type of data
        collection = CloudResources(credentialId, constant.RESTYPE[type] )
        if collection.isReady()
          d[ key ] = collection.where(filter).length
        else
          d[ key ] = ""

      rdsCollection = CloudResources(credentialId, constant.RESTYPE.DBINSTANCE, region)
      if rdsCollection.isReady()
        d.rds = rdsCollection.models.length
      else
        d.rds = ""
      collection = CloudResources(credentialId, constant.RESTYPE.SUBSCRIPTION, region )
      if collection.isReady()
        d.snss = collection.models.length
      else
        d.snss = ""
      d

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
