
define [ "./OpsEditorBase", "./StackView", "Design" ], ( OpsEditorBase, StackView, Design )->

  ###
    StackEditor is mainly for editing a stack
  ###
  class StackEditor extends OpsEditorBase

    title       : ()-> @opsModel.get("name") + " - stack"
    tabClass    : ()-> "icon-stack-tabbar"

    createView   : ()-> new StackView({workspace:this})

    isReady : ()-> @opsModel.hasJsonData()

    fetchAdditionalData : ()->
      d = Q.defer()
      d.resolve()
      d.promise

  StackEditor
