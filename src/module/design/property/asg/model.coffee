#############################
#  View Mode for design/property/instance
#############################

define [ 'jquery' ], () ->

  ASGConfigModel = Backbone.Model.extend {

    defaults :
      uid : null
      asg : null

    initialize : ->
      null

    setUID : ( uid ) ->

      data =
        uid : uid

      this.set data
      null
  }

  model = new ASGConfigModel()

  return model
