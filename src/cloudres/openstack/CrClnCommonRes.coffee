
define [
  "./CrCommonCollection"
  "../CrCollection"
  "../CrModel"
  "ApiRequestOs"
  "constant"
  "CloudResources"
], ( CrCommonCollection, CrCollection, CrModel, ApiRequest, constant, CloudResources )->

  ### FIP ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsFipCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSFIP

    parseFetchData : ( data )->
      data?.floatingips or []
    parseExternalData: ( data ) ->
      data?.floatingips or []

  }


  ### Pool ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsPoolCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSPOOL

    parseFetchData : ( data )->
      data?.pools or []
    parseExternalData: ( data ) ->
      data?.pools or []
  }


  ### Listener(VIP) ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsListenerCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSLISTENER

    parseFetchData : ( data )->
      data?.vips or []
    parseExternalData: ( data ) ->
      data?.vips or []
  }


  ### HealthMonitor ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsHealthMonitorCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSHM

    parseFetchData : ( data )->
      data?.health_monitors or []
    parseExternalData: ( data ) ->
      data?.health_monitors or []
  }


  ### Router ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsRouterCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSRT

    parseFetchData : ( data )->
      data?.routers or []
    parseExternalData: ( data ) ->
      data?.routers or []
  }


  ### Server ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsServerCollection"
    ### env:dev:end ###

    # initialize : ()->
    #   @listenTo @, "add", ( m )-> CloudResources( constant.RESTYPE.AMI, m.attributes.category ).fetchAmi( m.attributes.imageId )
    #   return

    type  : constant.RESTYPE.OSSERVER

    doFetch : ()->
      region = @region()
      ApiRequest("os_server_List", {region : region}).then (res)->
        ApiRequest("os_server_Info", {
          region : region
          ids    : _.pluck( res.servers, "id" )
        })

    parseFetchData : ( data )->
      data = _.values(data)

    parseExternalData: ( data ) ->
      data?.server or []
  }


  ### Volume ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsVolumeCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSVOL

    doFetch : ()->
      region = @region()
      ApiRequest("os_volume_List", {region : region}).then (res)->
        ApiRequest("os_volume_Info", {
          region : region
          ids    : _.pluck( res.volumes, "id" )
        })

    parseFetchData : ( data )->
      data = _.values(data)

    parseExternalData: ( data ) ->
      data?.volume or []
  }


  ## The following resource data need fetch from ide ########################################################

  ### Subnet ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsSubnetCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSSUBNET

    doFetch : ()-> ApiRequest("os_subnet_List", {region : @region()})
    parseFetchData : ( data )->
      data?.subnets or []

    parseExternalData: ( data ) ->
      data?.subnets or []

  }


  ### SG ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsSgCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSSG

    doFetch : ()-> ApiRequest("os_securitygroup_List", {region : @region()})
    parseFetchData : ( data )->
      data?.security_groups or []

    parseExternalData: ( data ) ->
      data?.security_groups or []

  }


  ### Port ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsPortCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSPORT

    doFetch : ()-> ApiRequest("os_port_List", {region : @region()})
    parseFetchData : ( data )->
      data?.ports or []
    parseExternalData: ( data ) ->
      data?.ports or []
  }
