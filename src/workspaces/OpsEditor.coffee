
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
  "./editor/AppEditor"
  './editor/framework/DesignBundle'
], ( ProgressViewer, UnmanagedViewer, StackEditor, AppEditor )->

  # OpsEditor defination
  OpsEditor = ( opsModel )->
    if not opsModel
      throw new Error("Cannot find opsmodel while openning workspace.")

    if opsModel.isImported()
      return new UnmanagedViewer opsModel

    if opsModel.isProcessing()
      return new ProgressViewer opsModel

    if opsModel.isStack()
      return new StackEditor opsModel
    else
      return new AppEditor opsModel

  OpsEditor
