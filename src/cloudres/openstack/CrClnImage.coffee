
define ["ApiRequest", "../CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  ### This Collection is used to fetch generic ami ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsImageCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSIMAGE

    doFetch        : ()-> ApiRequest("os_image_List", {region_name : @region()})
    parseFetchData : (res)-> res.images
  }
