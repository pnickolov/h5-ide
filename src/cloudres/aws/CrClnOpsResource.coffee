
define ["ApiRequest", "../CrCollection", "constant", "CloudResources"], ( ApiRequest, CrCollection, constant, CloudResources )->

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

      app_json = data.app_json
      delete data.app_json

      # Parse aws resource data with other collection
      extraAttr = { RES_TAG : @category }
      for type, d of data
        cln = CloudResources( type, @__region )
        if not cln
          console.warn "Cannot find cloud resource collection for type:", type
          continue
        cln.__parseExternalData d, extraAttr, @__region

      #get originalJson
      app_id = App.workspaces.getAwakeSpace().opsModel.get("id")
      if app_id and app_id.substr(0,4) is 'app-'
        originalJson = App.model.attributes.appList.where({id:app_id})
        if originalJson and originalJson.length>0
          originalJson = originalJson[0].__jsonData

      if app_json
        @generatedJson = app_json
        #fill repo and tag of module when they are empty
        if not (app_json.agent.module.repo and app_json.agent.module.tag)
          @generatedJson.agent.module.repo = App.user.get("repo")
          @generatedJson.agent.module.tag  = App.user.get("tag")
        console.log "Generated Json from backend:", $.extend true, {}, @generatedJson

        ###### patch for app_json ######
        for id,comp of @generatedJson.component
          #fill attachmentId of ENI
          if comp.type is constant.RESTYPE.ENI
            eni = CloudResources(constant.RESTYPE.ENI,@__region ).where({id:comp.resource.NetworkInterfaceId})
            if eni and eni.length>0 and not comp.resource.Attachment.AttachmentId
              eni = eni[0].attributes
              comp.resource.Attachment.AttachmentId = eni.attachment.attachmentId
              console.warn "[patch app_json] fill AttachmentId of eni"
          else if comp.type is constant.RESTYPE.KP
            kpComp = $.extend true, {}, comp
          null
        #patch for old app without DefaultKP and default SG
        if originalJson
          for id,comp of originalJson.component
            if comp.type is constant.RESTYPE.KP
              originalKpComp = $.extend true, {}, comp
            else if comp.type is constant.RESTYPE.SG and comp.name in ["DefaultSG","default"]
              sg = CloudResources(constant.RESTYPE.SG,@__region ).where({id:comp.resource.GroupId})
              if sg and sg.length>0 and comp.resource.GroupName isnt sg[0].get("groupName")
                comp.resource.GroupName = sg[0].get("groupName")
                console.warn "[patch app_json] change groupName from 'default' to real value @{comp.resource.GroupName}"
            null
          #use original KP to avoid diff
          if originalKpComp
            if kpComp and originalKpComp.uid isnt kpComp.uid
              delete @generatedJson.component[kpComp.uid]
              @generatedJson.component[originalKpComp.uid] = originalKpComp
          else
            originalJson.component[kpComp.uid] = kpComp

        #patch for agent.enable
        @generatedJson.agent.enabled = if originalJson then originalJson.agent.enabled else false

        ###### patch for app_json ######
      else
        ### env:dev ###
        @generatedJson = @__generateJsonFromRes(originalJson)
        console.log "Generated Json from frontend:", $.extend true, {}, @generatedJson
        ### env:dev:end ###

      return

    ### env:dev ###
    __generateJsonFromRes : ( originalJson )->
      res = CloudResources.getAllResourcesForVpc( @__region, @category, originalJson )
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
      json.name      = if originalJson then originalJson.name else "imported-" + @category
      return json
    ### env:dev:end ###

  }
