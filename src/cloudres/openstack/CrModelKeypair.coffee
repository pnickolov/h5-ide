
define [ "../CrModel", "ApiRequestOs" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrOsModelKeypair"
    ### env:dev:end ###

    defaults :
      name        : ""
      public_key  : ""
      fingerprint : ""

    idAttribute : "name"
    taggable: false

    doCreate : ()->
      #TO-DO
      null

    doDestroy : ()->
      #TO-DO
      null

  }
