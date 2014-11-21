
define [ "CanvasLine", "constant", "CanvasManager", "i18n!/nls/lang.js", "SGRulePopup" ], ( CeLine, constant, CanvasManager, lang, SGRulePopup )->

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeEniAttachment"
    ### env:dev:end ###
    type : "EniAttachment"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeRtbAsso"
    ### env:dev:end ###
    type : "RTB_Asso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeRtbRoute"
    ### env:dev:end ###
    type : "RTB_Route"

    lineStyle : ()-> 1

    createLine : ( pd )->
      svg   = @canvas.svg
      svgEl = CeLine.prototype.createLine.call this, pd
      svgEl.add( svg.path(pd).classes("dash-line") )
      svgEl
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeVpn"
    ### env:dev:end ###
    type : constant.RESTYPE.VPN
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeElbSubnetAsso"
    ### env:dev:end ###
    type : "ElbSubnetAsso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeElbAmiAsso"
    ### env:dev:end ###
    type : "ElbAmiAsso"
  }, {
    connect : ( LineClass, p1Comp, p2Comp )->
      new SGRulePopup( p1Comp, p2Comp )
      new LineClass( p1Comp, p2Comp, undefined, { createByUser : true } )
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeDbReplication"
    ### env:dev:end ###
    type : "DbReplication"

    select : ()-> # Disable selection

    createLine : ( pd )->
      svg   = @canvas.svg
      svgEl = CeLine.prototype.createLine.call this, pd
      svgEl.add( svg.path(pd).classes("dash-line") )
      svgEl
  }

  CeLine
