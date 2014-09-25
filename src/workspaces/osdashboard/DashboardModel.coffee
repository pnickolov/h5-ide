

define ["ApiRequest", "CloudResources", "constant", "backbone"], ( ApiRequest, CloudResources, constant )->

  ###
    Dashboard Model
  ###
  Backbone.Model.extend {

    initialize : ()->
      region = 'guangzhou'
      @listenTo CloudResources( constant.RESTYPE.OSSERVER, region ), "update", @onRegionResChanged 'OSSERVER'
      @listenTo CloudResources( constant.RESTYPE.OSVOL, region ), "update", @onRegionResChanged 'OSVOL'
      @listenTo CloudResources( constant.RESTYPE.OSSNAP, region ), "update", @onRegionResChanged 'OSSNAP'
      @listenTo CloudResources( constant.RESTYPE.OSFIP, region ), "update", @onRegionResChanged 'OSFIP'
      @listenTo CloudResources( constant.RESTYPE.OSRT, region ), "update", @onRegionResChanged 'OSRT'
      @listenTo CloudResources( constant.RESTYPE.OSPOOL, region ), "update", @onRegionResChanged 'OSPOOL'
      @listenTo CloudResources( constant.RESTYPE.OSLISTENER, region ), "update", @onRegionResChanged 'OSLISTENER'

    onRegionResChanged : ( type )-> () -> @trigger "change:regionResources", type

    ### Cloud Resources ###
    fetchOsResources : ( region = 'guangzhou')->
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
          servers : CloudResources( constant.RESTYPE.OSSERVER, region )?.toJSON()
          volumes : CloudResources( constant.RESTYPE.OSVOL, region )?.toJSON()
          snaps   : CloudResources( constant.RESTYPE.OSSNAP, region )?.toJSON()
          fips    : CloudResources( constant.RESTYPE.OSFIP, region )?.toJSON()
          rts     : CloudResources( constant.RESTYPE.OSRT, region )?.toJSON()
          elbs    : CloudResources( constant.RESTYPE.OSLISTENER, region )?.toJSON()
        }

    getOsResDataById : ( region, type, id )-> CloudResources( type, region ).get(id)

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
        collection = CloudResources( constant.RESTYPE[type], region )
        if collection.isReady()
          d[ key ] = collection.where(filter).length
        else
          d[ key ] = ""

      d
  }
