
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
        return d.promise

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

      # Parse aws resource data with other collection
      extraAttr = { RES_TAG : @category }
      for type, d of data
        cln = CloudResources( type, @__region )
        if not cln
          console.warn "Cannot find cloud resource collection for type:", type
          continue
        cln.__parseExternalData d, extraAttr, @__region

      if data.app_json
        @generatedJson = data.app_json
        delete data.app_json

        console.log "Generated Json from backend:", $.extend true, {}, @generatedJson

        topicMap       = {} # id=>comp
        topicCompAry   = []

        RESTYPE = constant.RESTYPE

        # Fix invalid json
        region = @__region
        for uid, comp of @generatedJson.component
          switch comp.type
            when RESTYPE.ENI
              for sg in comp.resource.GroupSet
                if sg.GroupName.indexOf("@{") isnt 0
                  sg.GroupName = "@{#{MC.extractID(sg.GroupId)}.resource.GroupName}"
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
                comp.resource.TopicARN = "@{#{uid}.resource.TopicArn}"

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

      else
        ### env:dev ###
        @generatedJson = @__generateJsonFromRes()
        console.log "Generated Json from frontend:", $.extend true, {}, @generatedJson
        ### env:dev:end ###

      console.log "Patched Generated Json:", @generatedJson
      return

    ### env:dev ###
    __generateJsonFromRes : ()->
      res = CloudResources.getAllResourcesForVpc( @__region, @category )
      json = {
        id          : ""
        name        : @category
        description : ""
        region      : @__region
        platform    : "ec2-vpc"
        state       : "Enabled"
        version     : "2014-02-17"
        component   : {}
        layout      : { size : [240, 240] }
        agent :
          enabled : true
          module  :
            repo : App.user.get("repo")
            tag  : App.user.get("tag")
        property :
          stoppable : true
      }
      json.component = res.component
      json.layout    = res.layout
      json.name      = "imported-" + @category
      return json
    ### env:dev:end ###

  }
