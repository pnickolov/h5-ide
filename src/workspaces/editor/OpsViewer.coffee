
###
  OpsViewer is a readonly viewer to show the app ( Basically it shows the visualize vpc )
###

define [ "./OpsEditorBase", "./OpsViewerView" ], ( OpsEditorBase, OpsViewerView )->

  class OpsViewer extends OpsEditorBase

    title : ()-> @opsModel.get("importVpcId") + " - visualization"

    tabClass : ()-> "icon-visualization-tabbar"

    initialize : ()->
      @view = new OpsViewerView()
      @opsModel.getJsonData()

      @view.listenTo @opsModel, "jsonDataLoaded", @view.dataLoaded

  OpsViewer
