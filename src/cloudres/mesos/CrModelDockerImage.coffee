define [ "../CrModel", "CloudResources", "ApiRequest" ], ( CrModel, CloudResources, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrDockerImageModel"
    ### env:dev:end ###

    defaults :
      "is_automated": false
      "name": ""
      "star_count": 0
      "is_trusted": false
      "is_official": true
      "description": ""
  }
