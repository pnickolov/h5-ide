
define [ "./CeLine", "constant", "./CanvasManager", "i18n!/nls/lang.js" ], ( CeLine, constant, CanvasManager, lang )->

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeSgLine"
    ### env:dev:end ###
    type : "SgRuleLine"

    createLine : ( pd )->
      svg = @canvas.svg
      svgEl = svg.group().add([
        svg.path(pd)
        svg.path(pd).classes("fill-line")
      ]).attr({"data-id":@cid}).classes("line " + @type.replace(/\./g, "-") )

      @canvas.appendSgline( svgEl )
      svgEl

    renderConnection : ( item_from, item_to, element1, element2 )->
      CeLine.prototype.renderConnection.call this, item_from, item_to, element1, element2

    lineStyle : ()-> @canvas.lineStyle()
  }
