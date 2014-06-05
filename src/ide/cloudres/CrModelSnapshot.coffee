
define [ "./CrModel", "CloudResources", "ApiRequest" ], ( CrModel, CloudResources, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrSnapshotModel"
    ### env:dev:end ###

    defaults :
      volumeId    : ""
      status      : "pending"
      startTime   : ""
      progress    : 0
      ownerId     : ""
      volumeSize  : 1
      description : ""
      name        : ""

    isComplete : ()-> @attributes.status is "completed"
    isPending  : ()-> @attributes.status is "pending"

    doCreate : ()->
      self = @
      ApiRequest("ebs_CreateSnapshot", {
        region_name  : @getCollection().region()
        volume_id    : @get("volumeId")
        description  : @get("description")
      }).then ( res )->
        try
          res          = res.CreateSnapshotResponse
          res.id       = res.snapshotId
          res.progress = res.progress || 0
          delete res.snapshotId
          delete res["@attributes"]
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Snapshot created but aws returns invalid ata." )

        self.set res

        # Ask collection to update the status for this model.
        self.getCollection().startPollingStatus()
        console.log "Created Snapshot resource", self

        self

    set : ( key, value )->
      if key.progress
        key.progress = parseInt( key.progress, 10 ) || 0
      if key.volumeSize
        key.volumeSize = parseInt( key.volumeSize, 10 ) || 1

      Backbone.Model.prototype.set.apply this, arguments
      return

    copyTo : ( destRegion, newName, description )->
      self = @

      ApiRequest("ebs_CopySnapshot",{
        region_name     : @getCollection().region()
        snapshot_id     : @get("id")
        dst_region_name : destRegion
        description     : description
      }).then ( data )->

        id = data.CopySnapshotResponse?.snapshotId
        if not id
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Snapshot copied but aws returns invalid data." )

        thatCln = CloudResources( self.collection.type, destRegion )
        # The model is not saved, because we would w
        clones = self.toJSON()
        clones.name = newName
        clones.description = description
        clones.region = destRegion
        clones.id = id
        model = thatCln.create(clones)
        thatCln.add(model)
        model.tagResource()
        return model

    doDestroy : ()->
      ApiRequest("ebs_DeleteSnapshot", {
        region_name : @getCollection().region()
        snapshot_id : @get("id")
      })

    # Tags this resource. It should only called right after the resource is created.
    tagResource : ()->
      self = @
      ApiRequest("ec2_CreateTags", {
        region_name  : @getCollection().region()
        resource_ids : [@get("id")]
        tags         : [
          {Name:"Created by", Value:App.user.get("username")}
          {Name:"Name",       Value:@get("name")}
        ]
      }).then ()->
        console.log "Success to tag resource", self.get("id")
        return

  }
