
define [
  "CoreEditorApp"
  "./MesosViewApp"
  "./model/DesignMesos"
  "./MesosEditorStack"
  "OpsModel"
  "CloudResources"
  "constant"

  "./MesosDeps"
], ( CoreEditorApp, AppView, DesignMesos, StackEditor, OpsModel, CloudResources, constant )->

  CoreEditorApp.extend {

    type : "MesosEditorApp"

    viewClass   : AppView
    designClass : DesignMesos

    fetchData : ()->
      self = @

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module
      credId      = @opsModel.credentialId()

      Q.all([
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
      ])

  }, {
    canHandle : ( data )->
      if not data.opsModel then return false
      return data.opsModel.type is OpsModel.Type.Mesos and data.opsModel.isApp() and not data.opsModel.isProcessing()
  }
