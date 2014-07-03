define [
  "ApiRequest"
  "./CrCollection"
  "constant"
  "CloudResources"
  "./CrModelRdsParameter"
], ( ApiRequest, CrCollection, constant, CloudResources, CrRdsParamModel )->

  ###
    This kind of collection can only be obtained by CrModelRdsPGroup.getParameters()
  ###

  ### Parameter ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrRDSParamCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DBPARAM
    model : CrRdsParamModel

    __selfParseData : true

    init : ( paramGroupModel )->
      if @groupModel then return
      @groupModel = paramGroupModel
      @listenTo paramGroupModel, "remove", @reset
      @

    region : ()-> @groupModel.collection.region()

    doFetch : ( marker )->
      self = @
      ApiRequest("rds_pg_DescribeDBParameters", {
        region_name : @region()
        param_group : @category
        marker      : marker
      }).then ( data )->
        try
          marker = data.DescribeDBParametersResponse.DescribeDBParametersResult.Marker
          data = data.DescribeDBParametersResponse.DescribeDBParametersResult.Parameters?.Parameter || []
        catch e
          console.log e

        if not _.isArray( data ) then data = [data]

        for d in data
          d.id = d.ParameterName

        if marker
          if not self.__bucket
            self.__bucket = data
          else
            self.__bucket = self.__bucket.concat data
          return self.doFetch( marker )

        if self.__bucket
          data = self.__bucket.concat data
          self.__bucket = null

        data
  }
