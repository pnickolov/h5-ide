
define [ "./AsgModel", "Design", "constant", "i18n!/nls/lang.js", "./connection/LcUsage" ], ( AsgModel, Design, constant, lang, LcUsage )->

  Model = AsgModel.extend {

    defaults : ()->
      cooldown : "300"
      capacity : "1"
      minSize  : "1"
      maxSize  : "2"

      healthCheckGracePeriod : "300"
      healthCheckType        : "EC2"

      terminationPolicies : [ "Default" ]
      expandedList : []
      policies : []

    type : constant.RESTYPE.MESOSASG
    newNameTmpl : "asg"

  }, {

    handleTypes : constant.RESTYPE.MESOSASG
  }

  Model

