define [
  "../CrCollection"
  "constant"
  "./CrModelDockerImage"
], ( CrCollection, constant, CrRdsDockerImageModel )->

  ### Snapshot ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDockerImageCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DOCKERIMAGE
    model : CrRdsDockerImageModel

    doFetch : ()-> @sendRequest("marathon_images")
    parseFetchData : ( data )->

      data = data?.docker_hub or []

      for i in data
        i.id = i.name

      data
  }
