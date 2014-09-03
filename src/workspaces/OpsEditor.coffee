
###
  This file is used to include all the core functionality of the editor
###

###
  OpsEditor is a workspace for working on an OpsModel
  This class is implemented as a class cluster. Actually implementation is seperated in
  other concrete class :

  ProgressViewer  : For starting app.
###

define [
  "ProgressViewer"

  "Design"

  "ResourceModel"
  "ComplexResModel"
  "ConnectionModel"
  "GroupModel"

  "CoreEditor"

  "CoreEditorView"

  "CanvasManager"
  "CanvasView"
  "CanvasElement"
  "CanvasPopup"
  "CanvasViewLayout"
  "workspaces/coreeditor/CanvasViewConnect"
  "workspaces/coreeditor/CanvasViewDnd"
  "workspaces/coreeditor/CanvasViewGResizer"

  "workspaces/coreeditor/TplOpsEditor"
  "workspaces/coreeditor/TplSvgDef"
], ( ProgressViewer, Design )->

  ### env:dev ###
  require ["workspaces/coreeditor/DesignDebugger"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["workspaces/coreeditor/DesignDebugger"], ()->
  ### env:debug:end ###

  window.Design = Design

  registeredEditors = []

  OpsEditor = ( opsmodel )->
    if not opsModel
      throw new Error("Cannot find opsmodel while openning workspace.")

    if opsModel.isProcessing()
      return new ProgressViewer opsModel

    for e in registeredEditors
      if e.handler( opsmodel )
        return new e.editor( opsmodel )

    console.error "Cannot find editor to edit OpsModel: ", opsmodel

  OpsEditor.registerEditors = ( editor, handler )->
    registeredEditors.push { editor : editor, handler : handler }

  OpsEditor
