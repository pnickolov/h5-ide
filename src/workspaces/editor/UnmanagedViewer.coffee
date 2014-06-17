
define [ "./OpsEditorBase", "./UnmanagedView", "Design" ], ( OpsEditorBase, UnmanagedView, Design )->

  ###
    UnmanagedViewer is mainly used to show visualize vpc
  ###
  class UnmanagedViewer extends OpsEditorBase

    title    : ()-> @opsModel.get("importVpcId") + " - app"
    tabClass : ()-> "icon-visualization-tabbar"

    ###
      Override these methods to implement subclasses.
    ###
    createView : ()->
      new UnmanagedView({
        opsModel  : @opsModel
        workspace : @
      })

    initDesign : ()->
      MC.canvas.analysis()
      @design.finishDeserialization()
      return

    isReady : ()-> @opsModel.hasJsonData()

  UnmanagedViewer
