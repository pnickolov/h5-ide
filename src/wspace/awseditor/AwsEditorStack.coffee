
define [
  "CoreEditor"
  "OpsModel"
  "./AwsViewStack"
  "./model/DesignAws"
  "CloudResources"
  "constant"
  "Credential"

  "./AwsDeps"
], ( CoreEditor, OpsModel, StackView, DesignAws, CloudResources, constant, Credential )->


  ###
    StackEditor is mainly for editing a stack
  ###
  CoreEditor.extend {

    type : "AwsEditorStack"

    viewClass   : StackView
    designClass : DesignAws

    title : ()-> (@design || @opsModel).get("name") + " - stack"

    fetchData : ()->
      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module
      credId      = @opsModel.credentialId()

      jobs = [
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( credId, constant.RESTYPE.AZ,   region ).fetch()
        CloudResources( credId, constant.RESTYPE.SNAP, region ).fetch()
        CloudResources( credId, "QuickStartAmi",       region ).fetch()
        CloudResources( credId, "MyAmi",               region ).fetch()
        CloudResources( credId, "FavoriteAmi",         region ).fetch()
        @fetchAmiData()
        @fetchRdsData( false )
      ]

      Q.all(jobs)

    fetchAmiData : ()->
      json = @opsModel.getJsonData()
      toFetch = {}
      for uid, comp of json.component
        if comp.type is constant.RESTYPE.INSTANCE or comp.type is constant.RESTYPE.LC
          imageId = comp.resource.ImageId
          if imageId then toFetch[ imageId ] = true

      CloudResources( @opsModel.credentialId(), constant.RESTYPE.AMI, @opsModel.get("region") ).fetchAmis( _.keys toFetch )

    isRdsDisabled : ()-> !!@__disableRds
    fetchRdsData : ( isForce = true )->
      self   = @
      region = @opsModel.get("region")

      if isForce
        method = "fetchForce"
      else
        method = "fetch"

      credId = @opsModel.credentialId()

      Q.all([
        CloudResources( credId, constant.RESTYPE.DBENGINE, region )[method]()
        CloudResources( credId, constant.RESTYPE.DBOG,     region )[method]()
        CloudResources( credId, constant.RESTYPE.DBSNAP,   region )[method]()
      ]).then ()->
        if self.__disableRds isnt false
          self.__disableRds = false
          self.trigger "toggleRdsFeature", true
      , ( error )->
        if error.awsErrorCode
          console.error "No authority to load rds data. Rds feature will be disabled.", error
          # Ignore rds api auth failure.
          self.__disableRds = true
          self.trigger "toggleRdsFeature", false
          return

        # Other reasons will consider as network error,
        # And will ask user to load ide again.
        throw error

    isModified : ()->
      if not @opsModel.isPersisted() then return false
      @design && @design.isModified()
  }, {
    canHandle : ( data )->
      if not data.opsModel then return false
      return data.opsModel.type is OpsModel.Type.Amazon and data.opsModel.isStack()
  }
