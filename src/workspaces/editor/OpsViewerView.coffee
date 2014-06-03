
define [ "./OpsViewerTpl", "./CanvasTpl", "backbone" ], ( OpsViewerTpl, CanvasTpl )->

  Backbone.View.extend {

    dataLoaded : ()-> @__hasJsonData = true

    render : ()->
      if @__hasJsonData
        tpl = CanvasTpl()
      else
        tpl = OpsViewerTpl.loading()

      @setElement $(tpl).appendTo("#main")[0]
      return

  }
