
define [ "./CrModel", "CloudResources", "ApiRequest" ], ( CrModel, CloudResources, ApiRequest )->

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
      ApiRequest("rds_snap_CreateDBSnapshot", {
        region_name : @getCollection().region()
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
      ApiRequest("rds_snap_DescribeDBSnapshots", {
        region_name : @getCollection().region()
        snapshot_id : @get("DBSnapshotIdentifier")
      }).then ( res )->
        self.__polling = null
        self.__parsePolling( res )
        return
      , ()->
        self.__polling = null
        self.startPollingStatus()

    __parsePolling : ( res )->
      res = res.DescribeDBSnapshotsResponse.DescribeDBSnapshotsResult.DBSnapshots.DBSnapshot

      @set {
        PercentProgress : res.PercentProgress
        Status : res.Status
      }
      return

    # copyTo : ( destRegion, newName, description )->
    #   self = @

    #   ApiRequest("ebs_CopySnapshot",{
    #     region_name     : @getCollection().region()
    #     snapshot_id     : @get("id")
    #     dst_region_name : destRegion
    #     description     : description
    #   }).then ( data )->

    #     id = data.CopySnapshotResponse?.snapshotId
    #     if not id
    #       throw McError( ApiRequest.Errors.InvalidAwsReturn, "Snapshot copied but aws returns invalid data." )

    #     thatCln = CloudResources( self.collection.type, destRegion )
    #     # The model is not saved, because we would w
    #     clones = self.toJSON()
    #     clones.name = newName
    #     clones.description = description
    #     clones.region = destRegion
    #     clones.id = id
    #     model = thatCln.create(clones)
    #     thatCln.add(model)
    #     model.tagResource()
    #     return model

    doDestroy : ()->
      ApiRequest("rds_snap_DeleteDBSnapshot", {
        region_name : @getCollection().region()
        snapshot_id : @get("id")
      })
  }
