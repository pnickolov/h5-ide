
define [
  '../ComplexResModel'
  '../ConnectionModel'
  './DBOgModel'
  'Design'
  'constant'
  'i18n!/nls/lang.js'
  'CloudResources'

], ( ComplexResModel, ConnectionModel, DBOgModel, Design, constant, lang, CloudResources )->

  EnginTypeMap = {
    'oracle-ee'     : "oracle"
    'oracle-se'     : "oracle"
    'oracle-se1'    : "oracle"
    'sqlserver-ee'  : "sqlserver"
    'sqlserver-ex'  : "sqlserver"
    'sqlserver-se'  : "sqlserver"
    'sqlserver-web' : "sqlserver"
  }

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

  OgUsage = ConnectionModel.extend {
    type : "OgUsage"
    oneToMany: constant.RESTYPE.DBOG
  }

  Model = ComplexResModel.extend {

    defaults :
      newInstanceId : ''
      instanceId    : ''
      snapshotId    : ''

      createdBy : ""
      accessible: false
      username: 'root'
      password: '12345678'
      multiAz: true
      iops: ''
      autoMinorVersionUpgrade: true
      allowMajorVersionUpgrade: ''
      backupRetentionPeriod: 1
      allocatedStorage: 10
      backupWindow: ''
      maintenanceWindow: ''
      characterSetName: ''
      dbName: ''
      port: ''
      pending: ''
      az: ''
      ogName: ''
      pgName: ''
      applyImmediately: false


    type : constant.RESTYPE.DBINSTANCE
    newNameTmpl : "db"

    __cachedSpecifications: null

    slaves: -> if @master() then [] else @connectionTargets("DbReplication")
    master: ->
      m = @connections("DbReplication")[0]
      if m and m.master() isnt @
        return m.master()
      null

    setMaster : ( master ) ->
      @connections("DbReplication")[0]?.remove()
      Replication = Design.modelClassForType("DbReplication")
      new Replication( master, @ )
      return

    # Source of Snapshot Instance
    source: -> CloudResources(constant.RESTYPE.DBSNAP, @design().region()).get( @get('snapshotId') )

    connect : ( cnn )->
      if @master() then return
      if cnn.type isnt "SgAsso" then return

      # Update slaves' SgAsso
      SgAsso = Design.modelClassForType("SgAsso")
      sg = cnn.getOtherTarget( @ )

      new SgAsso( slave, sg ) for slave in @slaves()
      return

    disconnect : ( cnn )->
      if @master() then return
      if cnn.type isnt "SgAsso" then return
      sg = cnn.getOtherTarget( @ )

      for slave in @slaves()
        for asso in slave.connections("SgAsso")
          if asso.getOtherTarget( slave ) is sg
            asso.remove()
            break
      return

    initialize : ( attr, option ) ->
      option = option || {}

      if option.cloneSource
        @clone( option.cloneSource )
        return

      if option.master
        @setMaster( option.master )
        @clone( option.master )

      else if option.createByUser
        # Default Sg
        SgAsso = Design.modelClassForType "SgAsso"
        defaultSg = Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg()
        new SgAsso defaultSg, @

        # Default Values
        @set {
          license         : @getDefaultLicense()
          engineVersion   : @getDefaultVersion()
          instanceClass   : @getDefaultInstanceClass()
          port            : @getDefaultPort()
          dbName          : @getDefaultDBName()
          characterSetName: @getDefaultCharSet()
          allocatedStorage: attr.allocatedStorage || @getDefaultAllocatedStorage()
          snapshotId      : attr.snapshotId || ""
        }

        #set default optiongroup and parametergroup
        @setDefaultOptionGroup()
        @setDefaultParameterGroup()
      return

    clone : ( srcTarget )->
      @cloneAttributes srcTarget, {
        reserve : "newInstanceId|instanceId"
        copyConnection : [ "SgAsso", "OgUsage" ]
      }
      return

    isMysql      : -> @engineType() is 'mysql'
    isOracle     : -> @engineType() is 'oracle'
    isSqlserver  : -> @engineType() is 'sqlserver'
    isPostgresql : -> @engineType() is 'postgresql'
    engineType: ->
      engine = @get('engine')
      EnginTypeMap[ engine ] || engine

    setDefaultOptionGroup: ( origEngineVersion ) ->
      # set default option group
      regionName  = Design.instance().region()
      engineCol   = CloudResources(constant.RESTYPE.DBENGINE, regionName)
      defaultInfo = engineCol.getDefaultByNameVersion regionName, @get('engine'), @get('engineVersion')
      if origEngineVersion
        origDefaultInfo = engineCol.getDefaultByNameVersion regionName, @get('engine'), origEngineVersion

      if origDefaultInfo and origDefaultInfo.family and defaultInfo and defaultInfo.family
        if origDefaultInfo.family is defaultInfo.family
          #family no changed, then no need change OptionGroup
          return null

      if defaultInfo and defaultInfo.defaultOGName
        defaultOG = defaultInfo.defaultOGName
      else
        defaultOG = "default:" + @get('engine') + "-" + @getMajorVersion().replace(".","-")
        console.warn "can not get default optiongroup for #{@get 'engine'} #{@getMajorVersion()}"

      new OgUsage @, @getDefaultOgInstance defaultOG
      null

    getDefaultOgInstance: ( name ) ->
      DBOgModel.findWhere( name: name, default: true ) or new DBOgModel name: name, default: true

    setDefaultParameterGroup:( origEngineVersion ) ->
      #set default parameter group
      regionName = Design.instance().region()
      engineCol = CloudResources(constant.RESTYPE.DBENGINE, regionName)
      defaultInfo = engineCol.getDefaultByNameVersion regionName, @get('engine'), @get('engineVersion')
      if origEngineVersion
        origDefaultInfo = engineCol.getDefaultByNameVersion regionName, @get('engine'), origEngineVersion

      if origDefaultInfo and origDefaultInfo.family and defaultInfo and defaultInfo.family
        if origDefaultInfo.family is defaultInfo.family
          #family no changed, then no need change parametergroup
          return null

      if defaultInfo and defaultInfo.defaultPGName
        defaultPG = defaultInfo.defaultPGName
      else
        defaultPG = "default." + @get('engine') + @getMajorVersion()
        console.warn "can not get default parametergroup for #{ @get 'engine' } #{ @getMajorVersion() }"
      @set 'pgName', defaultPG || ""
      null

    setIops: ( iops ) -> @set('iops', iops)
    getIops: () -> @get('iops')

    defaultMap:
      'mysql'         :
        port            : 3306
        dbname          : ''
        charset         : ''
        allocatedStorage: 5
      'postgres'      :
        port            : 5432
        dbname          : ''
        charset         : ''
        allocatedStorage: 5
      'oracle-ee'     :
        port            : 1521
        dbname          : 'ORCL'
        charset         : 'AL32UTF8'
        allocatedStorage: 10
      'oracle-se'     :
        port            : 1521
        dbname          : 'ORCL'
        charset         : 'AL32UTF8'
        allocatedStorage: 10
      'oracle-se1'    :
        port            : 1521
        dbname          : 'ORCL'
        charset         : 'AL32UTF8'
        allocatedStorage: 10
      'sqlserver-ee'  :
        port            : 1433
        dbname          : ''
        charset         : ''
        allocatedStorage: 200
      'sqlserver-ex'  :
        port            : 1433
        dbname          : ''
        charset         : ''
        allocatedStorage: 30
      'sqlserver-se'  :
        port            : 1433
        dbname          : ''
        charset         : ''
        allocatedStorage: 200
      'sqlserver-web' :
        port            : 1433
        dbname          : ''
        charset         : ''
        allocatedStorage: 30

    #override ResourceModel.getNewName()
    getNewName : ()->
      args = [].slice.call arguments, 0
      args[0] = Model.getInstances().length
      ComplexResModel.prototype.getNewName.apply this, args

    #override ResourceModel.isRemovable()
    isRemovable :()->
      if @slaves().length > 0
        # Return a warning, delete DBInstance will remove ReadReplica together
        return sprintf lang.ide.CVS_CFM_DEL_DBINSTANCE, @get("name")
      true

    #override ResourceModel.remove()
    remove :()->
      #remove readReplica related to current DBInstance
      slave.remove() for slave in @slaves()

      #remove current node
      ComplexResModel.prototype.remove.call(this)
      null

    getRdsInstances: -> App.model.getRdsData(@design().region())?.instance[@get 'engine']

    getDefaultPort: ->
      @defaultMap[@get('engine')].port

    getDefaultDBName: ->
      @defaultMap[@get('engine')].dbname

    getDefaultCharSet: ->
      @defaultMap[@get('engine')].charset

    getDefaultAllocatedStorage: ->
      @defaultMap[@get('engine')].allocatedStorage

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

    getMajorVersion: -> @get('engineVersion')?.split('.').slice(0,2).join('.')

    getMinorVersion: -> @get('engineVersion')?.split('.').slice(2).join('.')

    # Get and Process License, EngineVersion, InstanceClass and multiAZ
    getLVIA: (spec) ->
      if not spec then return []

      currentLicense = @get 'license'
      currentVersion = @get 'engineVersion'
      currentClass   = @get 'instanceClass'

      # spec[1] = license: 'test', versions: [ { version: '0.0.1', instanceClasses: [{instanceClass:'test', multiAZCapable: false}]} ]

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

      [spec, license.versions, version.instanceClasses, instanceClass.multiAZCapable, instanceClass.availabilityZones]


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
        spec[i.LicenseModel][i.EngineVersion][i.DBInstanceClass] = {
          multiAZCapable: i.MultiAZCapable,
          availabilityZones: i.AvailabilityZones
        }

      for license, versions of spec
        lObj = license: license, versions: []
        for version, classes of versions
          vObj = version: version, instanceClasses: []
          for cla, az of classes
            vObj.instanceClasses.push instanceClass: cla, multiAZCapable: az.multiAZCapable, availabilityZones: az.availabilityZones

          vObj.instanceClasses = _.sortBy vObj.instanceClasses, (cla) -> Model.instanceClassList.indexOf cla.instanceClass
          lObj.versions.push vObj

        lObj.versions.sort (a, b) -> versionCompare b.version, a.version
        specArr.push lObj

      @__cachedSpecifications = specArr

      specArr

    getCost : ( priceMap, currency )->
      if not priceMap.database then return null

      engine = @engineType()

      if engine is 'sqlserver' then sufix = engine.split('-')[1]

      dbInstanceType = @attributes.instanceClass.split('.')
      deploy = if @attributes.multiAZ then 'multiAZ' else 'standard'

      if not engine or not deploy then return null

      unit = priceMap.database.rds.unit
      try
        fee = priceMap.database.rds[ engine ][ dbInstanceType[0] ][ dbInstanceType[1] ][ dbInstanceType[2] ]

        license = null
        if @attributes.license is 'license-included'
          license = 'li'
        else if @attributes.license is 'bring-your-own-license'
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
            resource    : @attributes.name
            type        : @attributes.instanceClass
            fee         : fee
            formatedFee : formatedFee

        return priceObj

      catch err
        # console.error "Error while get database instance price", err
      finally

    category: (type) ->
      switch type
        when 'instance' then return !(@get('snapshotId') or @master())
        when 'replica' then return !!@master()
        when 'snapshot' then return !!@get('snapshotId')

      if @get 'snapshotId' then return 'snapshot'

      if @master() then 'replica' else 'instance'

    getSnapshotModel: () ->

      if @category() is 'snapshot'
        regionName = Design.instance().region()
        snapshotCol = CloudResources(constant.RESTYPE.DBSNAP, regionName)
        snapshotModel = snapshotCol.findWhere({id: @get('snapshotId')})
        return snapshotModel
      else
        return null

    autobackup: ( value )->
      if value isnt undefined
        @set 'backupRetentionPeriod', value
        return

      return @get('backupRetentionPeriod') || 0

    setOptionGroup: ( name ) ->
      ogComp = DBOgModel.findWhere(name: name) or new DBOgModel(name: name, default: true)

      new OgUsage @, ogComp

    getOptionGroup: -> @connectionTargets('OgUsage')[0]

    getOptionGroupName: -> @getOptionGroup()?.get 'name'

    serialize : () ->

      master = @master()

      if master and not @get("appId")
        # If this is a newly created replica, we would get the component from its master
        component = master.serialize().component
        component.name = @get("name")
        component.uid  = @id
        $.extend component.resource, {
          DBInstanceClass         : @get("instanceClass")
          AutoMinorVersionUpgrade : @get("autoMinorVersionUpgrade")
          PubliclyAccessible      : @get("accessible")
          BackupRetentionPeriod   : 0
          MultiAZ                 : false
        }
      else
        component =
          name : @get("name")
          type : @type
          uid  : @id
          resource :
            CreatedBy                             : @get 'createdBy'
            DBInstanceIdentifier                  : @get 'instanceId'
            NewDBInstanceIdentifier               : @get 'newInstanceId'
            DBSnapshotIdentifier                  : @get 'snapshotId'
            ReadReplicaSourceDBInstanceIdentifier : @master()?.createRef('DBInstanceIdentifier') or ''

            AllocatedStorage                      : @get 'allocatedStorage'
            AutoMinorVersionUpgrade               : @get 'autoMinorVersionUpgrade'
            AllowMajorVersionUpgrade              : @get 'allowMajorVersionUpgrade'
            AvailabilityZone                      : @get 'az'
            MultiAZ                               : @get 'multiAz'
            Iops                                  : @getIops()
            BackupRetentionPeriod                 : @get 'backupRetentionPeriod'
            CharacterSetName                      : @get 'characterSetName'
            DBInstanceClass                       : @get 'instanceClass'

            DBName                                : @get 'dbName'
            Endpoint:
              Port   : @get 'port'
            Engine                                : @get 'engine'
            EngineVersion                         : @get 'engineVersion'
            LicenseModel                          : @get 'license'
            MasterUsername                        : @get 'username'
            MasterUserPassword                    : @get 'password'

            OptionGroupMembership:
              OptionGroupName: @connectionTargets( 'OgUsage' )[ 0 ]?.createRef 'OptionGroupName' || ""

            DBParameterGroups:
              DBParameterGroupName                : @get 'pgName'
            ApplyImmediately                      : @get 'applyImmediately'

            PendingModifiedValues                 : @get 'pending'

            PreferredBackupWindow                 : @get 'backupWindow'
            PreferredMaintenanceWindow            : @get 'maintenanceWindow'

            PubliclyAccessible                    : @get 'accessible'

            DBSubnetGroup:
              DBSubnetGroupName                   : @parent().createRef 'DBSubnetGroupName'
            VpcSecurityGroupIds                   : _.map @connectionTargets( "SgAsso" ), ( sg )-> sg.createRef 'GroupId'

      { component : component, layout : @generateLayout() }


  }, {

    handleTypes: constant.RESTYPE.DBINSTANCE

    instanceClassList: ["db.t1.micro", "db.m1.small", "db.m1.medium", "db.m1.large", "db.m1.xlarge", "db.m2.xlarge", "db.m2.2xlarge", "db.m2.4xlarge", "db.cr1.8xlarge", "db.m3.medium", "db.m3.large", "db.m3.xlarge", "db.m3.2xlarge", "db.r3.large", "db.r3.xlarge", "db.r3.2xlarge", "db.r3.4xlarge", "db.r3.8xlarge"]

    oracleCharset: ["AL32UTF8", "JA16EUC", "JA16EUCTILDE", "JA16SJIS", "JA16SJISTILDE", "KO16MSWIN949", "TH8TISASCII", "VN8MSWIN1258", "ZHS16GBK", "ZHT16HKSCS", "ZHT16MSWIN950", "ZHT32EUC", "BLT8ISO8859P13", "BLT8MSWIN1257", "CL8ISO8859P5", "CL8MSWIN1251", "EE8ISO8859P2", "EL8ISO8859P7", "EL8MSWIN1253", "EE8MSWIN1250", "NE8ISO8859P10", "NEE8ISO8859P4", "WE8ISO8859P15", "WE8MSWIN1252", "AR8ISO8859P6", "AR8MSWIN1256", "IW8ISO8859P8", "IW8MSWIN1255", "TR8MSWIN1254", "WE8ISO8859P9", "US7ASCII", "UTF8", "WE8ISO8859P1"]

    getInstances: -> @reject (obj) -> obj.master() or obj.get('snapshotId')

    getReplicas: -> @filter (obj) -> !!obj.master()

    getSnapShots: -> @filter (obj) -> !!obj.get('snapshotId')

    getDefaultOgInstance: ( name ) ->
      DBOgModel.findWhere( name: name, default: true ) or new DBOgModel name: name, default: true

    deserialize : ( data, layout_data, resolve ) ->
      that = @
      model = new Model({

        id     : data.uid
        name   : data.name
        createdBy  : data.resource.CreatedBy

        appId                     : data.resource.DBInstanceIdentifier
        instanceId                : data.resource.DBInstanceIdentifier
        newInstanceId             : data.resource.NewDBInstanceIdentifier
        snapshotId                : data.resource.DBSnapshotIdentifier

        allocatedStorage          : data.resource.AllocatedStorage
        autoMinorVersionUpgrade   : data.resource.AutoMinorVersionUpgrade
        allowMajorVersionUpgrade  : data.resource.AllowMajorVersionUpgrade
        az                        : data.resource.AvailabilityZone
        multiAz                   : data.resource.MultiAZ
        iops                      : data.resource.Iops
        backupRetentionPeriod     : data.resource.BackupRetentionPeriod
        characterSetName          : data.resource.CharacterSetName

        dbName                    : data.resource.DBName
        port                      : data.resource.Endpoint?.Port
        engine                    : data.resource.Engine
        license                   : data.resource.LicenseModel
        engineVersion             : data.resource.EngineVersion
        instanceClass             : data.resource.DBInstanceClass
        username                  : data.resource.MasterUsername
        password                  : data.resource.MasterUserPassword

        pending                   : data.resource.PendingModifiedValues

        backupWindow              : data.resource.PreferredBackupWindow
        maintenanceWindow         : data.resource.PreferredMaintenanceWindow

        accessible                : data.resource.PubliclyAccessible

        pgName                    : data.resource.DBParameterGroups?.DBParameterGroupName
        applyImmediately          : data.resource.ApplyImmediately


        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]

        parent : resolve( layout_data.groupUId )
      })

      # Set master if model is replica
      if data.resource.ReadReplicaSourceDBInstanceIdentifier
        model.setMaster resolve MC.extractID data.resource.ReadReplicaSourceDBInstanceIdentifier

      # Asso SG
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sg in data.resource.VpcSecurityGroupIds || []
        new SgAsso( model, resolve( MC.extractID(sg) ) )

      # Asso OptionGroup
      ogName = data.resource.OptionGroupMembership?.OptionGroupName
      if ogName
        ogComp = resolve MC.extractID ogName

        new OgUsage( model, ogComp or model.getDefaultOgInstance(ogName) )
  }

  Model
