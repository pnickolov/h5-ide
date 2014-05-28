
###
  OpsEditor is a workspace for working on an OpsModel
  This class is implemented as a class cluster. Actually implementation is seperated in
  other concrete class :

  OpsProgress : For starting app.
###

define [ "Workspace", "./editor/OpsProgress" ], ( Workspace, OpsProgress )->

  class OpsEditor extends Workspace

    constructor : ( attribute )->
      opsModel = App.model.stackList().get( attribute )
      if not opsModel then opsModel = App.model.appList().get( attribute )

      if not opsModel
        throw new Error("Cannot find opsmodel while openning workspace.")

      opsModel.attributes.state = 3
      opsModel.attributes.progress = 20

      if opsModel.isProcessing()
        return new OpsProgress attribute

      return

  OpsEditor
