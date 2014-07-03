
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


    initialize : ( attr, option )->
      @draw true

      null




    serialize : ()->
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

          DBSubnetGroupName                     : @parent.get 'name'


      { component : component, layout : @generateLayout() }


  }, {

    handleTypes: constant.RESTYPE.DBINSTANCE

    deserialize : ( data, layout_data, resolve )->
      new Model({

        id     : data.uid
        name   : data.name
        appId  : data.CreatedBy

        instanceId                : data.DBInstanceIdentifier
        snapshotId                : data.DBSnapshotIdentifier
        replicaId                 : data.ReadReplicaSourceDBInstanceIdentifier

        allocatedStorage          : data.AllocatedStorage
        autoMinorVersionUpgrade   : data.AutoMinorVersionUpgrade
        az                        : data.AvailabilityZone
        multiAz                   : data.MultiAZ
        iops                      : data.Iops
        backupRetentionPeriod     : data.BackupRetentionPeriod
        characterSetName          : data.CharacterSetName
        instanceClass             : data.DBInstanceClass
        replicas                  : data.ReadReplicaDBInstanceIdentifiers

        dbName                    : data.DBName
        port                      : data.Endpoint?.Port
        engine                    : data.Engine
        engineVersion             : data.EngineVersion
        license                   : data.LicenseModel
        username                  : data.MasterUsername
        password                  : data.MasterUserPassword

        ogName                    : data.OptionGroupMembership?.OptionGroupName
        ogStatus                  : data.OptionGroupMembership?.Status

        pending                   : data.PendingModifiedValues

        preferredBackupWindow     : data.PreferredBackupWindow
        preferredMaintenanceWindow: data.PreferredMaintenanceWindow

        accessible                : data.PubliclyAccessible

        pgName                    : data.DBParameterGroups?.DBParameterGroupName


        x      : layout_data.coordinate[0]
        y      : layout_data.coordinate[1]

        parent : resolve( layout_data.groupUId )
      })
  }

  Model
