
define ["ApiRequestOs", "../CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOsImageCollection"
    ### env:dev:end ###

    type : constant.RESTYPE.OSIMAGE

    doFetch        : ()-> ApiRequest("os_image_List", {region : @region()})
    parseFetchData : (res)->
      data = res?.images || []
      for item in data
        if item.architecture and item.os_distro and item.architecture in ["i686","x86_64"] and item.os_distro in ["centos","debian","fedora","gentoo","opensuse","redhat","suse","ubuntu","windows","cirros"]
          item.os_type = item.os_distro
        else
          item.os_type = "unknown"
      data
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

    parseFetchData : (res)-> _.values(res)
  }
