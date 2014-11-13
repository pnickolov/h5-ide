

define ["ApiRequest", "CloudResources", "constant", "backbone"], ( ApiRequest, CloudResources, constant )->

  ###
    Dashboard Model
  ###
  Backbone.Model.extend {

    defaults :
      region   : ""
      provider : ""

    initialize : ()->

      r = @region = App.user.get("default_region")
      @provider = App.user.get("default_provider")

      R = constant.RESTYPE
      r = @region

      @listenTo CloudResources( R.OSSERVER,   r ), "update", @onRegionResChanged [ 'OSSERVER', 'FIP' ]
      @listenTo CloudResources( R.OSPORT,     r ), "update", @onRegionResChanged [ 'FIP' ]
      @listenTo CloudResources( R.OSVOL,      r ), "update", @onRegionResChanged [ 'OSVOL', 'OSSNAP' ]
      @listenTo CloudResources( R.OSSNAP,     r ), "update", @onRegionResChanged [ 'OSSNAP' ]
      @listenTo CloudResources( R.OSFIP,      r ), "update", @onRegionResChanged [ 'OSFIP' ]
      @listenTo CloudResources( R.OSRT,       r ), "update", @onRegionResChanged [ 'OSRT' ]
      @listenTo CloudResources( R.OSPOOL,     r ), "update", @onRegionResChanged [ 'OSPOOL', 'OSLISTENER' ]
      @listenTo CloudResources( R.OSLISTENER, r ), "update", @onRegionResChanged [ 'OSLISTENER' ]
      @listenTo CloudResources( R.OSNETWORK,  r ), "update", @onRegionResChanged [ 'OSRT' ]

    onRegionResChanged : ( type )-> () -> @trigger "change:regionResources", type

    ### Cloud Resources ###
    fetchOsResources : ()->
      CloudResources( constant.RESTYPE.OSSERVER,   @region ).fetch()
      CloudResources( constant.RESTYPE.OSPORT,     @region ).fetch()
      CloudResources( constant.RESTYPE.OSVOL,      @region ).fetch()
      CloudResources( constant.RESTYPE.OSSNAP,     @region ).fetch()
      CloudResources( constant.RESTYPE.OSFIP,      @region ).fetch()
      CloudResources( constant.RESTYPE.OSRT,       @region ).fetch()
      CloudResources( constant.RESTYPE.OSPOOL,     @region ).fetch()
      CloudResources( constant.RESTYPE.OSLISTENER, @region ).fetch()
      CloudResources( constant.RESTYPE.OSNETWORK,  @region ).fetch()
      return

    isOsResReady : ( type )->
      res = CloudResources( type, @region ).isReady()

      switch type
        when constant.RESTYPE.OSLISTENER
          res = res and CloudResources( constant.RESTYPE.OSPOOL, @region ).isReady()
        when constant.RESTYPE.OSPOOL
          res = res and CloudResources( constant.RESTYPE.OSLISTENER, @region ).isReady()

      res

    getOsResData : ( type )->
      region = @region
      availableImageDistro = ["centos","debian","fedora","gentoo","opensuse","redhat","suse","ubuntu","windows","cirros"]
      data = {
        servers : _.map CloudResources( constant.RESTYPE.OSSERVER, region ).toJSON(), (e)->
          if e.system_metadata.image_os_distro not in availableImageDistro
            e.system_metadata.image_os_distro = "unknown"
          e
        volumes : CloudResources( constant.RESTYPE.OSVOL,      region ).toJSON()
        snaps   : CloudResources( constant.RESTYPE.OSSNAP,     region ).toJSON()
        fips    : CloudResources( constant.RESTYPE.OSFIP,      region ).toJSON()
        rts     : CloudResources( constant.RESTYPE.OSRT,       region ).toJSON()
        elbs    : CloudResources( constant.RESTYPE.OSLISTENER, region ).toJSON()
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
        name = ""
        if rt.external_gateway_info
          extNetwork = _.findWhere extNetworks, { id: rt.external_gateway_info.network_id }
          if extNetwork then name = extNetwork.name

        rt.externalNetworkName = name

      data


    getOsResDataById : ( type, id )-> CloudResources( type, @region ).get(id)

    getResourcesCount : ()->
      filter = { category : @region }
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
        collection = CloudResources( constant.RESTYPE[type], @region )
        if collection.isReady()
          d[ key ] = collection.where(filter).length
        else
          d[ key ] = ""

      d

    importApp : ()->
      self = @
      ApiRequest("resource_region_resource").then ( data )->
        d = []
        emptyArr = []

        for key, value of data.openstack[ self.provider ] || {}
          region =
            name   : constant.REGION_LABEL[ key ]
            region : key
            apps   : []

          for networkId, data of value
            region.apps.push {
              id       : networkId
              subnet   : ( data[ constant.RESTYPE.OSSUBNET ]   || emptyArr ).length
              router   : ( data[ constant.RESTYPE.OSRT ]       || emptyArr ).length
              server   : ( data[ constant.RESTYPE.OSSERVER ]   || emptyArr ).length
              fip      : ( data[ constant.RESTYPE.OSFIP ]      || emptyArr ).length
              listener : ( data[ constant.RESTYPE.OSLISTENER ] || emptyArr ).length
              pool     : ( data[ constant.RESTYPE.OSPOOL ]     || emptyArr ).length
            }
          if region.apps.length
            d.push region

        d
  }
