
define ["ApiRequestOs", "../CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsImageCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSIMAGE

    doFetch        : ()-> ApiRequest("os_image_List", {region : @region()})
    parseFetchData : (res)-> res.images
  }


  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsFlavorCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSFLAVOR

    doFetch : ()->
      region = @region()
      ApiRequest("os_flavor_List", {region : region}).then (res)->
        ApiRequest("os_flavor_Info", {
          region : region
          ids    : _.pluck( res.flavors, "id" )
        })

    parseFetchData : (res)-> res.flavor
  }
