
define [
  "./OpsEditorBase"
  "./StackView"
  "Design"
  "CloudResources"
  "constant"
], ( OpsEditorBase, StackView, Design, CloudResources, constant )->

  ###
    StackEditor is mainly for editing a stack
  ###
  class StackEditor extends OpsEditorBase

    title       : ()-> (@design || @opsModel).get("name") + " - stack"
    tabClass    : ()-> "icon-stack-tabbar"

    createView : ()->
      new StackView({workspace:this})

    isReady : ()->
      if not @opsModel.hasJsonData() then return false

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      CloudResources( constant.RESTYPE.AZ, region ).isReady()   &&
      CloudResources( constant.RESTYPE.SNAP, region ).isReady() &&
      CloudResources( "QuickStartAmi",       region ).isReady() &&
      CloudResources( "MyAmi",               region ).isReady() &&
      CloudResources( "FavoriteAmi",         region ).isReady() &&
      !!App.model.getStateModule( stateModule.repo, stateModule.tag )

    fetchAdditionalData : ()->
      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      Q.all [
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( constant.RESTYPE.AZ,   region ).fetch()
        CloudResources( constant.RESTYPE.SNAP, region ).fetch()
        CloudResources( "QuickStartAmi",       region ).fetch()
        CloudResources( "MyAmi",               region ).fetch()
        CloudResources( "FavoriteAmi",         region ).fetch()
      ]

    cleanup : ()->
      # Ask parent to cleanup first, so that removing opsModel won't trigger change event.
      OpsEditorBase.prototype.cleanup.call this

      # If the OpsModel doesn't exist in server, we would destroy it when the editor is closed.
      if not @opsModel.isPresisted()
        @opsModel.remove()
      return

    isModified : ()->
      if not @opsModel.isPresisted() then return true
      @design && @design.isModified()

  StackEditor
