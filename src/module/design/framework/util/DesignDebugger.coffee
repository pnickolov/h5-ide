
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

    a = JSON.stringify( canvas_data )
    b = JSON.stringify( Design.instance().serialize() )

    require ["test/jsondiff/JsonDiff"], ( JsonDiff )->
      JsonDiff.showDiffDialog( canvas_data, Design.instance().serialize() )

    # a = JSON.stringify( canvas_data ).replace(/"/g, '\\"')
    # b = JSON.stringify( Design.instance().serialize() ).replace(/"/g, '\\"')

    # param = '{"d":{"a":"'+a+'","b":"'+b+'"}}'
    # #
    # window.open 'test/jsondiff/index.htm#' + encodeURIComponent(param)
    # if e and e.preventDefault then e.preventDefault()
    null

  Design.debug.json = ( notToString )->
    data = Design.instance().serialize()
    if not notToString
      return JSON.stringify( data )
    else
      console.log( data )
    null

  Design.debug.view = ( e )->
    if e and e.preventDefault then e.preventDefault()
    null

  window.D  = Design
  window.ds = ()-> Design.debug.json( true )

  ### env:dev:end ###
