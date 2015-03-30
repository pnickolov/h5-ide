
define [ "CanvasLine", "constant", "CanvasManager", "i18n!/nls/lang.js" ], ( CeLine, constant, CanvasManager, lang )->

  CeLine.extend {
    ### env:dev ###
    ClassName : "CeMarathonDepOut"
    ### env:dev:end ###
    type : "MarathonDepOut"
  }


  CeLine.extend {
    ### env:dev ###
    ClassName : "CeMarathonDepIn"
    ### env:dev:end ###
    type : "MarathonDepIn"
  }
