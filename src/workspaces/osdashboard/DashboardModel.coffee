

define ["ApiRequest", "CloudResources", "constant", "backbone"], ( ApiRequest, CloudResources, constant )->

  ###
    Dashboard Model
  ###
  Backbone.Model.extend {

    initialize : ()->
      region = 'guangzhou'

      @listenTo CloudResources( constant.RESTYPE.OSSERVER, region ), "update", @onRegionResChanged [ 'OSSERVER', 'FIP' ]
      @listenTo CloudResources( constant.RESTYPE.OSPORT, region ), "update", @onRegionResChanged [ 'FIP' ]
      @listenTo CloudResources( constant.RESTYPE.OSVOL, region ), "update", @onRegionResChanged [ 'OSVOL', 'OSSNAP' ]
      @listenTo CloudResources( constant.RESTYPE.OSSNAP, region ), "update", @onRegionResChanged [ 'OSSNAP' ]
      @listenTo CloudResources( constant.RESTYPE.OSFIP, region ), "update", @onRegionResChanged [ 'OSFIP' ]
      @listenTo CloudResources( constant.RESTYPE.OSRT, region ), "update", @onRegionResChanged [ 'OSRT' ]
      @listenTo CloudResources( constant.RESTYPE.OSPOOL, region ), "update", @onRegionResChanged [ 'OSPOOL', 'OSLISTENER' ]
      @listenTo CloudResources( constant.RESTYPE.OSLISTENER, region ), "update", @onRegionResChanged [ 'OSLISTENER' ]
      @listenTo CloudResources( constant.RESTYPE.OSNETWORK, region ), "update", @onRegionResChanged [ 'OSRT' ]

    onRegionResChanged : ( type )-> () -> @trigger "change:regionResources", type

    ### Cloud Resources ###
    fetchOsResources : ( region = 'guangzhou')->
      CloudResources( constant.RESTYPE.OSSERVER, region ).fetch()
      CloudResources( constant.RESTYPE.OSPORT, region ).fetch()
      CloudResources( constant.RESTYPE.OSVOL, region ).fetch()
      CloudResources( constant.RESTYPE.OSSNAP, region ).fetch()
      CloudResources( constant.RESTYPE.OSFIP, region ).fetch()
      CloudResources( constant.RESTYPE.OSRT, region ).fetch()
      CloudResources( constant.RESTYPE.OSPOOL, region ).fetch()
      CloudResources( constant.RESTYPE.OSLISTENER, region ).fetch()
      CloudResources( constant.RESTYPE.OSNETWORK, region ).fetch()
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
        data = {
          servers : CloudResources( constant.RESTYPE.OSSERVER, region )?.toJSON()
          volumes : CloudResources( constant.RESTYPE.OSVOL, region )?.toJSON()
          snaps   : CloudResources( constant.RESTYPE.OSSNAP, region )?.toJSON()
          fips    : CloudResources( constant.RESTYPE.OSFIP, region )?.toJSON()
          rts     : CloudResources( constant.RESTYPE.OSRT, region )?.toJSON()
          elbs    : CloudResources( constant.RESTYPE.OSLISTENER, region )?.toJSON()
        }

        # Join fip, port, server
        _.each data.fips, ( fip ) ->
          portId = fip.port_id
          port = CloudResources( constant.RESTYPE.OSPORT, region )?.get( portId )?.toJSON()
          if port
            server = CloudResources( constant.RESTYPE.OSSERVER, region )?.get( port.device_id )?.toJSON()

          fip.serverName = server?.name
          fip.portName = port?.name

        # Join snapshot, volume
        _.each data.snaps, ( snap ) ->
          volume = CloudResources( constant.RESTYPE.OSVOL, region )?.get( snap.volume_id )?.toJSON()
          snap.volumeName = volume?.name


        # Join listener, pool
        _.each data.elbs, ( listener ) ->
          pool = CloudResources( constant.RESTYPE.OSPOOL, region )?.get( listener.pool_id )?.toJSON()
          listener.poolName = pool?.name

        # Join router, extnetwork
        extNetworks = _.map CloudResources( constant.RESTYPE.OSNETWORK, region ).getExtNetworks(), (m) -> m.toJSON()
        _.each data.rts, ( rt ) ->
          extNetwork = _.findWhere extNetworks, { id: rt.external_gateway_info?.network_id }
          rt.externalNetworkName = extNetwork?.name


        data


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
