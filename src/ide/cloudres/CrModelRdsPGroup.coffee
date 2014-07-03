
define [ "./CrModel", "CloudResources", "ApiRequest", "constant" ], ( CrModel, CloudResources, ApiRequest, constant )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrRdsParameterGroup"
    ### env:dev:end ###

    # defaults:
    #   "Description"            : ""
    #   "DBParameterGroupFamily" : ""
    #   "DBParameterGroupName"   : ""

    taggable : false

    getParameters : ()-> CloudResources( constant.RESTYPE.DBPARAM, @id ).init( @ )

    doCreate : ()->
      self = @
      ApiRequest("rds_pg_CreateDBParameterGroup", {
        param_group        : @get("DBParameterGroupName")
        param_group_family : @get("DBParameterGroupFamily")
        description        : @get("Description")
      }).then ( res )->
        self.set( id , @self.get("DBParameterGroupFamily") )
        self

    doDestroy : ()->
      ApiRequest("rds_pg_DeleteDBParameterGroup", {
        region_name : @collection.region()
        param_group : @id
      })
  }
