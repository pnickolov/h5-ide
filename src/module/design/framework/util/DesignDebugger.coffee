
define [ "Design" ], ( Design )->

  ### env:dev ###
  Design.debug = ()->
    componentMap = Design.instance().__componentMap
    canvasNodes  = Design.instance().__canvasNodes
    canvasGroups = Design.instance().__canvasGroups
    checkedMap   = {
      "line"            : {}
      "node"            : {}
      "group"           : {}
      "otherResource"   : {}
      "otherConnection" : {}
    }
    checked = {}
    for id, a of canvasNodes
      checked[ id ] = true
      checkedMap.node[ a.id ] = a
    for id, a of canvasGroups
      checked[ id ] = true
      checkedMap.group[ a.id] = a
    for id, a of componentMap
      if checked[ id ] then continue
      if a.node_line
        if a.isVisual()
          checkedMap.line[ a.id ] = a
        else
          checkedMap.otherConnection[ a.id ] = a
      else
        checkedMap.otherResource[ a.id ] = a

    checkedMap

  Design.debug.selectedComp = ()->
    Design.instance().component( $("#svg_canvas").find(".selected").attr("id") )

  Design.debug.diff = ( e )->

    d = Design.instance()

    canvas_data = $.extend true, {}, d.attributes

    canvas_data.component = d.__backingStore.component
    canvas_data.layout    = d.__backingStore.layout
    canvas_data.name      = d.__backingStore.name

    require ["test/jsonviewer/JsonViewer"], ( JsonViewer )->
      JsonViewer.showDiffDialog( canvas_data, Design.instance().serialize() )
    null

  Design.debug.json = ( notToString )->
    data = Design.instance().serialize()
    if not notToString
      return JSON.stringify( data )
    else
      console.log( data )
    null

  Design.debug.export = ()->
    filename = 'CanvasData.json'
    data     = Design.debug.json()

    blob = new Blob([data], {type: 'text/json'})
    e    = document.createEvent('MouseEvents')
    a    = document.createElement('a')

    a.download = filename
    a.href = window.URL.createObjectURL(blob)
    a.dataset.downloadurl =  ['text/json', a.download, a.href].join(':')
    e.initMouseEvent('click', true, false, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
    a.dispatchEvent(e)
    null

  Design.debug.view = ( e )->
    if e and e.preventDefault then e.preventDefault()

    data = Design.instance().serialize()
    require ["test/jsonviewer/JsonViewer"], ( JsonViewer )->
      JsonViewer.showViewDialog( data )
    null

  window.D   = Design
  window.dd  = Design.debug
  window.dds = ()-> Design.debug.json( true )

  ### env:dev:end ###
  null
