
define [ "../CrModel" ], ( CrModel )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrElbModel"
    ### env:dev:end ###

    initialize : ()->
      self = @

      # Needs to defer the fetch. Since the collection of this model is not defined
      # when initailize() is called.
      _.defer ()->
        self.sendRequest("elb_DescribeInstanceHealth", {elb_name:self.get("Name")}).then ( data )->
          self.onInsHealthData( data )
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
