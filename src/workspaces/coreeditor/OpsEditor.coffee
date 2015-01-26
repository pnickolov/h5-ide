
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
  "Workspace"

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
  "workspaces/coreeditor/CeSvg"
  "workspaces/coreeditor/CanvasViewConnect"
  "workspaces/coreeditor/CanvasViewDnd"
  "workspaces/coreeditor/CanvasViewGResizer"
  "workspaces/coreeditor/CanvasViewEffect"

  "workspaces/coreeditor/TplOpsEditor"
  "workspaces/coreeditor/TplSvgDef"
], ( Workspace, Design )->

  ### env:dev ###
  require ["workspaces/coreeditor/DesignDebugger"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["workspaces/coreeditor/DesignDebugger"], ()->
  ### env:debug:end ###

  window.Design = Design

  registeredEditors = []

  Workspace.extend {

    type : "OpsEditor"

    constructor : ( opsmodel )->
      if not opsmodel
        throw new Error("Cannot find opsmodel while openning workspace.")

      if opsmodel.isProcessing()
        return new ProgressViewer opsmodel

      for e in registeredEditors
        if e.handler( opsmodel )
          return new e.editor( opsmodel )

      console.error "Cannot find editor to edit OpsModel: ", opsmodel
      return
  }, {
    canHandle : ()->
    registerEditors : ( editor, handler )->
      registeredEditors.push { editor : editor, handler : handler }
  }
