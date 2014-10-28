
define [ "CanvasLine", "constant" ], ( CeLine, constant )->

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeListenerAsso"
    ### env:dev:end ###
    type : "OsListenerAsso"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CePortUsage"
    ### env:dev:end ###
    type : "OsPortUsage"
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeRouterAsso"
    ### env:dev:end ###
    type : "OsRouterAsso"

    appendLineToCanvas : ( svgEl )-> @canvas.appendGroupLine( svgEl )
  }

  CeLine.extend {
    ### env:dev ###
    ClassName : "CePoolMembership"
    ### env:dev:end ###
    type : "OsPoolMembership"
  }
