
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

    initEditor : ()->
      self = @
      @__refreshInterval = setInterval ()->
        self.loadVpcResource()
      , 8000
      CoreEditorApp.prototype.initEditor.call this

    cleanup : ()->
      if @__refreshInterval
        console.log( "Clearing AutoRefresh Interval" )
        clearInterval @__refreshInterval
        @__refreshInterval = null
      CoreEditorApp.prototype.cleanup.call this

    fetchData : ()->
      self = @

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module
      credId      = @opsModel.credentialId()

      Q.all([
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( credId, constant.RESTYPE.MRTHAPP,   @opsModel.id ).fetch()
        CloudResources( credId, constant.RESTYPE.MRTHGROUP, @opsModel.id ).fetch()
      ])

    diff : ()->

    loadVpcResource : ()-> CloudResources( @opsModel.credentialId(), constant.RESTYPE.MRTHAPP, @opsModel.id ).fetch()

  }, {
    canHandle : ( data )->
      if not data.opsModel then return false
      return data.opsModel.type is OpsModel.Type.Mesos and data.opsModel.isApp() and not data.opsModel.isProcessing()
  }
