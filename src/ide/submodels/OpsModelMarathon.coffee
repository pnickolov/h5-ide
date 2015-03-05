
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
        PRODUCT001 : {
          uid      : "PRODUCT001",
          type     : "DOCKER.MARATHON.Group",
          toplevel : true
          resource : {
            id : "prodcut",
            groups : [ "SERVICE001" ]
          }
        },

        SERVICE001 : {
          uid  : "SERVICE001",
          type : "DOCKER.MARATHON.Group",
          resource : {
            id     : "service",
            groups : [ "USEAST001" ]
          }
        },

        USEAST001 : {
          uid  : "USEAST001",
          type : "DOCKER.MARATHON.Group",
          resource : {
            id   : "us-east",
            apps : [ "MYAPP001" ]
          }
        },

        MYAPP001 : {
          uid  : "MYAPP001",
          type : "DOCKER.MARATHON.App",
          resource : {
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
          }
        }
      }

      json.layout = {
        "MYAPP001" :
          coordinate : [9,17]
          groupUId : "USEAST001"
        "USEAST001" :
          coordinate : [9,5]
          size       : [10,10]
          groupUId : "SERVICE001"
        "SERVICE001" :
          coordinate : [7,2]
          size       : [20,40]
          groupUId : "PRODUCT001"
        "PRODUCT001" :
          coordinate : [5,3]
          size       : [60,60]
      }

      json
  }, {
    supportedProviders : ["docker::marathon"]
  }
