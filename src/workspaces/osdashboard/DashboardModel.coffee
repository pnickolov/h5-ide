

define ["ApiRequest", "CloudResources", "constant", "backbone"], ( ApiRequest, CloudResources, constant )->

  ###
    Dashboard Model
  ###
  Backbone.Model.extend {

    initialize : ()->
      # @listenTo CloudResources( constant.RESTYPE.SUBSCRIPTION, region ), "update", @onRegionResChanged
      # @listenTo CloudResources( constant.RESTYPE.DBINSTANCE, region ),  "update", @onGlobalResChanged

    ### Cloud Resources ###
    onRegionResChanged : ()-> @trigger "change:regionResources"
    onGlobalResChanged : ()->
      @trigger "change:globalResources"
      @trigger "change:regionResources"

    fetchAwsResources : ( region )->
      if not region
        CloudResources( constant.RESTYPE.INSTANCE ).fetch()
        CloudResources( constant.RESTYPE.EIP ).fetch()
        CloudResources( constant.RESTYPE.VOL ).fetch()
        CloudResources( constant.RESTYPE.ELB ).fetch()
        CloudResources( constant.RESTYPE.VPN ).fetch()
        _.each constant.REGION_KEYS, (e)->
          CloudResources( constant.RESTYPE.DBINSTANCE, e).fetch()
        return

      CloudResources( constant.RESTYPE.SUBSCRIPTION, region ).fetch()
      CloudResources( constant.RESTYPE.VPC ).fetch()
      CloudResources( constant.RESTYPE.DHCP, region ).fetch()
      CloudResources( constant.RESTYPE.ASG ).fetch()
      CloudResources( constant.RESTYPE.CW ).fetch()
      CloudResources( constant.RESTYPE.ENI, region ).fetch()
      CloudResources( constant.RESTYPE.CGW, region ).fetch()
      CloudResources( constant.RESTYPE.VGW, region ).fetch()
      return


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

    getAwsResData : ( region, type )->
      if not region
        filter = ( m )-> if m.attributes.instanceState then m.attributes.instanceState.name is "running" else false
        DBInstancesCount = 0
        DBInstances =[]
        for e in constant.REGION_KEYS
          data =
            region: e
            data: CloudResources( constant.RESTYPE.DBINSTANCE, e ).models || []
            regionName: constant.REGION_SHORT_LABEL[ e ]
            regionArea: constant.REGION_LABEL[ e ]
          DBInstancesCount += data.data.length
          DBInstances.push data
        DBInstances.totalCount = DBInstancesCount
        return {
          instances : CloudResources( constant.RESTYPE.INSTANCE ).groupByCategory(undefined, filter)
          eips      : CloudResources( constant.RESTYPE.EIP ).groupByCategory()
          volumes   : CloudResources( constant.RESTYPE.VOL ).groupByCategory()
          elbs      : CloudResources( constant.RESTYPE.ELB ).groupByCategory()
          vpns      : CloudResources( constant.RESTYPE.VPN ).groupByCategory()
          rds       : DBInstances
        }

      if type is constant.RESTYPE.SUBSCRIPTION
        return CloudResources( type, region ).models
      else
        return CloudResources( type, region ).where({ category : region })

    getAwsResDataById : ( region, type, id )-> CloudResources( type, region ).get(id)

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
      for key, type of data
        collection = CloudResources( constant.RESTYPE[type] )
        if collection.isReady()
          d[ key ] = collection.where(filter).length
        else
          d[ key ] = ""

      rdsCollection = CloudResources(constant.RESTYPE.DBINSTANCE, region)
      if rdsCollection.isReady()
        d.rds = rdsCollection.models.length
      else
        d.rds = ""
      collection = CloudResources( constant.RESTYPE.SUBSCRIPTION, region )
      if collection.isReady()
        d.snss = collection.models.length
      else
        d.snss = ""
      d

    getResourceData : ( region, type, id )-> CloudResources( type, region ).get( id )
  }
