
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["OpsModel", "ApiRequest", "constant" ], ( OpsModel, ApiRequest, constant )->

  OsOpsModel = OpsModel.extend {

    type : OpsModel.Type.Mesos

    getMsrId : ()->

    __defaultJson : ()->
      json = OpsModel.prototype.__defaultJson.call this

      json
  }, {
    supportedProviders : ["mesos::mesos"]
  }

  OsOpsModel
