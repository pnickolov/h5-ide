
define [ "../CrModel", "ApiRequestOs" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrOsModelVolume"
    ### env:dev:end ###

    defaults :
      name: ""
      id: ""

    #idAttribute : "id"
    taggable: false

    doCreate : ()->
      #TO-DO
      null

    doDestroy : ()->
      #TO-DO
      null

  }
