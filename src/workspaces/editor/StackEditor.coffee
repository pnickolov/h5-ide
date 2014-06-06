
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
      ]

  StackEditor
