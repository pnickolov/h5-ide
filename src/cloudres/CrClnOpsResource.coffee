
define ["ApiRequest", "./CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

  ### This Connection is used to fetch all the resource of an vpc ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrOpsCollection"
    ### env:dev:end ###

    type  : "OpsResource"

    init : ( region )-> @__region = region; @

    # Fetches
    fetchForceDedup : ()->
      @__forceDedup = false
      p = @fetchForce()
      @__forceDedup = true
      p

    fetchForce : ()->
      if @__forceDedup
        @__forceDedup = false
        d = Q.defer()
        d.resolve()
        d.promise

      @generatedJson = null
      CrCollection.prototype.fetchForce.call this

    doFetch : ()->
      # Before we do the fetch, we would want to clear everything in the CloudResources cache.
      self = @
      CloudResources.clearWhere ((m)-> m.RES_TAG is self.category), @__region

      console.assert( @__region, "CrOpsCollection's region is not set before fetching data. Need to call init() first" )
      ApiRequest("resource_vpc_resource", {
        region_name : @__region
        vpc_id      : @category
      })

    parseFetchData : ( data )->
      # OpsResource doesn't return anything, Instead, it injects the data to other collection.
      delete data.vpc

      @generatedJson = data.app_json
      delete data.app_json

      console.log "Generated Json from backend:", $.extend true, {}, @generatedJson

      # Parse aws resource data with other collection
      extraAttr = { RES_TAG : @category }
      for type, d of data
        cln = CloudResources( type, @__region )
        if not cln
          console.warn "Cannot find cloud resource collection for type:", type
          continue
        cln.__parseExternalData d, extraAttr, @__region

      topicMap       = {} # id=>comp
      topicCompAry   = []
      asgCompAry     = []

      RESTYPE = constant.RESTYPE

      # Fix invalid json
      region = @__region
      for uid, comp of @generatedJson.component
        switch comp.type
          when RESTYPE.AZ
            comp.name = comp.resource.ZoneName
          when RESTYPE.ACL
            acl = CloudResources( comp.type, region ).get( comp.resource.NetworkAclId )
            if acl then comp.resource.Default = acl.get("default")
          when RESTYPE.SG
            sg = CloudResources( comp.type, region ).get( comp.resource.GroupId )
            if sg then comp.resource.GroupName = sg.get("groupName")
          when RESTYPE.DBOG
            comp.name = comp.resource.OptionGroupName
          when RESTYPE.ASG
            asgCompAry.push comp
          when RESTYPE.NC
            if comp.resource.TopicARN.indexOf("arn:aws:sns:") is 0
              #Create TopicArn when NC's TopicARN is not reference
              if not topicMap[ comp.resource.TopicARN ]
                topicComp = {
                  name     : comp.resource.TopicARN.split(":").pop()
                  type     : "AWS.SNS.Topic"
                  uid      : MC.guid()
                  resource : {
                    TopicArn : comp.resource.TopicARN
                  }
                }
                topicMap[comp.resource.TopicARN] = topicComp
                topicCompAry.push topicComp

                console.log "create component for Topic"

              uid = topicMap[ comp.resource.TopicARN ].uid
              comp.resource.TopicARN = "@{#{uid}}.resource.TopicArn"

              console.log "convert TopicARN of NC"

          when RESTYPE.DBINSTANCE
            comp.resource.MasterUserPassword = "****"
            dbins = CloudResources( comp.type, region ).get( comp.resource.DBInstanceIdentifier )
            if dbins
              dbins = dbins.attributes
              if not dbins.ReadReplicaSourceDBInstanceIdentifier
                comp.resource.ReadReplicaSourceDBInstanceIdentifier = ""

              #changing DBInstance attribute( avoid json diff )
              pending = dbins.PendingModifiedValues
              if pending
                if pending.AllocatedStorage
                  comp.resource.AllocatedStorage = Number(pending.AllocatedStorage)
                if pending.BackupRetentionPeriod
                  comp.resource.BackupRetentionPeriod = Number(pending.BackupRetentionPeriod)
                if pending.DBInstanceClass
                  comp.resource.DBInstanceClass = pending.DBInstanceClass
                if pending.Iops
                  comp.resource.Iops = Number(pending.Iops)
                if pending.MultiAZ
                  comp.resource.MultiAZ = pending.MultiAZ
                if pending.MasterUserPassword
                  comp.resource.MasterUserPassword = pending.MasterUserPassword

      #append topic component to component_data
      @generatedJson.component[topic.uid] = topic for topic in topicCompAry

      invalidExpandedAsgAry = []
      for key,layout of @generatedJson.layout
        if layout.type is 'ExpandedAsg'
          if not @generatedJson.component[ layout.originalId ]
            invalidExpandedAsgAry.push key

      #remove invalid ExpandedAsg
      delete @generatedJson.layout[exAsgId] for exAsgId in invalidExpandedAsgAry

      console.log "Patched Generated Json:", @generatedJson
      return
  }
