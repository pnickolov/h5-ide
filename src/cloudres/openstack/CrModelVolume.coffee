
define [ "../CrModel", "ApiRequestOs" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrOsModelVolume"
    ### env:dev:end ###

    defaults :
      name: ""
      id: ""
      status: ""
      user_id: ""
      availability_zone: ""
      created_at: ""
      description: ""
      size: 0

    #idAttribute : "id"
    taggable: false

    doCreate : ()->
      #TO-DO
      null

    doDestroy : ()->
      #TO-DO
      null

  }
