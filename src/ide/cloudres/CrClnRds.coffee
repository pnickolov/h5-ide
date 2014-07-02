define ["ApiRequest", "./CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDBEngineVersionCollection"
    ### env:dev:end ###

    type  : "DBEngineVersion"
    doFetch : ()-> ApiRequest("rds_DescribeDBEngineVersions", {region_name : @region()})
    parseFetchData : ( data )->
      dbEngineVersion = []
      dbEngineVersion = data?.DescribeDBEngineVersionsResponse?.DescribeDBEngineVersionsResult?.DBEngineVersions?.DBEngineVersion
      dbEngineVersion = _.map dbEngineVersion, (item) ->
        item.id = item.Engine + ' ' + item.EngineVersion
        return item
      # CloudResources('DBEngineVersion', @region()).add dbEngineVersion
      return dbEngineVersion
  }

  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrRDSSnapshotCollection"
    ### env:dev:end ###

    type  : "RDSSnapshot"
    doFetch : ()-> ApiRequest("rds_snap_DescribeDBSnapshots", {region_name : @region()})
    parseFetchData : ( data )->
      rdsSnapshot = []
      rdsSnapshot = data?.DescribeDBSnapshotsResponse?.DescribeDBSnapshotsResult?.DBSnapshots
      rdsSnapshot = _.map rdsSnapshot, (item) ->
        item.id = item.DBSnapshotIdentifier
        return item
      return rdsSnapshot
  }