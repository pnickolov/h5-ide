
define [ "./CrModel", "CloudResources", "ApiRequest" ], ( CrModel, CloudResources, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrRdsParameter"
    ### env:dev:end ###

    taggable : false

    # defaults :
    #   "DataType"      : "boolean"
    #   "Source"        : "engine-default"
    #   "IsModifiable"  : false,
    #   "Description"   : "Controls whether user-defined functions that have only an xxx symbol for the main function can be loaded",
    #   "ApplyType"     : "static"
    #   "AllowedValues" : "0,1"
    #   "ParameterName" : "allow-suspicious-udfs"
    #   "ParameterValue": "/rdsdbbin/mysql"

    isValidValue : ( value )->
      if not @attributes.AllowedValues then return true

      valueNum = parseInt( value )
      if value in @attributes.AllowedValues.split(",")
        return true
      for allowed in @attributes.AllowedValues.split(",")
        if allowed.indexOf("-")>=0
          if not /^[0-9]*$/.test(value)
            return false
          range = allowed.split("-")
          if valueNum >= parseInt(range[0]) and valueNum <= parseInt(range[1])
            return true
      false

    applyMethod : ()-> if @get("ApplyType") is "dynamic" then "immediate" else "pending-reboot"
  }
