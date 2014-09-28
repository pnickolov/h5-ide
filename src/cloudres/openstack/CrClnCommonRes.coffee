
define [
  "../CrCollection"
  "../CrModel"
  "ApiRequestOs"
  "constant"
  "CloudResources"
], ( CrCollection, CrModel, ApiRequest, constant, CloudResources )->

  ### FIP ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsFipCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSFIP

    doFetch : ()-> ApiRequest("os_floatingip_List", {region:@region()})

    parseFetchData    : ( data )-> data.floatingips
    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res

  }


  ### Pool ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsPoolCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSPOOL

    doFetch : ()-> ApiRequest("os_pool_List", {region:@region()})

    parseFetchData    : ( data )-> data.pools
    parseExternalData : ( data, category, dataCollection )->
      members = {}
      for m in dataCollection["OS::Neutron::Member"] || []
        members[ m.id ] = m

      res = $.extend(true, [], data)
      for r in res
        newmembers = []
        for m in r.members || []
          m = members[m]
          if m then newmembers.push m

        r.members = newmembers

      @camelToUnderscore res

  }


  ### Listener(VIP) ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsListenerCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSLISTENER

    doFetch : ()-> ApiRequest("os_vip_List", {region:@region()})

    parseFetchData    : ( data )-> data.vips
    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res

  }


  ### HealthMonitor ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsHealthMonitorCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSHM

    doFetch : ()-> ApiRequest("os_healthmonitor_List", {region:@region()})

    parseFetchData    : ( data )-> data.health_monitors
    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res

  }


  ### Router ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsRouterCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSRT

    doFetch : ()-> ApiRequest("os_router_List", {region:@region()})

    parseFetchData    : ( data )-> data.routers
    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res

  }


  ### Server ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsServerCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSSERVER

    doFetch : ()->
      region = @region()
      ApiRequest("os_server_List", {region : region}).then (res)->
        ApiRequest("os_server_Info", {
          region : region
          ids    : _.pluck( res.servers, "id" )
        })

    parseFetchData    : ( data )->
      data = _.values(data)
      for server in data
        server['diskConfig'] = server['OS-DCF:diskConfig']
        server['availability_zone'] = server['OS-EXT-AZ:availability_zone']
        server['power_state'] = server['OS-EXT-STS:power_state']
        server['task_state'] = server['OS-EXT-STS:task_state']
        server['vm_state'] = server['OS-EXT-STS:vm_state']
        server['launched_at'] = server['OS-SRV-USG:launched_at']
        server['terminated_at'] = server['OS-SRV-USG:terminated_at']
        server['volumes_attached'] = server['os-extended-volumes:volumes_attached']
        delete server['OS-DCF:diskConfig']
        delete server['OS-EXT-AZ:availability_zone']
        delete server['OS-EXT-STS:power_state']
        delete server['OS-EXT-STS:task_state']
        delete server['OS-EXT-STS:vm_state']
        delete server['OS-SRV-USG:launched_at']
        delete server['OS-SRV-USG:terminated_at']
        delete server['os-extended-volumes:volumes_attached']
      data

    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res

  }


  ### Volume ###
  CrCollection.extend {
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

    parseFetchData    : ( data )-> _.values(data)
    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res

  }


  ### Subnet ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsSubnetCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSSUBNET

    doFetch : ()-> ApiRequest("os_subnet_List", {region : @region()})

    parseFetchData    : ( data )-> data.subnets
    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res

  }


  ### SG ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsSgCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSSG

    doFetch : ()-> ApiRequest("os_securitygroup_List", {region : @region()})

    parseFetchData    : ( data )-> data.security_groups
    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res

  }


  ### Port ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsPortCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSPORT

    doFetch : ()-> ApiRequest("os_port_List", {region : @region()})

    parseFetchData    : ( data )->
      for port in data.ports
        port['vif_details'] = port['binding:vif_details']
        port['vif_type']    = port['binding:vif_type']
        port['profile']     = port['binding:profile']
        port['vnic_type']   = port['binding:vnic_type']
        port['host_id']     = port['binding:host_id']
        delete port['binding:vif_details']
        delete port['binding:vif_type']
        delete port['binding:profile']
        delete port['binding:vnic_type']
        delete port['binding:host_id']
      data.ports

    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res

  }



  ### Neutron Quota ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrNeutronQuotaCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSNQ

    doFetch : ()-> ApiRequest("os_neutron_quota_List", {region : @region()})

    parseFetchData    : ( data )->
      if data?.quota
        data.quota.id = "neutron_quota"
      [data?.quota]

  }


  ### Cinder Quota ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrCinderQuotaCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.OSCQ

    doFetch : ()-> ApiRequest("os_cinder_quota_List", {region : @region()})

    parseFetchData    : ( data )->
      if data?.quota_set
        data.quota_set.id = "cinder_quota"
      [data?.quota_set]

  }
