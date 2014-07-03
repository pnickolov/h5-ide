
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
  }
