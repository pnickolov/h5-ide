
###
  OpsEditor is a workspace for working on an OpsModel
  This class is implemented as a class cluster. Actually implementation is seperated in
  other concrete class :

  OpsProgress : For starting app.
  OpsViewer   : For viewing visualize app
###

define [
  "./editor/OpsProgress"
  "./editor/UnmanagedViewer"
  "./editor/StackEditor"
  'module/design/framework/DesignBundle'
], ( OpsProgress, OpsViewer, StackEditor )->

  # OpsEditor defination
  class OpsEditor

    constructor : ( opsModel )->
      if not opsModel
        throw new Error("Cannot find opsmodel while openning workspace.")

      if opsModel.isImported()
        return new UnmanagedViewer opsModel

      if opsModel.isProcessing()
        return new OpsProgress opsModel

      if opsModel.isStack()
        return new StackEditor opsModel

      return new StackEditor opsModel

  OpsEditor
