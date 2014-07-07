
define [ "../ComplexResModel", "Design", "constant", 'i18n!/nls/lang.js', 'CloudResources' ], ( ComplexResModel, Design, constant, lang, CloudResources )->


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
      allocatedStorage: 100
      backupWindow: ''
      maintenanceWindow: ''
      characterSetName: ''
      dbName: ''
      pending: ''
      instanceId: ''
      replicaId: ''
      snapshotId: ''
      adz: ''
      replicas: ''
      ogName: ''
      pgName: ''

    instanceClassList: ["db.t1.micro", "db.m1.small", "db.m1.medium", "db.m1.large", "db.m1.xlarge", "db.m2.xlarge", "db.m2.2xlarge", "db.m2.4xlarge", "db.m3.medium", "db.m3.large", "db.m3.xlarge", "db.m3.2xlarge", "db.r3.large", "db.r3.xlarge", "db.r3.2xlarge", "db.r3.4xlarge", "db.r3.8xlarge"]

    type : constant.RESTYPE.DBINSTANCE
    newNameTmpl : "db-"

    __cachedSpecifications: null

    constructor : ( attr, option ) ->
      ComplexResModel.call( @, attr, option )

    initialize : ( attr, option ) ->

      if attr.sourceDBInstance
        #TODO
        @set 'replicaId', attr.sourceDBInstance.createRef('DBInstanceIdentifier')
        @set 'engine', attr.sourceDBInstance.get("engine")

      if option and option.createByUser

        # Default Sg
        defaultSg = Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg()
        SgAsso = Design.modelClassForType "SgAsso"
        new SgAsso defaultSg, @

        # Default Values
        @set {
          license         : @getDefaultLicense()
          engineVersion   : @getDefaultVersion()
          instanceClass   : @getDefaultInstanceClass()
          port            : @getDefaultPort()
        }

      if attr.snapshotId
        @set 'snapshotId', attr.snapshotId

      # Draw before creating SgAsso
      @draw true

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

    getDefaultLicense: -> @getSpecifications()?[0].license

    getDefaultVersion: -> @getSpecifications()?[0].versions[0].version

    getDefaultInstanceClass: ->
      if not @getSpecifications() then return ''

      consoleDefault = 'db.m3.xlarge'
      instanceClasses = _.pluck @getSpecifications()[0].versions[0].instanceClasses, 'instanceClass'

      if consoleDefault in instanceClasses
        consoleDefault
      else
        _.first(@getSpecifications()).versions[0].instanceClasses[0].instanceClass

    getLVI: (spec) ->
      license = _.find spec, (s) =>
        if s.license is @get 'license'
          s.selected = true
          true

      version = _.find license.versions, (v) =>
        if v.version is @get 'engineVersion'
          v.selected = true
          true

      instanceClass = _.find version.instanceClasses, (i) =>
        if i.instanceClass is @get 'instanceClass'
          i.selected = true
          true

      [spec, license.versions, version.instanceClasses]


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

          vObj.instanceClasses = _.sortBy vObj.instanceClasses, (cla) -> that.instanceClassList.indexOf cla.instanceClass
          lObj.versions.push vObj

        lObj.versions.sort (a, b) -> b.version > a.version
        specArr.push lObj

      @__cachedSpecifications = specArr

      specArr



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
          AvailabilityZone                      : @get 'adz'
          MultiAZ                               : @get 'multiAz'
          Iops                                  : @get 'iops'
          BackupRetentionPeriod                 : @get 'backupRetentionPeriod'
          CharacterSetName                      : @get 'characterSetName'
          DBInstanceClass                       : @get 'instanceClass'
          ReadReplicaDBInstanceIdentifiers      : @get 'replicas'

          DBName                                : @get 'dbName'
          Endpoint:
            Port: @get 'port'
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
