
define [
  '../ComplexResModel'
  '../ConnectionModel'
  'Design'
  'constant'
  'i18n!/nls/lang.js'
  'CloudResources'

], ( ComplexResModel, ConnectionModel, Design, constant, lang, CloudResources )->

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

    defaults : () ->
      x        : 0
      y        : 0
      width    : 9
      height   : 9

      newInstanceId: ''

      createdBy : ""
      accessible: false
      username: 'root'
      password: '12345678'
      multiAz: true
      iops: ''
      autoMinorVersionUpgrade: true
      allowMajorVersionUpgrade: ''
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
      ogName: ''
      pgName: ''
      applyImmediately: ''


    type : constant.RESTYPE.DBINSTANCE
    newNameTmpl : "db"
    newReplicaNameTmpl : "replica"

    __cachedSpecifications: null

    constructor : ( attr, option ) ->

      ComplexResModel.call( @, attr, option )

    initialize : ( attr, option ) ->

      if option and option.cloneSource
        #Create ReadReplica
        @set 'engine',    option.cloneSource.get('engine') # for draw
        @set 'replicaId', option.cloneSource.createRef('DBInstanceIdentifier') # for draw
        # Draw before clone
        @draw true
        @clone( option.cloneSource )

      else if option and option.createByUser
        #Create new DBInstance
        # Draw before creating SgAsso
        @draw true
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
        }

        if attr.snapshotId
          #Create new DBInstance from snapshot
          @set 'snapshotId', attr.snapshotId

        #set default optiongroup and parametergroup
        @setDefaultOptionGroup()
        @setDefaultParameterGroup()


      if @category() is 'instance'
        @on 'all', @preSerialize
        @on 'sgchange', @onSgChange
      null

    setDefaultOptionGroup: () ->
      # set default option group
      that = this
      ogCol = CloudResources(constant.RESTYPE.DBOG, Design.instance().region())
      defaultOGAry = []
      ogCol.each (model, idx) ->
          if model.get('EngineName') is that.get('engine') and
              model.get('MajorEngineVersion') is that.getMajorVersion() and
                  model.get('OptionGroupName').indexOf('default:') is 0
                      defaultOGAry.push(model.get('OptionGroupName'))
      if defaultOGAry.length > 0 and defaultOGAry[0]
        defaultOG = defaultOGAry[0]
      else
        defaultOG = "default:" + @get('engine') + "-" + @getMajorVersion().replace(".","-")
        console.warn "can not get default optiongroup for #{@get 'engine'} #{@getMajorVersion()}"
      @set('ogName', defaultOG )
      null

    setDefaultParameterGroup:() ->
      pgData = App.model.getRdsData(@design().region())?.defaultInfo
      if pgData
        engine = pgData[ @get 'engine' ]
        if engine
          defaultPG = pgData[ @get 'engine' ][ @get 'engineVersion' ]

      if defaultPG and defaultPG.parameterGroup
        defaultPG = defaultPG.parameterGroup
      else
        defaultPG = "default." + @get('engine') + @getMajorVersion()
        console.warn "can not get default parametergroup for #{ @get 'engine' } #{ @getMajorVersion() }"
      @set 'pgName', defaultPG || ""
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

    #override ResourceModel.getNewName()
    getNewName : ( attr )->
      base  = 0
      exist = true
      if attr and attr.sourceId
        #Create ReadReplica
        srcComp = Design.instance().component(attr.sourceId)
        if not srcComp
          console.error "can not found component for " + attr.sourceId
          return ""
        srcName = srcComp.get("name")
        repinsAry = Model.getReplicasOfInstance( srcComp )
        while exist
          exist = false
          for repins in repinsAry
            if repins.get("name") is srcName + "-" + @newReplicaNameTmpl + base
              base++
              exist = true
              break
        newName = srcName + "-" + @newReplicaNameTmpl + base
      else
        #Create new DBInstance or from snapshot
        dbinsAry = Model.getInstances()
        while exist
          exist = false
          for dbins in dbinsAry
            if dbins.get("name") is (@newNameTmpl + base)
              base++
              exist = true
              break
        newName = @newNameTmpl + base
      newName

    clone :( srcTarget )->
      @cloneAttributes srcTarget, {
        reserve : "replicaId"
        copyConnection : [ "SgAsso" ]
      }
      null

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
        # console.error "Error while get database instance price", err
      finally

    category: (type) ->
      if type is 'instance'
        return !(@get('snapshotId') or @get('replicaId'))
      else if type
        return !!@get("#{type}Id")

      if @get 'snapshotId' then return 'snapshot'
      if @get 'replicaId' then return 'replica'

      return 'instance'

    autobackup: ( value )->
      if value isnt undefined
        #setter : show/hide dragger by this property
        @set 'backupRetentionPeriod', value
        @draw()
        null
      else
        #getter
        return @get('backupRetentionPeriod') || 0

    # trigger by assignSG or un-assignSG in model of sglist property panel
    onSgChange : (event) ->
      if @category() is 'instance'
        for replica in Model.getReplicasOfInstance @
          if not replica.get('appId')
            #force clear all connections
            num = replica.attributes.__connections.length
            while num > 0
              conn = replica.attributes.__connections.pop()
              conn.remove( {force:true} ) #no need assign defaultSg
              num--
            if replica.attributes.__connections.length isnt 0
              console.error "force clear all SgAsso of DBInstance #{replica.id} failed"
            replica.clone @
      null

    setOptionGroup: ( name ) ->
      ogComp = Design.modelClassForType(constant.RESTYPE.DBOG).findWhere name: name

      if ogComp
        new OgUsage @, ogComp
        @unset 'ogName'
      else
        @set 'ogName', name
        _.invoke @connections('OgUsage'), 'remove'

    getOptionGroupName: -> @get( 'ogName' ) or @connectionTargets('OgUsage')[0]?.get 'name'

    preSerialize : ( event ) ->
      if event and $.type(event) is 'string'
        event = event.split(":")[0]

      #event is undefined => DesignImpl.prototype.serialize()
      #event is 'change'  => change attr from property panel
      if event is undefined or event is 'change'
        #clone to new readReplica(not include existed readReplica)
        if @category() is 'instance'
          for replica in Model.getReplicasOfInstance @
            if not replica.get('appId')
              replica.clone @
      null

    serialize : () ->
      sgArray = _.map @connectionTargets( "SgAsso" ), ( sg )-> sg.createRef 'GroupId'

      ogName = @connectionTargets( 'OgUsage' )[ 0 ]?.createRef 'OptionGroupName'
      if not ogName then ogName = @get( 'ogName' )

      pgName = @get 'pgName'

      component =
        name : @get("name")
        type : @type
        uid  : @id
        resource :
          CreatedBy                             : @get 'createdBy'
          DBInstanceIdentifier                  : @get 'instanceId'
          NewDBInstanceIdentifier               : @get 'newInstanceId'
          DBSnapshotIdentifier                  : @get 'snapshotId'
          ReadReplicaSourceDBInstanceIdentifier : @get 'replicaId'

          AllocatedStorage                      : @get 'allocatedStorage'
          AutoMinorVersionUpgrade               : @get 'autoMinorVersionUpgrade'
          AllowMajorVersionUpgrade              : @get 'allowMajorVersionUpgrade'
          AvailabilityZone                      : @get 'az'
          MultiAZ                               : @get 'multiAz'
          Iops                                  : @get 'iops'
          BackupRetentionPeriod                 : @get 'backupRetentionPeriod'
          CharacterSetName                      : @get 'characterSetName'
          DBInstanceClass                       : @get 'instanceClass'

          DBName                                : @get 'dbName'
          Endpoint:
            Port   : @get 'port'
            Address: @get 'address'
          Engine                                : @get 'engine'
          EngineVersion                         : @get 'engineVersion'
          LicenseModel                          : @get 'license'
          MasterUsername                        : @get 'username'
          MasterUserPassword                    : @get 'password'

          OptionGroupMembership:
            OptionGroupName: ogName

          DBParameterGroups:
            DBParameterGroupName                : pgName
          ApplyImmediately                      : @get 'applyImmediately'

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

    getReplicasOfInstance: ( instance ) -> @filter (obj) -> obj.get('replicaId') is instance.createRef('DBInstanceIdentifier')

    getInstanceOfReplica : ( instance  ) -> @filter (obj) -> obj.createRef('DBInstanceIdentifier') is instance.get('replicaId')

    deserialize : ( data, layout_data, resolve ) ->
      model = new Model({

        id     : data.uid
        name   : data.name
        createdBy  : data.resource.CreatedBy

        appId                     : data.resource.DBInstanceIdentifier
        instanceId                : data.resource.DBInstanceIdentifier
        newInstanceId             : data.resource.NewDBInstanceIdentifier
        snapshotId                : data.resource.DBSnapshotIdentifier
        replicaId                 : data.resource.ReadReplicaSourceDBInstanceIdentifier

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
        address                   : data.resource.Endpoint?.Address
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

      # Asso SG
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sg in data.resource.VpcSecurityGroupIds || []
        new SgAsso( model, resolve( MC.extractID(sg) ) )

      # Asso OptionGroup
      ogName = data.resource.OptionGroupMembership?.OptionGroupName
      if ogName
        ogComp = resolve MC.extractID ogName

        if ogComp then new OgUsage( model, ogComp )
        else model.set 'ogName', ogName


  }

  Model
