
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
      json.component = {
        "product" : {
          "type": "DOCKER.MARATHON.Group"
          "id": "product",
          "groups": [{
            "id": "service",
            "groups": [{
              "id": "us-east",
              "apps": [{
                "type":"DOCKER.MARATHON.App"
                "id": "/product/service/my-app",
                "cmd": "env && sleep 300",
                "args": ["/bin/sh", "-c", "env && sleep 300"],
                "container": {},
                "cpus": 1.5,
                "mem": 256.0,
                "deployments": [],
                "env": {},
                "executor": "",
                "constraints": [],
                "healthChecks": [],
                "instances": 3,
                "ports": [
                    8080,
                    9000
                ],
                "backoffSeconds": 1,
                "backoffFactor": 1.15,
                "maxLaunchDelaySeconds": 3600,
                "tasksRunning": 3,
                "tasksStaged": 0,
                "uris": [],
                "dependencies": ["/product/db/mongo", "/product/db", "../../db"],
                "upgradeStrategy": {},
                "version": "2014-03-01T23:29:30.158Z"
              }]
            }],
            "dependencies": ["/product/database", "../backend"]
          }],
          "version": "2014-03-01T23:29:30.158Z"
        }
      }

      json.layout = {
        "/product/service/my-app" :
          coordinate : [9,17]
        "us-east" :
          coordinate : [9,5]
          size       : [10,10]
        "service" :
          coordinate : [7,2]
          size       : [20,40]
        "product" :
          coordinate : [5,3]
          size       : [60,60]
      }

      json
  }, {
    supportedProviders : ["docker::marathon"]
  }
