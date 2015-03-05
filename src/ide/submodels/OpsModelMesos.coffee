
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["OpsModel", "ApiRequest", "constant" ], ( OpsModel, ApiRequest, constant )->

  OpsModel.extend {

    type : OpsModel.Type.Mesos

    # We don't care which credential the mesos stack use, be we need a credential to send request to the server
    credential   : ()-> @project().credentials().models[0]

    getMsrId : ()->

    __defaultJson : ()->
      json = OpsModel.prototype.__defaultJson.call this

      json
  }, {
    supportedProviders : ["docker::marathon"]
  }
