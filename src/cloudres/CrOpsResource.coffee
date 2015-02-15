
define ["./CrCollection", "constant", "CloudResources", "ApiRequest"], ( CrCollection, constant, CloudResources, ApiRequest )->

  ### This Connection is used to fetch all the resource of an vpc ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOpsCollection"
    ### env:dev:end ###

    type  : "OpsResource"

    ###
    {
      region   : ""
      project  : null
    }
    ###
    init : ( attr )->
      @__region    = attr.region
      @__projectId = attr.project
      @__provider  = attr.provider
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
      CloudResources.clearWhere @credential(), @__region, ((m)-> m.RES_TAG is self.category)

      console.assert( @__region && @__projectId && @__provider, "CrOpsCollection's region is not set before fetching data. Need to call init() first" )

      ApiRequest("resource_get_resource", {
        region_name : @__region
        provider    : @__provider
        project_id  : @__projectId
        res_id      : @category
      })

    parseFetchData : ( data )->
      app_json = data.app_json
      delete data.app_json

      # 1. Parse aws resource data with other collection
      extraAttr = { RES_TAG : @category }
      for type, d of data
        cln = CloudResources( @credential(), type, @__region )
        if not cln
          console.warn "Cannot find cloud resource collection for type:", type
          continue
        cln.__parseExternalData d, extraAttr, @__region, data

      # 2. Fix buggy generated json.
      @generatedJson = @fixGeneratedJson( app_json )
      return

    fixGeneratedJson : ( json )-> json

  }
