
define ["ApiRequest", "./CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  ### This Connection is used to fetch all the resource of an vpc ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOpsCollection"
    ### env:dev:end ###

    type  : "OpsResource"

    init : ( region )-> @__region = region; @

    doFetch : ()->
      console.assert( @__region, "CrOpsCollection's region is not set before fetching data. Need to call init() first" )
      ApiRequest("resource_vpc_resource", {
        region_name : @__region
        vpc_id      : @category
      })

    parseFetchData : ( data )->
      # OpsResource doesn't return anything, Instead, it injects the data to other collection.
      delete data.vpc

      extraAttr = { RES_TAG : @category }

      for type, d of data
        cln = CloudResources( type, @__region )
        if not cln
          console.warn "Cannot find cloud resource collection for type:", type
          continue
        cln.__parseExternalData d, extraAttr

      # Nasty, but it should work.
      # Describe instances belongs to ASG.
      return
  }
