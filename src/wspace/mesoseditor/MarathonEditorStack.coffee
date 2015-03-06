
define [
  "CoreEditor"
  "OpsModel"
  "./MarathonViewStack"
  "./model/DesignMarathon"
  "CloudResources"
  "constant"
  "Credential"

  "./MarathonDeps"
], ( CoreEditor, OpsModel, StackView, DesignMarathon, CloudResources, constant, Credential )->


  ###
    StackEditor is mainly for editing a stack
  ###
  CoreEditor.extend {

    type : "MarathonEditorStack"

    viewClass   : StackView
    designClass : DesignMarathon

    title : ()-> (@design || @opsModel).get("name") + " - stack"

    fetchData : ()->
      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module
      credId      = @opsModel.credentialId()

      jobs = [
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( credId, constant.RESTYPE.DOCKERIMAGE, region ).fetch()
      ]

      Q.all(jobs)

    isModified : ()->
      if not @opsModel.isPersisted() then return false
      @design && @design.isModified()
  }, {
    canHandle : ( data )->
      if not data.opsModel then return false
      return data.opsModel.type is OpsModel.Type.Mesos and data.opsModel.isStack()
  }
