
define ["ApiRequest", "./CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  ### This Connection is used to fetch all the resource of an vpc ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOpsCollection"
    ### env:dev:end ###

    type  : "OpsResource"

    init : ( region, provider )->
      @__region   = region
      @__provider = provider
      @

    # Fetches
    fetchForceDedup : ()->
      @__forceDedup = false
      p = @fetchForce()
      @__forceDedup = true
      p

    fetchForce : ()->
      if @__forceDedup
        @__forceDedup = false
        d = Q.defer()
        d.resolve()
        return d.promise

      @generatedJson = null
      CrCollection.prototype.fetchForce.call this

    doFetch : ()->
      # Before we do the fetch, we would want to clear everything in the CloudResources cache.
      self = @
      CloudResources.clearWhere ((m)-> m.RES_TAG is self.category), @__region

      ### env:dev ###
      #use cache data for develop
      app_json = App.workspaces.getAwakeSpace().opsModel.getJsonData()
      if app_json
        data = dd.getDataFromLocal app_json.id
      if data
        @parseFetchData( data )
        return
      ### env:dev:end ###

      console.assert( @__region && @__provider, "CrOpsCollection's region is not set before fetching data. Need to call init() first" )
      ApiRequest("resource_get_resource", {
        region_name : @__region
        provider    : @__provider
        res_id      : @category
      })


    parseFetchData : ( data )->
      ### env:dev ###
      #store resource data for develop
    #   data.app_json = App.workspaces.getAwakeSpace().opsModel.getJsonData()
    #   dd.setDataToLocal data
      ### env:dev:end ###

      app_json = data.app_json
      delete data.app_json

      # 1. Parse aws resource data with other collection
      extraAttr = { RES_TAG : @category }
      for type, d of data
        cln = CloudResources( type, @__region )
        if not cln
          console.warn "Cannot find cloud resource collection for type:", type
          continue
        cln.__parseExternalData d, extraAttr, @__region, data

      # 2. Fix buggy generated json.
      @generatedJson = @fixGeneratedJson( app_json )
      return

    fixGeneratedJson : ( json )-> json

  }
