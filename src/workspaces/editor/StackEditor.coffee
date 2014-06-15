
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

    title       : ()-> @opsModel.get("name") + " - stack"
    tabClass    : ()-> "icon-stack-tabbar"

    createView : ()->
      new StackView({workspace:this})

    isReady : ()->
      @opsModel.hasJsonData() && CloudResources( constant.RESTYPE.AZ, @opsModel.get("region") ).isReady() && CloudResources( constant.RESTYPE.SNAP, @opsModel.get("region") ).isReady()

    fetchAdditionalData : ()->
      region = @opsModel.get("region")
      Q.all [
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
