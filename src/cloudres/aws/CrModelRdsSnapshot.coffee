
define [ "../CrModel", "CloudResources", "ApiRequest" ], ( CrModel, CloudResources, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrRdsSnapshotModel"
    ### env:dev:end ###

    taggable : false

    # defaults :
    #   Port                 : 3306
    #   OptionGroupName      : default:mysql-5-6
    #   Engine               : mysql
    #   Status               : available # creating | available
    #   SnapshotType         : manual
    #   LicenseModel         : general-public-license
    #   EngineVersion        : 5.6.13
    #   DBInstanceIdentifier : my-mysqlexampledb
    #   DBSnapshotIdentifier : my-test-restore-snapshot
    #   SnapshotCreateTime   : 2014-03-28T19:57:16.707Z
    #   AvailabilityZone     : us-west-2b
    #   InstanceCreateTime   : 2014-01-29T22:58:24.231Z
    #   PercentProgress      : 100
    #   AllocatedStorage     : 5
    #   MasterUsername       : awsmyuser

    isComplete  : ()-> @attributes.Status is "available"
    isAutomated : ()-> @attributes.SnapshotType is "automated"

    doCreate : ()->
      self = @
      @sendRequest("rds_snap_CreateDBSnapshot", {
        source_id   : @get("DBInstanceIdentifier")
        snapshot_id   : @get("DBSnapshotIdentifier")
      }).then ( res )->
        try
          res    = res.CreateDBSnapshotResponse.CreateDBSnapshotResult.DBSnapshot
          res.id = res.DBSnapshotIdentifier
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Snapshot created but aws returns invalid data." )

        self.set res

        console.log "Created DbSnapshot resource", self

        self

    set : ( key )->
      if key.PercentProgress
        key.PercentProgress = parseInt( key.PercentProgress, 10 ) || 0

      if key.Status is "creating"
        @startPollingStatus()

      Backbone.Model.prototype.set.apply this, arguments
      return

    startPollingStatus : ()->
      if @__polling then return
      ___pollingStatus = @__pollingStatus.bind @
      @__polling = setTimeout ___pollingStatus, 2000
      return

    stopPollingStatus : ()->
      clearTimeout @__polling
      @__polling = null
      return

    __pollingStatus : ()->
      self = @
      @sendRequest("rds_snap_DescribeDBSnapshots", {snapshot_id : @get("DBSnapshotIdentifier")}).then ( res )->
        self.__polling = null
        self.__parsePolling( res )
        return
      , ( err )->
        if err and err.awsError
          # If we encounter aws error, just ignore it.
          if err.awsError is 404
            self.remove()
          return
        if err and err.error < 0
          self.__polling = null
          self.startPollingStatus()

    __parsePolling : ( res )->
      res = res.DescribeDBSnapshotsResponse.DescribeDBSnapshotsResult.DBSnapshots.DBSnapshot

      @set {
        PercentProgress : res.PercentProgress
        Status : res.Status
      }
      return

    copyTo : ( destRegion, newName, description )->
       self = @
       source_id = "arn:aws:rds:#{@collection.region()}:#{App.user.attributes.account.split('-').join("")}:snapshot:#{@get('id')}"
       @sendRequest("rds_snap_CopyDBSnapshot",{
         region_name     : destRegion
         source_id       : source_id
         target_id       : newName
       }).then ( data )->
         console.log data
         newSnapshot = data.CopyDBSnapshotResponse?.CopyDBSnapshotResult?.DBSnapshot
         if not newSnapshot.DBSnapshotIdentifier
           throw McError( ApiRequest.Errors.InvalidAwsReturn, "Snapshot copied but aws returns invalid data." )

         thatCln = CloudResources( self.collection.type, destRegion )
         clones = newSnapshot
         clones.id = newSnapshot.DBSnapshotIdentifier
         clones.name = newName
         clones.region = destRegion
         model = thatCln.create(clones)
         thatCln.add(model)
         model.tagResource()
         return model

    doDestroy : ()-> @sendRequest("rds_snap_DeleteDBSnapshot", {snapshot_id : @get("id")})
  }
