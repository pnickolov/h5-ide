
define [
  "CoreEditor"
  "./OsViewStack"
], ( CoreEditor, StackView )->

  ###
    StackEditor is mainly for editing a stack
  ###
  class StackEditor extends CoreEditor

    viewClass : StackView
    title : ()-> (@design || @opsModel).get("name") + " - stack"

    isReady : ()->
      if @__hasAdditionalData then return true
      if not @opsModel.hasJsonData() or not @opsModel.isPersisted() then return false

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      !!App.model.getStateModule( stateModule.repo, stateModule.tag )

    fetchAdditionalData : ()->
      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      jobs = [
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
      ]

      if not @opsModel.isPersisted() then jobs.unshift( @opsModel.save() )

      Q.all(jobs)

    isModified : ()->
      if not @opsModel.isPersisted() then return true
      @design && @design.isModified()

  StackEditor
