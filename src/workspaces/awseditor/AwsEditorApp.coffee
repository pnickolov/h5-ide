
define [
  "CoreEditorApp"
  "./AwsViewApp"
  "./model/DesignAws"
  "./AwsEditorStack"
  "OpsModel"
  "CloudResources"
  "constant"

  "./AwsDeps"
], ( CoreEditorApp, AppView, DesignAws, StackEditor, OpsModel, CloudResources, constant )->

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

    fetchAmiData  : StackEditor.prototype.fetchAmiData
    fetchRdsData  : StackEditor.prototype.fetchRdsData
    isRdsDisabled : StackEditor.prototype.isRdsDisabled

  }, {
    canHandle : ( data )->
      if not data.opsModel then return false
      return data.opsModel.type is OpsModel.Type.Amazon and data.opsModel.isApp()
  }
