
###
  This file is used to include all the core functionality of the editor
###
define [
  "Design"
  "ResourceModel"
  "ComplexResModel"
  "ConnectionModel"
  "GroupModel"

  "CoreEditor"

  "CoreEditorView"
  "ProgressViewer"

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
], ( Design )->

  ### env:dev ###
  require ["workspaces/coreeditor/DesignDebugger"], ()->
  ### env:dev:end ###
  ### env:debug ###
  require ["workspaces/coreeditor/DesignDebugger"], ()->
  ### env:debug:end ###

  window.Design = Design

  registeredEditors = []

  OpsEditor = ( opsmodel )->
    for e in registeredEditors
      if e.handler( opsmodel )
        return new e.editor( opsmodel )

    console.error "Cannot find editor to edit OpsModel: ", opsmodel

  OpsEditor.registerEditors = ( editor, handler )->
    registeredEditors.push { editor : editor, handler : handler }

  OpsEditor
