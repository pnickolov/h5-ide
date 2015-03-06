
define [
  "CoreEditorApp"
  "./MarathonViewApp"
  "./model/DesignMarathon"
  "./MarathonEditorStack"
  "OpsModel"
  "CloudResources"
  "constant"

  "./MarathonDeps"
], ( CoreEditorApp, AppView, DesignMarathon, StackEditor, OpsModel, CloudResources, constant )->

  CoreEditorApp.extend {

    type : "MarathonEditorApp"

    viewClass   : AppView
    designClass : DesignMarathon

    fetchData : ()->
      self = @

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module
      credId      = @opsModel.credentialId()

      Q.all([
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
      ])

    diff : ()->

  }, {
    canHandle : ( data )->
      if not data.opsModel then return false
      return data.opsModel.type is OpsModel.Type.Mesos and data.opsModel.isApp() and not data.opsModel.isProcessing()
  }
