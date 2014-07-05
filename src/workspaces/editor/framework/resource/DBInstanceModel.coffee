
define [ "../ComplexResModel", "Design", "constant", 'i18n!/nls/lang.js', 'CloudResources' ], ( ComplexResModel, Design, constant, lang, CloudResources )->

  Model = ComplexResModel.extend {

    defaults : () ->
      x        : 0
      y        : 0
      width    : 9
      height   : 9



    type : constant.RESTYPE.DBINSTANCE
    newNameTmpl : "db-"

    constructor : ( attr, option ) ->
      ComplexResModel.call( @, attr, option )

    initialize : ( attr, option ) ->
      if option and option.createByUser
        # Default Sg
        defaultSg = Design.modelClassForType( constant.RESTYPE.SG ).getDefaultSg()
        SgAsso = Design.modelClassForType "SgAsso"
        new SgAsso defaultSg, @




      if attr.sourceDBInstance
        #TODO
        @set 'replicaId', attr.sourceDBInstance
        @set 'engine', attr.sourceDBInstance.get("engine")

      if attr.snapshotId
        @set 'snapshotId', attr.snapshotId

      @draw true

      null

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
        name : @get("instanceId")
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
          VpcSecurityGroups                     : sgArray


      { component : component, layout : @generateLayout() }


  }, {

    handleTypes: constant.RESTYPE.DBINSTANCE

    getInstances: -> @reject (obj) -> obj.get('replicaId') or obj.get('snapshotId')

    getReplicas: -> @filter (obj) -> !!obj.get('replicaId')

    getSnapShots: -> @filter (obj) -> !!obj.get('snapshotId')


    deserialize : ( data, layout_data, resolve ) ->
      model = new Model({

        id     : data.uid
        name   : data.resource.DBInstanceIdentifier
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
