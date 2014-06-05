
###
  OpsEditor is a workspace for working on an OpsModel
  This class is implemented as a class cluster. Actually implementation is seperated in
  other concrete class :

  OpsProgress : For starting app.
  OpsViewer   : For viewing visualize app
###

define [ "./editor/OpsProgress", "./editor/OpsViewer", 'module/design/framework/DesignBundle' ], ( OpsProgress, OpsViewer )->

  # OpsEditor defination
  class OpsEditor

    constructor : ( opsModel )->
      if not opsModel
        throw new Error("Cannot find opsmodel while openning workspace.")

      if opsModel.isImported()
        return new OpsViewer opsModel

      if opsModel.isProcessing()
        return new OpsProgress opsModel

      return new OpsViewer opsModel

  OpsEditor
