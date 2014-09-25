
define ["ApiRequestOs", "../CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsNetworkCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSNETWORK

    getExtNetworks : ()-> @where {"router:external":true}

    doFetch        : ()-> ApiRequest("os_network_List", {region : @region()})
    parseFetchData : (data)->
      for network in data.networks
        data['physical_network'] = data['provider:physical_network']
        data['external'] = data['router:external']
        delete data['provider:physical_network']
        delete data['router:external']
      data.networks

    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res


  }
