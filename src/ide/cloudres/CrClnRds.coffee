define [
  "ApiRequest"
  "./CrCollection"
  "constant"
  "CloudResources"
  "./CrModelRdsSnapshot"
  "./CrModelRdsInstance"
  "./CrModelRdsPGroup"
], ( ApiRequest, CrCollection, constant, CloudResources, CrRdsSnapshotModel, CrRdsDbInstanceModel, CrRdsPGroupModel )->


  ### Engine ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDBEngineVersionCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DBENGINE
    __selfParseData : true

    initialize : ()->
      @optionGroupData = {}
      return

    getEngineOptions : ( engineName )-> @optionGroupData[ engineName ]

    doFetch : ()->
      self = @
      ApiRequest("rds_DescribeDBEngineVersions", {region_name : @region()}).then ( data )->
        try
          data = data.DescribeDBEngineVersionsResponse.DescribeDBEngineVersionsResult.DBEngineVersions.DBEngineVersion
        catch e
          console.error e

        data = data || []
        if not _.isArray( data ) then data = [data]

        engines = {}
        for d in data
          d.id = d.Engine + " " + d.EngineVersion
          engines[ d.Engine ] = true

        jobs = _.keys( engines ).map ( engine_name )->
          ApiRequest("rds_og_DescribeOptionGroupOptions", {
            region_name : self.region()
            engine_name : engine_name
          }).then ( data )->
            try
              self.__parseOptions( data )
            catch e
              console.error e
            return

        Q.all( jobs ).then ()-> data

    __parseOptions : ( data )->
      data = data.DescribeOptionGroupOptionsResponse.DescribeOptionGroupOptionsResult.OptionGroupOptions

      if not data then return

      data = data.OptionGroupOption || []
      if not _.isArray( data ) then data = [data]

      if not data.length then return

      optionData = {}

      for d in data
        engineName = d.EngineName
        if not optionData[ d.MajorEngineVersion ]
          optionData[ d.MajorEngineVersion ] = []

        if d.OptionGroupOptionSettings and d.OptionGroupOptionSettings.OptionGroupOptionSetting
          d.OptionGroupOptionSettings = d.OptionGroupOptionSettings.OptionGroupOptionSetting

        optionData[ d.MajorEngineVersion ].push d

      @optionGroupData[ engineName ] = optionData
      return
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

  ### DBOptionGroup ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDbOptionGroupCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DBOG

    doFetch : ()-> ApiRequest("rds_og_DescribeOptionGroups", {region_name : @region()})
    parseFetchData : ( data )->
      data = data.DescribeOptionGroupsResponse.DescribeOptionGroupsResult.OptionGroupsList.OptionGroup || []
      if not _.isArray( data ) then data = [data]
      for i in data
        i.id = i.OptionGroupName
      data
    parseExternalData: ( data ) ->
      @unifyApi data, @type
      @camelToPascal data
      _.each data, (dataItem) ->
        dataItem.id  = dataItem.OptionGroupName
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
