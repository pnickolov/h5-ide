define [
  "ApiRequest"
  "./CrCollection"
  "constant"
  "CloudResources"
  "./CrModelRdsSnapshot"
  "./CrModelRdsPGroup"
], ( ApiRequest, CrCollection, constant, CloudResources, CrRdsSnapshotModel, CrRdsPGroupModel )->


  ### Engine ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDBEngineVersionCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DBENGINE
    doFetch : ()-> ApiRequest("rds_DescribeDBEngineVersions", {region_name : @region()})
    parseFetchData : ( data )->
      dbEngineVersion = []
      dbEngineVersion = data?.DescribeDBEngineVersionsResponse?.DescribeDBEngineVersionsResult?.DBEngineVersions?.DBEngineVersion
      dbEngineVersion = _.map dbEngineVersion, (item) ->
        item.id = item.Engine + ' ' + item.EngineVersion
        return item
      return dbEngineVersion
  }


  ### Snapshot ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrRDSSnapshotCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DBSNAP
    model : CrRdsSnapshotModel

    doFetch : ()-> ApiRequest("rds_snap_DescribeDBSnapshots", {region_name : @region()})
    parseFetchData : ( data )->
      rdsSnapshot = []
      rdsSnapshots = data?.DescribeDBSnapshotsResponse?.DescribeDBSnapshotsResult?.DBSnapshots
      if _.isArray(rdsSnapshots.DBSnapshot)
        rdsSnapshot = rdsSnapshots.DBSnapshot
      else
        rdsSnapshot = rdsSnapshots
      rdsSnapshot = _.map rdsSnapshot, (item) ->
        item.id = item.DBSnapshotIdentifier
        return item
      return rdsSnapshot
  }


  ### Parameter Group ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrRDSPGroupCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DBPG
    model : CrRdsPGroupModel

    doFetch : ()-> ApiRequest("rds_pg_DescribeDBParameterGroups", {region_name : @region()})
    parseFetchData : ( data )->
      rdsSnapshot = []
      rdsSnapshots = data?.DescribeDBSnapshotsResponse?.DescribeDBSnapshotsResult?.DBSnapshots
      if _.isArray(rdsSnapshots.DBSnapshot)
        rdsSnapshot = rdsSnapshots.DBSnapshot
      else
        rdsSnapshot = rdsSnapshots
      rdsSnapshot = _.map rdsSnapshot, (item) ->
        item.id = item.DBSnapshotIdentifier
        return item
      return rdsSnapshot
  }
