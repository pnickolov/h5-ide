
define [ "CanvasLine", "constant", "CanvasManager", "i18n!/nls/lang.js", "SGRulePopup" ], ( CeLine, constant, CanvasManager, lang, SGRulePopup )->

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
