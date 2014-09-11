
define [
  "CoreEditor"
  "./OsViewStack"
  "./model/DesignOs"
  "CloudResources"
  "constant"
], ( CoreEditor, StackView, DesignOs, CloudResources, constant )->

  ###
    StackEditor is mainly for editing a stack
  ###
  class StackEditor extends CoreEditor

    viewClass   : StackView
    designClass : DesignOs
    title : ()-> (@design || @opsModel).get("name") + " - stack"

    isReady : ()->
      if @__hasAdditionalData then return true
      if not @opsModel.hasJsonData() or not @opsModel.isPersisted() then return false

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      CloudResources( constant.RESTYPE.OSFLAVOR, region ).isReady() &&
      CloudResources( constant.RESTYPE.OSIMAGE,  region ).isReady() &&
      CloudResources( constant.RESTYPE.OSEXTNET, region ).isReady() &&
      !!App.model.getStateModule( stateModule.repo, stateModule.tag )

    fetchAdditionalData : ()->
      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      jobs = [
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( constant.RESTYPE.OSFLAVOR, region ).fetch()
        CloudResources( constant.RESTYPE.OSIMAGE,  region ).fetch()
        CloudResources( constant.RESTYPE.OSEXTNET, region ).fetch()
      ]

      if not @opsModel.isPersisted() then jobs.unshift( @opsModel.save() )

      Q.all(jobs)

    isModified : ()->
      if not @opsModel.isPersisted() then return true
      @design && @design.isModified()

  StackEditor
