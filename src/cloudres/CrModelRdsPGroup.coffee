
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

    isDefault : ()-> (@get("DBParameterGroupName") || "").indexOf("default.") is 0

    getParameters : ()-> CloudResources( constant.RESTYPE.DBPARAM, @id ).init( @ )

    doCreate : ()->
      self = @
      ApiRequest("rds_pg_CreateDBParameterGroup", {
        region_name        : @getCollection().region()
        param_group        : @get("DBParameterGroupName")
        param_group_family : @get("DBParameterGroupFamily")
        description        : @get("Description")
      }).then ( res )->
        self.set( "id" , self.get("DBParameterGroupName") )
        self

    doDestroy : ()->
      ApiRequest("rds_pg_DeleteDBParameterGroup", {
        region_name : @collection.region()
        param_group : @id
      })

    resetParams : ()->
      self = @
      ApiRequest("rds_pg_ResetDBParameterGroup", {
        region_name      : @collection.region()
        param_group : @id
        reset_all   : true
      }).then ()-> self.getParameters().fetchForce()

    modifyParams : ( paramNewValueMap )->
      ###
      paramNewValueMap = {
        "allow-suspicious-udfs" : 0
        "log_output" : "TABLE"
      }
      ###
      pArray = []
      for name, value of paramNewValueMap
        pArray.push {
          ParameterName  : name
          ParameterValue : value
          ApplyMethod    : @getParameters().get( name ).applyMethod()
        }

      requests = []
      params = {
        region_name : @collection.region()
        param_group : @id
        parameters  : []
      }
      i = 0
      while i < pArray.length
        params.parameters = pArray.slice(i, i+20)
        requests.push ApiRequest("rds_pg_ModifyDBParameterGroup", params)
        i+=20

      self = @
      parameters = self.getParameters()
      Q.all( requests ).then ()->
        for name, value of paramNewValueMap
          parameters.get(name).set("ParameterValue", value)
        return
  }
