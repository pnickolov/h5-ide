
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

    setMesosData: ( data ) ->
      framework = data.frameworks[ 0 ]

      ipMap = MesosMasterModel.getMasterIPs()

      leaderIpPortString  = data.leader.split( '@' )[ 1 ]
      leaderIpPortArray   = leaderIpPortString.split ':'
      leaderPrivateIp     = leaderIpPortArray[ 0 ]
      leaderPublicIp      = ipMap[ leaderPrivateIp ]
      leaderPort          = leaderIpPortArray[ 1 ]

      if framework
        marathonIpPortString = framework.webui_url.slice 7 # Remove http://
        marathonIpPortArray = marathonIpPortString.split ':'
        marathonPrivateIp = marathonIpPortArray[ 0 ]
        marathonPublicIp = ipMap[ marathonPrivateIp ]
        marathonPort = marathonIpPortArray[ 1 ]

      data = {
        framework   : framework and 'marathon' or ''
        leaderIp    : leaderPublicIp
        leaderPort  : leaderPort
        marathonIp  : marathonPublicIp
        marathonPort: marathonPort
        slaves      : data.slaves
      }

      @opsModel.setMesosData data

    updateMesosInfo : ()->
      that = @
      @mesosSchedule = null
      jobs = []

      jobs.push(
        ApiRequest("marathon_info", {
          "key_id" : @opsModel.credentialId()
          "master_ips" : MesosMasterModel.getMasterIPs()
        }).then ( data )->
          that.setMesosData data
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
