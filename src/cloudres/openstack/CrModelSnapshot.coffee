
define [ "../CrModel", "ApiRequestOs" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrOsModelSnapshot"
    ### env:dev:end ###

    defaults :
      status        : ""
      description   : ""
      created_at    : ""
      name          : ""
      volume_id     : ""
      size          : ""
      id            : ""
      metadata      : ""

    #idAttribute : "id"
    taggable: false

    doCreate : ()->
      #TO-DO
      null

    doDestroy : ()->
      #TO-DO
      null

  }
