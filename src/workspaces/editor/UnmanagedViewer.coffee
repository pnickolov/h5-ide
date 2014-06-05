
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

    createDesign : ()->
      design = new Design( @opsModel.getJsonData(), {
        mode       : Design.Mode.AppView
        autoFinish : false
      })
      MC.canvas.analysis()
      design.finishDeserialization()
      design

    isReady : ()-> @__isJsonLoaded && @__hasAdditionalData

  UnmanagedViewer
