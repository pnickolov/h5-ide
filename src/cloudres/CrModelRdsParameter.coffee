
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

      valueNum = Number( value )
      if value in @attributes.AllowedValues.split(",")
        return true
      for allowed in @attributes.AllowedValues.split(",")
        if allowed.indexOf("-")>=0
          if not (!isNaN(parseFloat(value)) && isFinite(value))
            return false
          #validate range
          if allowed.split("-").length>=2
            if allowed.indexOf("-") is 0
              second_minus = allowed.indexOf("-",1)
            else
              second_minus = allowed.indexOf("-",0)
            allowed = allowed.substr( 0,second_minus ) + "#" + allowed.substr( second_minus+1 )
            range = allowed.split("#")
            if valueNum >= Number(range[0]) and valueNum <= Number(range[1])
              return true
      false

    isFunctionValue: (value)->
      reg = /^((GREATEST|LEAST|SUM)\s*\(\s*)*((({(DBInstanceClassMemory|AllocatedStorage|EndPointPort))+((\/|\*|\+|\-)*(\d+|(DBInstanceClassMemory|AllocatedStorage|EndPointPort)))*}|\d+)\s*,?\s*\)*)*$/
      reg.test(value)

    isNumber: (value)->
      reg = /^\d+$/
      reg.test(value)

    applyMethod : ()-> if @get("ApplyType") is "dynamic" then "immediate" else "pending-reboot"
  }
