
define [
  "../CrCommonCollection"
  "../CrCollection"
  "../CrModel"
  "ApiRequestOs"
  "constant"
  "CloudResources"
], ( CrCommonCollection, CrCollection, CrModel, ApiRequest, constant, CloudResources )->


  ### Network ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsNetworkCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSNETWORK
    doFetch : ()-> ApiRequest("os_network_List", {region : @region()})
    parseFetchData : ( data )->
      for vpc in data
        null
      data
    parseExternalData: ( data ) ->
      for vpc in data
        null
      data
  }


  ### Subnet ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsSubnetCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSSUBNET
    doFetch : ()-> ApiRequest("os_subnet_List", {region : @region()})
    parseFetchData : ( data )->
      for subnet in data
        null
      data
    parseExternalData: ( data ) ->
      for subnet in data
        null
      data

  }


  ### SG ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsSgCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSSG
    doFetch : ()-> ApiRequest("os_securitygroup_List", {region : @region()})
    parseFetchData : ( data )->
      for sg in data
        null
      data
    parseExternalData: ( data ) ->
      for sg in data
        null
      data

  }


  ### Port ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsPortCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSPORT
    doFetch : ()-> ApiRequest("os_port_List", {region : @region()})
    parseFetchData : ( data )->
      for port in data
        null
      data
    parseExternalData: ( data ) ->
      for port in data
        null
      data
  }


  ### FIP ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsFipCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSFIP
    doFetch : ()-> ApiRequest("os_ip_ListFloatingIP", {region : @region()})
    parseFetchData : ( data )->
      for fip in data
        null
      data
    parseExternalData: ( data ) ->
      for fip in data
        null
      data

  }


  ### Pool ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsPoolCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSPOOL
    doFetch : ()-> ApiRequest("os_pool_List", {region : @region()})
    parseFetchData : ( data )->
      for pool in data
        null
      data
    parseExternalData: ( data ) ->
      for pool in data
        null
      data
  }


  ### Listener(VIP) ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsListenerCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSLISTENER
    doFetch : ()-> ApiRequest("os_listener_List", {region : @region()})
    parseFetchData : ( data )->
      for vip in data
        null
      data
    parseExternalData: ( data ) ->
      for vip in data
        null
      data
  }


  ### HealthMonitor ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsHealthMonitorCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSHM
    doFetch : ()-> ApiRequest("os_healthmonitor_List", {region : @region()})
    parseFetchData : ( data )->
      for hm in data
        null
      data
    parseExternalData: ( data ) ->
      for hm in data
        null
      data
  }


  ### Router ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsRouterCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSRT
    doFetch : ()-> ApiRequest("os_router_List", {region : @region()})
    parseFetchData : ( data )->
      for rt in data
        null
      data
    parseExternalData: ( data ) ->
      for rt in data
        null
      data
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
    doFetch : ()-> ApiRequest("os_server_List", {region : @region()})
    parseFetchData : ( data, region )->
      for server in data
        null
      data

    parseExternalData: ( data, region ) ->
      for server in data
        null
      data
  }


  ### Volume ###
  CrCommonCollection.extend {
    ### env:dev ###
    ClassName : "CrOsVolumeCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSVOL
    doFetch : ()-> ApiRequest("os_volume_List", {region : @region()})
    parseFetchData : ( data )->
      for vol in data
        null
      data
    parseExternalData: ( data ) ->
      for vol in data
        null
      data
  }

