define [
  "ApiRequest"
  "./CrCollection"
  "constant"
  "CloudResources"
  "./CrModelRdsSnapshot"
  "./CrModelRdsInstance"
  "./CrModelRdsPGroup"
  "./CrModelRdsParameter"
], ( ApiRequest, CrCollection, constant, CloudResources, CrRdsDbInstanceModel, CrRdsSnapshotModel, CrRdsPGroupModel )->


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

  ### DBSubnetGroup ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDbSubnetGroupCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DBSBG
    #model : CrRdsDbSubnetGroupModel

    doFetch : ()-> ApiRequest("rds_subgrp_DescribeDBSubnetGroups", {region_name : @region()})
    parseFetchData : ( data )->
      data = data.DescribeDBSubnetGroupsResponse.DescribeDBSubnetGroupsResult.DBSubnetGroups?.DBSubnetGroup || []
      if not _.isArray( data ) then data = [data]
      for i in data
        i.id = i.DBSubnetGroupName
        i.Subnets = i.Subnets?.Subnet
      data
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @camelToPascal data
      _.each data, (dataItem) ->
        dataItem.id  = dataItem.DBSubnetGroupName
      data
  }

  ### DBInstance ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDbInstanceCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DBINSTANCE
    model : CrRdsDbInstanceModel

    doFetch : ()-> ApiRequest("rds_ins_DescribeDBInstances", {region_name : @region()})
    parseFetchData : ( data )->
      data = data.DescribeDBInstancesResponse.DescribeDBInstancesResult.DBInstances?.DBInstance || []
      if not _.isArray( data ) then data = [data]
      for i in data
        i.id   = i.DBInstanceIdentifier #use name as id
        i.Name = i.DBName
        i.sbgId = i.DBSubnetGroup.DBSubnetGroupName
        i.DBParameterGroups = i.DBParameterGroups?.DBParameterGroup || []
        i.DBSecurityGroups  = i.DBSecurityGroups?.DBSecurityGroup || []
      data
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @camelToPascal data
      _.each data, (dataItem) ->
        #convert DBSubnetGroup
        if dataItem.DBSubnetGroup
          dataItem.DBSubnetGroup.DBSubnetGroupDescription = dataItem.DBSubnetGroup.DbsubnetGroupDescription
          dataItem.DBSubnetGroup.DBSubnetGroupName        = dataItem.DBSubnetGroup.DbsubnetGroupName
          delete dataItem.DBSubnetGroup.DbsubnetGroupDescription
          delete dataItem.DBSubnetGroup.DbsubnetGroupName
        #convert DBParameterGroups
        for pg in dataItem.DBParameterGroups
          pg.DBParameterGroupName = pg.DbparameterGroupName
          delete pg.DbparameterGroupName
        dataItem.id  = dataItem.DBInstanceIdentifier #use name as id
        dataItem.Name = dataItem.DBName
        dataItem.sbgId = dataItem.DBSubnetGroup.DBSubnetGroupName #subnetGroup
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
      data = data.DescribeDBSnapshotsResponse.DescribeDBSnapshotsResult.DBSnapshots?.DBSnapshot || []

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
      data = data.DescribeDBParameterGroupsResponse.DescribeDBParameterGroupsResult.DBParameterGroups?.DBParameterGroup || []

      if not _.isArray( data ) then data = [data]

      for i in data
        i.id = i.DBParameterGroupName

      data
  }
