
define [
  "CoreEditorApp"
  "./AwsViewApp"
  "./model/DesignAws"
  "./AwsEditorStack"
  "OpsModel"
  "CloudResources"
  "constant"
  "ApiRequest"
  "./model/MesosMasterModel"

  "./AwsDeps"
], ( CoreEditorApp, AppView, DesignAws, StackEditor, OpsModel, CloudResources, constant, ApiRequest, MesosMasterModel )->

  CoreEditorApp.extend {

    type : "AwsEditorApp"

    viewClass   : AppView
    designClass : DesignAws

    fetchData : ()->
      self = @

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module
      credId      = @opsModel.credentialId()

      Q.all([
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( credId, constant.RESTYPE.AZ,       region ).fetch()
        CloudResources( credId, constant.RESTYPE.SNAP,     region ).fetch()
        CloudResources( credId, constant.RESTYPE.DHCP,     region ).fetch()
        CloudResources( credId, "QuickStartAmi",           region ).fetch()
        CloudResources( credId, "MyAmi",                   region ).fetch()
        CloudResources( credId, "FavoriteAmi",             region ).fetch()
        @loadVpcResource()
        @fetchAmiData()
        @fetchRdsData( false )
      ]).fail ( err )-> self.__handleDataError( err )

    __handleDataError : ( err )->
      if err.error is 286 # VPC not exist
        @view.showVpcNotExist @opsModel.get("name"), ()=> @opsModel.terminate( true )
        @remove()
        return

      throw err

    initEditor : ()->
      CoreEditorApp.prototype.initEditor.call this
      @mesosJobs()
      return

    cleanup : ()->
      CoreEditorApp.prototype.cleanup.call this
      @cleanupMesosJobs()
      return

    fetchAmiData  : StackEditor.prototype.fetchAmiData
    fetchRdsData  : StackEditor.prototype.fetchRdsData
    isRdsDisabled : StackEditor.prototype.isRdsDisabled

    ### Mesos ###
    mesosJobs : ()->
      self = @
      @updateMesosInfo().then(()->
        if self.isRemoved() then return
      ).fin ()->
        if self.isRemoved() then return
        self.mesosSchedule = setTimeout ()->
          self.mesosJobs()
        , 1000 * 10
      return

    updateMesosInfo : ()->
      that = @
      @mesosSchedule = null
      jobs = []

      jobs.push(
        ApiRequest("marathon_info", {
          "key_id" : @opsModel.credentialId(),
          "master_ips" : {"10.0.3.4":"52.4.211.169", "10.0.2.4":"52.4.252.105", "10.0.2.5":"52.4.57.214"}
          # MesosMasterModel.getMasterIPs()
        }).then ( data )->
          that.opsModel.setMesosData data
      )

      Q.all jobs

    cleanupMesosJobs : ()->
      if @mesosSchedule
        clearTimeout( @mesosSchedule )
        @mesosSchedule = null
      return

  }, {
    canHandle : ( data )->
      if not data.opsModel then return false
      return data.opsModel.type is OpsModel.Type.Amazon and data.opsModel.isApp() and not data.opsModel.isProcessing()
  }
