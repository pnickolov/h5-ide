
define ["ApiRequestOs", "../CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsExtNetworkCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSEXTNET

    doFetch        : ()-> ApiRequest("os_network_List", {region : @region()})
    parseFetchData : (res)->
      exts = []
      for nw in res.networks
        if nw["router:external"] is true
          exts.push nw

      exts
  }
