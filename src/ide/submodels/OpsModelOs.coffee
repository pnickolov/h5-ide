
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define ["OpsModel", "ApiRequest", "constant", "CloudResources" ], ( OpsModel, ApiRequest, constant, CloudResources )->

  AwsOpsModel = OpsModel.extend {
    type : "OpenstackOps"

    # This method init a json for a newly created stack.
    __createRawJson : ()->
      json = OpsModel.prototype.__createRawJson.call this
      json.cloud_type = "openstack"
      json.provider   = "awcloud"
      json
  }

  AwsOpsModel
