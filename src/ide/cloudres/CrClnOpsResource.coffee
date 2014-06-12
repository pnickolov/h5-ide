
define ["ApiRequest", "./CrCollection", "constant"], ( ApiRequest, CrCollection, constant )->

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
      debugger

    __parseAndCache : ( region, data )->
      # Parse and cached additional datas.
      for d in data[ region ]
        d = $.xml2json( $.parseXML(d) )
        for resType of d
          if d.hasOwnProperty( resType )
            Collection = CrCollection.getClassByAwsResponseType( resType )
            if Collection then break

        col = CloudResources( Collection.type, region )
        col.parseExternalData( d )
      return
  }
