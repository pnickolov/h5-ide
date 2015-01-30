
define [ "../CrModel" ], ( CrModel )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrElbModel"
    ### env:dev:end ###

    initialize : ()->
      self = @
      @sendRequest("elb_DescribeInstanceHealth", {elb_name:@get("Name")}).then ( data )-> self.onInsHealthData( data )
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
