
define [ "../ComplexResModel", "Design", "constant", 'i18n!/nls/lang.js', 'CloudResources' ], ( ComplexResModel, Design, constant, lang, CloudResources )->

  Model = ComplexResModel.extend {

    defaults : () ->
      x        : 0
      y        : 0
      width    : 9
      height   : 9



    type : constant.RESTYPE.DBINSTANCE
    newNameTmpl : "db-instance-"

    constructor : ( attr, option ) ->
      ComplexResModel.call( this, attr, option )


    initialize : ( attr, option ) ->
      @draw true

      null

    category: (type) ->
      if type then return !!@get("#{type}Id")
      if @get 'instanceId' then return 'instance'
      if @get 'snapshotId' then return 'snapshot'
      if @get 'replicaId' then return 'replica'

    serialize : () ->
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
          EngineVersion                         : @get 'engineVersion'
          LicenseModel                          : @get 'license'
          MasterUsername                        : @get 'username'
          MasterUserPassword                    : @get 'password'

          OptionGroupMembership:
            OptionGroupName: @get 'ogName'
            Status: @get 'ogStatus'

          DBParameterGroups:
            DBParameterGroupName: @get 'pgName'

          PendingModifiedValues                 : @get 'pending'

          PreferredBackupWindow                 : @get 'preferredBackupWindow'
          PreferredMaintenanceWindow            : @get 'preferredMaintenanceWindow'

          PubliclyAccessible                    : @get 'accessible'

          DBSubnetGroupName                     : @parent().get 'name'


      { component : component, layout : @generateLayout() }


  }, {

    handleTypes: constant.RESTYPE.DBINSTANCE

    deserialize : ( data, layout_data, resolve ) ->
      new Model({

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
        instanceClass             : data.resource.DBInstanceClass
        replicas                  : data.resource.ReadReplicaDBInstanceIdentifiers

        dbName                    : data.resource.DBName
        port                      : data.resource.Endpoint?.Port
        engine                    : data.resource.Engine
        engineVersion             : data.resource.EngineVersion
        license                   : data.resource.LicenseModel
        username                  : data.resource.MasterUsername
        password                  : data.resource.MasterUserPassword

        ogName                    : data.resource.OptionGroupMembership?.OptionGroupName
        ogStatus                  : data.resource.OptionGroupMembership?.Status

        pending                   : data.resource.PendingModifiedValues

        preferredBackupWindow     : data.resource.PreferredBackupWindow
        preferredMaintenanceWindow: data.resource.PreferredMaintenanceWindow

        accessible                : data.resource.PubliclyAccessible

        pgName                    : data.resource.DBParameterGroups?.DBParameterGroupName


        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]

        parent : resolve( layout_data.groupUId )
      })

      # Asso SG
      SgAsso = Design.modelClassForType( "SgAsso" )
      for sg in data.resource.VpcSecurityGroups || []
        new SgAsso( model, resolve( MC.extractID(sg) ) )


  }

  Model
