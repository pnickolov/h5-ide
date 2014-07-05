define [
  "ApiRequest"
  "./CrCollection"
  "constant"
  "CloudResources"
  "./CrModelRdsSnapshot"
  "./CrModelRdsPGroup"
  "./CrModelRdsParameter"
], ( ApiRequest, CrCollection, constant, CloudResources, CrRdsSnapshotModel, CrRdsPGroupModel )->


  ### Engine ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDBEngineVersionCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DBENGINE
    doFetch : ()-> ApiRequest("rds_DescribeDBEngineVersions", {region_name : @region()})
    parseFetchData : ( data )->
      data = data?.DescribeDBEngineVersionsResponse.DescribeDBEngineVersionsResult.DBEngineVersions?.DBEngineVersion || []

      if not _.isArray( data ) then data = [data]

      for i in data
        i.icon = i.Engine.split("-")[0]
        i.id = i.Engine + " " + i.EngineVersion

      data
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
      data = data.DescribeDBSnapshotsResponse.DescribeDBSnapshotsResult.DBSnapshots.DBSnapshot || []

      if not _.isArray( data ) then data = [data]

      for i in data
        i.id = i.DBSnapshotIdentifier

      data
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
      data = data.DescribeDBParameterGroupsResponse.DescribeDBParameterGroupsResult.DBParameterGroups.DBParameterGroup || []

      if not _.isArray( data ) then data = [data]

      for i in data
        i.id = i.DBParameterGroupName

      data
  }
