

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
    fetchOsResources : ( region )->
      CloudResources( constant.RESTYPE.OSSERVER, region ).fetch()
      CloudResources( constant.RESTYPE.OSVOL, region ).fetch()
      CloudResources( constant.RESTYPE.OSSNAP, region ).fetch()
      CloudResources( constant.RESTYPE.OSFIP, region ).fetch()
      CloudResources( constant.RESTYPE.OSRT, region ).fetch()
      CloudResources( constant.RESTYPE.OSPOOL, region ).fetch()
      CloudResources( constant.RESTYPE.OSLISTENER, region ).fetch()
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
