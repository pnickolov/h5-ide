
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrElbModel"
    ### env:dev:end ###

    initialize : ()->
      self = @
      ApiRequest("elb_DescribeInstanceHealth", {
        region_name : @get("category")
        elb_name    : @get("Name")
      }).then ( data )-> self.onInsHealthData( data )
      return

    onInsHealthData : ( data )->
      data = data.DescribeInstanceHealthResponse
      if not data then return
      data = data.DescribeInstanceHealthResult
      if not data then return
      data = data.InstanceStates?.member
      if not data then return
      @set "InstanceStates", data
      return
  }
