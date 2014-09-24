

define ["ApiRequest", "CloudResources", "constant", "backbone"], ( ApiRequest, CloudResources, constant )->

  ###
    Dashboard Model
  ###
  Backbone.Model.extend {

    initialize : ()->
      @listenTo CloudResources( constant.RESTYPE.OSSERVER ), "update", @onRegionResChanged
      @listenTo CloudResources( constant.RESTYPE.OSVOL ), "update", @onRegionResChanged
      @listenTo CloudResources( constant.RESTYPE.OSSNAP ), "update", @onRegionResChanged
      @listenTo CloudResources( constant.RESTYPE.OSFIP ), "update", @onRegionResChanged
      @listenTo CloudResources( constant.RESTYPE.OSRT ), "update", @onRegionResChanged
      @listenTo CloudResources( constant.RESTYPE.OSPOOL ), "update", @onRegionResChanged
      @listenTo CloudResources( constant.RESTYPE.OSLISTENER ), "update", @onRegionResChanged

    onRegionResChanged : ()-> @trigger "change:regionResources"

    ### Cloud Resources ###
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

    isOsResReady : ( region, type )->
      switch type
        when constant.RESTYPE.OSLISTENER
          return CloudResources( type, region ).isReady() and CloudResources( constant.RESTYPE.OSPOOL, region ).isReady()
        when constant.RESTYPE.OSPOOL
          return CloudResources( type, region ).isReady() and CloudResources( constant.RESTYPE.OSLISTENER, region ).isReady()
        else
          return CloudResources( type, region ).isReady()
      return

    getOsResData : ( region, type )->
        return {
          instances : CloudResources( constant.RESTYPE.INSTANCE ).groupByCategory(undefined, filter)
          eips      : CloudResources( constant.RESTYPE.EIP ).groupByCategory()
          volumes   : CloudResources( constant.RESTYPE.VOL ).groupByCategory()
          elbs      : CloudResources( constant.RESTYPE.ELB ).groupByCategory()
          vpns      : CloudResources( constant.RESTYPE.VPN ).groupByCategory()
          rds       : DBInstances
        }

    getResourcesCount : ( region )->
      filter = { category : region }
      data = {
        servers      : "OSSERVER"
        volumes      : "OSVOL"
        snaps        : "OSSNAP"
        fips         : "OSFIP"
        rts          : "OSRT"
        elbs         : "OSLISTENER"
      }
      d = {}
      for key, type of data
        collection = CloudResources( constant.RESTYPE[type] )
        if collection.isReady()
          d[ key ] = collection.where(filter).length
        else
          d[ key ] = ""

      d
  }
