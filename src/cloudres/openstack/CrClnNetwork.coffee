
define ["ApiRequestOs", "../CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsNetworkCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSNETWORK

    getExtNetworks : ()-> @where {"router:external":true}

    doFetch        : ()-> ApiRequest("os_network_List", {region : @region()})
    parseFetchData : (data)-> data.networks
    parseExternalData : ( data )->
      res = $.extend(true, [], data)
      @camelToUnderscore res
      res


  }
