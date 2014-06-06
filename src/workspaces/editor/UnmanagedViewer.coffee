
define [ "./OpsEditorBase", "./OpsViewBase", "Design" ], ( OpsEditorBase, OpsEditorView, Design )->

  ###
    UnmanagedViewer is mainly used to show visualize vpc
  ###
  class UnmanagedViewer extends OpsEditorBase

    title       : ()-> @opsModel.get("importVpcId") + " - visualization"
    tabClass    : ()-> "icon-visualization-tabbar"

    ###
      Override these methods to implement subclasses.
    ###
    fetchAdditionalData : ()->
      d = Q.defer()
      d.resolve()
      d.promise

    createView : ()->
      new OpsEditorView({
        opsModel  : @opsModel
        workspace : @
      })

    initDesign : ()->
      MC.canvas.analysis()
      @design.finishDeserialization()
      return

    isReady : ()-> @opsModel.hasJsonData()

  UnmanagedViewer
