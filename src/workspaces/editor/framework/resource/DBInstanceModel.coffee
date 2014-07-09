
define [ "../ComplexResModel", "Design", "constant", 'i18n!/nls/lang.js', 'CloudResources' ], ( ComplexResModel, Design, constant, lang, CloudResources )->

  versionCompare = (left, right) ->
    return false  unless typeof left + typeof right is "stringstring"
    a = left.split(".")
    b = right.split(".")
    i = 0
    len = Math.max(a.length, b.length)
    while i < len
      if (a[i] and not b[i] and parseInt(a[i]) > 0) or (parseInt(a[i]) > parseInt(b[i]))
        return 1
      else if (b[i] and not a[i] and parseInt(b[i]) > 0) or (parseInt(a[i]) < parseInt(b[i]))
        return -1
      i++
    0

  Model = ComplexResModel.extend {

    defaults : () ->
      x        : 0
      y        : 0
      width    : 9
      height   : 9

      accessible: false
      username: 'root'
      password: '12345678'
      multiAz: true
      iops: ''
      autoMinorVersionUpgrade: true
      backupRetentionPeriod: 1
      allocatedStorage: 5
      backupWindow: ''
      maintenanceWindow: ''
      characterSetName: ''
      dbName: ''
      address: ''
      port: ''
      pending: ''
      instanceId: ''
      replicaId: ''
      snapshotId: ''
      az: ''
      replicas: ''
      ogName: ''
      pgName: ''


    type : constant.RESTYPE.DBINSTANCE
    newNameTmpl : "db-"

    __cachedSpecifications: null

    constructor : ( attr, option ) ->

      ComplexResModel.call( @, attr, option )

    initialize : ( attr, option ) ->

      SgAsso = Design.modelClassForType "SgAsso"

      if attr.sourceDBInstance
        #Create ReadReplica
        @set 'replicaId', attr.sourceDBInstance.createRef('DBInstanceIdentifier')
        @set 'engine', attr.sourceDBInstance.get("engine")
        # Draw before creating SgAsso
        @draw true
        for sg in attr.sgList || []
          new SgAsso sg, @

      else if option and option.createByUser
        #Create new DBInstance
        # Draw before creating SgAsso
        @draw true
        # Default Sg
        defaultSg = Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg()
        new SgAsso defaultSg, @

        # Default Values
        @set {
          license         : @getDefaultLicense()
          engineVersion   : @getDefaultVersion()
          instanceClass   : @getDefaultInstanceClass()
          port            : @getDefaultPort()
        }

        if attr.snapshotId
          #Create new DBInstance from snapshot
          @set 'snapshotId', attr.snapshotId

      null

    defaultPortMap:
      'mysql'         : 3306
      'postgres'      : 5432

      'oracle-ee'     : 1521
      'oracle-se'     : 1521
      'oracle-se1'    : 1521

      'sqlserver-ee'  : 1433
      'sqlserver-ex'  : 1433
      'sqlserver-se'  : 1433
      'sqlserver-web' : 1433


    getRdsInstances: -> App.model.getRdsData(@design().region())?.instance[@get 'engine']

    getDefaultPort: ->
      @defaultPortMap[@get('engine')]

    getLicenseObj: ( getDefault ) ->
      currentLicense = @get 'license'

      if currentLicense then obj = _.findWhere @getSpecifications(), license: currentLicense
      if not obj and getDefault then obj = @getSpecifications()[0]

      obj

    getVersionObj: ( getDefault ) ->
      versions = @getLicenseObj(true).versions
      currentVersion = @get 'engineVersion'

      if currentVersion then obj = _.findWhere versions, version: currentVersion
      if not obj and getDefault then obj = versions[0]

      obj

    getInstanceClassObj: ( getDefault ) ->
      instanceClasses = @getVersionObj(true).instanceClasses
      currentClass = @get 'instanceClass'

      if currentClass then obj = _.findWhere instanceClasses, instanceClass: currentClass
      if not obj and getDefault
        consoleDefault = 'db.t1.micro'
        obj = _.find instanceClasses, (i) -> i.instanceClass is consoleDefault
        if not obj then obj = instanceClasses[0]

      obj

    getDefaultLicense: -> @getLicenseObj(true).license

    getDefaultVersion: -> @getVersionObj(true).version

    getDefaultInstanceClass: -> @getInstanceClassObj(true).instanceClass

    # Get and Process License, EngineVersion, InstanceClass and multiAZ
    getLVIA: (spec) ->
      if not spec then return []

      currentLicense = @get 'license'
      currentVersion = @get 'engineVersion'
      currentClass   = @get 'instanceClass'

      spec[1] = license: 'test', versions: [ { version: '0.0.1', instanceClasses: [{instanceClass:'test', multiAZCapable: false}]} ]

      license = _.first _.filter spec, (s) ->
        if s.license is currentLicense
          s.selected = true
          true
        else
          delete s.selected
          false

      version = _.first _.filter license.versions, (v) ->
        if v.version is currentVersion
          v.selected = true
          true
        else
          delete v.selected
          false

      if not version
        version = @getVersionObj true
        @set 'engineVersion', version.version
        _.findWhere(license.versions, {version: version.version})?.selected = true

      instanceClass = _.first _.filter version.instanceClasses, (i) ->
        if i.instanceClass is currentClass
          i.selected = true
          true
        else
          delete i.selected
          false

      if not instanceClass
        instanceClass = @getInstanceClassObj true
        @set 'instanceClass', instanceClass.instanceClass
        _.where(version.instanceClasses, {instanceClass: instanceClass.instanceClass})?.selected = true

      if not instanceClass.multiAZCapable
        @set 'multiAz', false

      [spec, license.versions, version.instanceClasses, instanceClass.multiAZCapable]


    getSpecifications: ->
      if @__cachedSpecifications then return @__cachedSpecifications

      that = @
      instances = @getRdsInstances()

      if not instances then return null

      spec = {}
      specArr = []

      for i in instances
        spec[i.LicenseModel] = {} if not spec[i.LicenseModel]
        spec[i.LicenseModel][i.EngineVersion] = {} if not spec[i.LicenseModel][i.EngineVersion]
        spec[i.LicenseModel][i.EngineVersion][i.DBInstanceClass] = multiAZCapable: i.MultiAZCapable

      for license, versions of spec
        lObj = license: license, versions: []
        for version, classes of versions
          vObj = version: version, instanceClasses: []
          for cla, az of classes
            vObj.instanceClasses.push instanceClass: cla, multiAZCapable: az.multiAZCapable

          vObj.instanceClasses = _.sortBy vObj.instanceClasses, (cla) -> Model.instanceClassList.indexOf cla.instanceClass
          lObj.versions.push vObj

        lObj.versions.sort (a, b) -> versionCompare b.version, a.version
        specArr.push lObj

      @__cachedSpecifications = specArr

      specArr

    getCost : ( priceMap, currency )->
      if not priceMap.database then return null

      engine = @attributes['engine']
      if engine == 'postgres'
        engine = 'postgresql'
      else if engine in ['oracle-ee', 'oracle-se', 'oracle-se1']
        engine = 'oracle'
      else if engine in ['sqlserver-ee', 'sqlserver-ex', 'sqlserver-se', 'sqlserver-web']
        engine = 'sqlserver'
        sufix = engine.split('-')[1]
      dbInstanceType = @attributes['instanceClass'].split('.')
      deploy = if @attributes['multiAz'] then 'multiAZ' else 'standard'

      if not engine or not deploy then return null

      unit = priceMap.database.rds.unit
      try
        fee = priceMap.database.rds[ engine ][ dbInstanceType[0] ][ dbInstanceType[1] ][ dbInstanceType[2] ]

        license = null
        if @attributes['license'] is 'license-included'
          license = 'li'
        else if @attributes['license'] is 'bring-your-own-license'
          license = 'byol'

        if license == 'li' and engine == 'sqlserver'
          license = license + sufix

        for p in fee
          if p.deploy != deploy
            continue
          if license and license != p.license
            continue

          fee = p[ currency ]
          break

        if not fee or typeof(fee) isnt 'number' then return null

        if unit is "pricePerHour"
          formatedFee = fee + "/hr"
          fee *= 24 * 30
        else
          formatedFee = fee + "/mo"

        priceObj =
            resource    : @attributes['name']
            type        : @attributes['instanceClass']
            fee         : fee
            formatedFee : formatedFee

        return priceObj

      catch err
        console.err "Error while get database instance price", err
      finally

    category: (type) ->
      if type is 'instance'
        return !(@get('snapshotId') or @get('replicaId'))
      else if type
        return !!@get("#{type}Id")

      if @get 'snapshotId' then return 'snapshot'
      if @get 'replicaId' then return 'replica'

      return 'instance'

    serialize : () ->
      sgArray = _.map @connectionTargets("SgAsso"), ( sg )-> sg.createRef( "GroupId" )

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CreatedBy                             : @get 'appId'
          DBInstanceIdentifier                  : @get 'instanceId'
          DBSnapshotIdentifier                  : @get 'snapshotId'
          ReadReplicaSourceDBInstanceIdentifier : @get 'replicaId'

          AllocatedStorage                      : @get 'allocatedStorage'
          AutoMinorVersionUpgrade               : @get 'autoMinorVersionUpgrade'
          AvailabilityZone                      : @get 'az'
          MultiAZ                               : @get 'multiAz'
          Iops                                  : @get 'iops'
          BackupRetentionPeriod                 : @get 'backupRetentionPeriod'
          CharacterSetName                      : @get 'characterSetName'
          DBInstanceClass                       : @get 'instanceClass'
          ReadReplicaDBInstanceIdentifiers      : @get 'replicas'

          DBName                                : @get 'dbName'
          Endpoint:
            Port   : @get 'port'
            Address: @get 'address'
          Engine                                : @get 'engine'
          EngineVersion                         : '5.6.13' # @get 'engineVersion'
          LicenseModel                          : @get 'license'
          MasterUsername                        : @get 'username'
          MasterUserPassword                    : @get 'password'

          OptionGroupMembership:
            OptionGroupName: 'default:mysql-5-6' # @get 'ogName'
            Status: @get 'ogStatus'

          DBParameterGroups:
            DBParameterGroupName: 'default.mysql5.6' # @get 'pgName'

          PendingModifiedValues                 : @get 'pending'

          PreferredBackupWindow                 : @get 'backupWindow'
          PreferredMaintenanceWindow            : @get 'maintenanceWindow'

          PubliclyAccessible                    : @get 'accessible'

          DBSubnetGroup:
            DBSubnetGroupName                   : @parent().createRef 'DBSubnetGroupName'
          VpcSecurityGroupIds                   : sgArray

      { component : component, layout : @generateLayout() }


  }, {

    handleTypes: constant.RESTYPE.DBINSTANCE

    instanceClassList: ["db.t1.micro", "db.m1.small", "db.m1.medium", "db.m1.large", "db.m1.xlarge", "db.m2.xlarge", "db.m2.2xlarge", "db.m2.4xlarge", "db.m3.medium", "db.m3.large", "db.m3.xlarge", "db.m3.2xlarge", "db.r3.large", "db.r3.xlarge", "db.r3.2xlarge", "db.r3.4xlarge", "db.r3.8xlarge"]

    oracleCharset: ["AL32UTF8", "JA16EUC", "JA16EUCTILDE", "JA16SJIS", "JA16SJISTILDE", "KO16MSWIN949", "TH8TISASCII", "VN8MSWIN1258", "ZHS16GBK", "ZHT16HKSCS", "ZHT16MSWIN950", "ZHT32EUC", "BLT8ISO8859P13", "BLT8MSWIN1257", "CL8ISO8859P5", "CL8MSWIN1251", "EE8ISO8859P2", "EL8ISO8859P7", "EL8MSWIN1253", "EE8MSWIN1250", "NE8ISO8859P10", "NEE8ISO8859P4", "WE8ISO8859P15", "WE8MSWIN1252", "AR8ISO8859P6", "AR8MSWIN1256", "IW8ISO8859P8", "IW8MSWIN1255", "TR8MSWIN1254", "WE8ISO8859P9", "US7ASCII", "UTF8", "WE8ISO8859P1"]

    getInstances: -> @reject (obj) -> obj.get('replicaId') or obj.get('snapshotId')

    getReplicas: -> @filter (obj) -> !!obj.get('replicaId')

    getSnapShots: -> @filter (obj) -> !!obj.get('snapshotId')


    deserialize : ( data, layout_data, resolve ) ->
      model = new Model({

        id     : data.uid
        name   : data.name
        appId  : data.resource.CreatedBy

        instanceId                : data.resource.DBInstanceIdentifier
        snapshotId                : data.resource.DBSnapshotIdentifier
        replicaId                 : data.resource.ReadReplicaSourceDBInstanceIdentifier

        allocatedStorage          : data.resource.AllocatedStorage
        autoMinorVersionUpgrade   : data.resource.AutoMinorVersionUpgrade
        az                        : data.resource.AvailabilityZone
        multiAz                   : data.resource.MultiAZ
        iops                      : data.resource.Iops
        backupRetentionPeriod     : data.resource.BackupRetentionPeriod
        characterSetName          : data.resource.CharacterSetName
        replicas                  : data.resource.ReadReplicaDBInstanceIdentifiers

        dbName                    : data.resource.DBName
        port                      : data.resource.Endpoint?.Port
        address                   : data.resource.Endpoint?.Address
        engine                    : data.resource.Engine
        license                   : data.resource.LicenseModel
        engineVersion             : data.resource.EngineVersion
        instanceClass             : data.resource.DBInstanceClass
        username                  : data.resource.MasterUsername
        password                  : data.resource.MasterUserPassword

        ogName                    : data.resource.OptionGroupMembership?.OptionGroupName
        ogStatus                  : data.resource.OptionGroupMembership?.Status

        pending                   : data.resource.PendingModifiedValues

        backupWindow              : data.resource.PreferredBackupWindow
        maintenanceWindow         : data.resource.PreferredMaintenanceWindow

        accessible                : data.resource.PubliclyAccessible

        pgName                    : data.resource.DBParameterGroups?.DBParameterGroupName


        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]

        parent : resolve( layout_data.groupUId )
      })

      # Asso SG
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sg in data.resource.VpcSecurityGroupIds || []
        new SgAsso( model, resolve( MC.extractID(sg) ) )

  }

  Model
