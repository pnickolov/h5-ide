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
      @optionGroupData   = {} #existed optiongroup
      @engineDict        = {} #by engineName, engineVersion
      @defaultInfo       = {} #by engine
      return

    #return availibale optiongroup array
    getOptionGroupsByEngine : ( regionName, engineName )->
      if not regionName
        console.error "please provide regionName"
      else if not engineName
        console.error "please provide engineName"
      else
        ogAry = @optionGroupData[regionName][engineName]
      ogAry || ""

    #return like this: (by parameter)
    # {family: "mysql5.6", defaultPGName: "default.mysql5.6", defaultOGName: "default:mysql-5-6", canCustomOG: false}
    getDefaultByNameVersion : ( regionName, engineName, engineVersion )->
      if not regionName
        console.error "please provide regionName"
      else if not engineName
        console.error "please provide engineName"
      else if not engineVersion
        console.error "please provide engineVersion"
      else
        defaultData = @engineDict[regionName][engineName][engineVersion]
      defaultData || ""

    #result is same as getDefaultByNameVersion()
    getDefaultByFamily : ( regionName, family )->
      if not regionName
        console.error "please provide regionName"
      else if not family
        console.error "please provide family"
      else
        defaultData = @defaultInfo[regionName][family]
      defaultData || ""

    doFetch : ()->
      self = @
      regionName = @region()
      ApiRequest("rds_DescribeDBEngineVersions", {region_name : regionName}).then ( data )->

        #init for region
        self.optionGroupData[regionName]    = {}
        self.engineDict[regionName]         = {}
        self.defaultInfo[regionName]        = {}

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

          #generate engine dictionary
          if not self.engineDict[regionName][d.Engine]
            self.engineDict[regionName][d.Engine] = {}
          dict =
            family : d.DBParameterGroupFamily
            defaultPGName : 'default.' + d.DBParameterGroupFamily
            defaultOGName : 'default:' + d.Engine + '-' + d.EngineVersion.split('.').slice(0,2).join('-')
            canCustomOG   : false
          self.engineDict[regionName][d.Engine][d.EngineVersion] = dict

          #generate engine
          if not self.defaultInfo[regionName][d.DBParameterGroupFamily]
            self.defaultInfo[regionName][d.DBParameterGroupFamily] = dict

        jobs = _.keys( engines ).map ( engineName )->
          ApiRequest("rds_og_DescribeOptionGroupOptions", {
            region_name : regionName
            engine_name : engineName
          }).then ( data )->
            try
              self.__parseOptions( self.category, data )
            catch e
              console.error e
            return

        Q.all( jobs ).then ()-> data

    __parseOptions : ( regionName, data )->
      self = @
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

        #generate engine dictionary(optiongroup)
        _.each self.engineDict[regionName][d.EngineName], (item, key) ->
          if key.indexOf( d.MajorEngineVersion ) is 0
            item.canCustomOG = true

      @optionGroupData[regionName][engineName] = optionData
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
