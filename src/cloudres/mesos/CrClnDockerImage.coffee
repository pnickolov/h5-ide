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
      data = data.DescribeDBSnapshotsResponse.DescribeDBSnapshotsResult.DBSnapshots?.DBSnapshot || []

      if not _.isArray( data ) then data = [data]

      for i in data
        i.id = i.DBSnapshotIdentifier

      data
  }
