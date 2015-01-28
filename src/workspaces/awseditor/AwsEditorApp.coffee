
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

  class AppEditor extends CoreEditorApp

    viewClass   : AppView
    designClass : DesignAws

    fetchData : ()->
      self = @

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      Q.all([
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( constant.RESTYPE.AZ,       region ).fetch()
        CloudResources( constant.RESTYPE.SNAP,     region ).fetch()
        CloudResources( constant.RESTYPE.DHCP,     region ).fetch()
        CloudResources( "QuickStartAmi",           region ).fetch()
        CloudResources( "MyAmi",                   region ).fetch()
        CloudResources( "FavoriteAmi",             region ).fetch()
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

  AppEditor
