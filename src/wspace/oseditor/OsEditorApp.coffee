
define [
  "CoreEditorApp"
  "./OsViewApp"
  "./model/DesignOs"
  "OpsModel"
  "CloudResources"
  "constant"
], ( CoreEditorApp, AppView, DesignOs, OpsModel, CloudResources, constant )->

  class AppEditor extends CoreEditorApp

    viewClass : AppView
    designClass : DesignOs

    fetchData : ()->
      self = @

      region      = @opsModel.get("region")
      stateModule = @opsModel.getJsonData().agent.module

      Q.all([
        App.model.fetchStateModule( stateModule.repo, stateModule.tag )
        CloudResources( constant.RESTYPE.OSFLAVOR,  region ).fetch()
        CloudResources( constant.RESTYPE.OSIMAGE,   region ).fetch()
        CloudResources( constant.RESTYPE.OSKP,      region ).fetch()
        CloudResources( constant.RESTYPE.OSIMAGE,   region ).fetch()
        CloudResources( constant.RESTYPE.OSNETWORK, region ).fetch()
        CloudResources( constant.RESTYPE.OSVOL, region ).fetch()
        @loadVpcResource()
      ])

  AppEditor
