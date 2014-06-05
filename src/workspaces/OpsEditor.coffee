
###
  OpsEditor is a workspace for working on an OpsModel
  This class is implemented as a class cluster. Actually implementation is seperated in
  other concrete class :

  ProgressViewer  : For starting app.
  UnmanagedViewer : For viewing visualize app
###

define [
  "./editor/ProgressViewer"
  "./editor/UnmanagedViewer"
  "./editor/StackEditor"
  './editor/framework/DesignBundle'
], ( ProgressViewer, UnmanagedViewer, StackEditor )->

  # OpsEditor defination
  class OpsEditor

    constructor : ( opsModel )->
      if not opsModel
        throw new Error("Cannot find opsmodel while openning workspace.")

      if opsModel.isImported()
        return new UnmanagedViewer opsModel

      if opsModel.isProcessing()
        return new ProgressViewer opsModel

      if opsModel.isStack()
        return new StackEditor opsModel

      return new StackEditor opsModel

  OpsEditor
