
define [ "Design" ], ( Design )->

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
    App.workspaces.getAwakeSpace().getSelectedComponent()

  Design.debug.selectedCompState = ()->
    comp = Design.debug.selectedComp()?.serialize()[1]
    if comp and comp.component and comp.component.state
      '{\n\t"component": {\n\t\t"init" : {\n\t\t\t"state": ' + JSON.stringify(comp.component.state) + '\n\t\t}\n\t}\n}\n'
    else
      "no state for selected component"


  Design.debug.diff = ( e )->
    require ["component/jsonviewer/JsonViewer"], ( JsonViewer )->
      d = Design.instance()
      JsonViewer.showDiffDialog( d.__opsModel.getJsonData(), d.serialize() )
    null

  Design.debug.json = ()->
    data = Design.instance().serialize()
    console.log( data )
    return JSON.stringify( data )

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
    require ["component/jsonviewer/JsonViewer"], ( JsonViewer )->
      JsonViewer.showViewDialog( data )
    null

  Design.debug.checkValidDesign = ()->
    dd().eachComponent ( comp )->
      if comp.design() is D.instance()
        console.log "Valid design"
      else
        console.log "Invalid design"
      null
    null

  Design.debug.autoLayout = ()->
    App.workspaces.getAwakeSpace().view.canvas.autoLayout()


  window.d    = ()-> Design.instance()
  window.dd   = Design.debug
  window.dget = ( a )-> Design.instance().get(a)
  window.dset = ( a, b )-> Design.instance().set(a,b)
  window.dds  = ()-> Design.debug.json()


  window.man = "
  d()          Return the current Design instance \n
  dd()         Print all components in current Design \n
  dget(a)      Design att getter \n
  dset(a,b)    Design att setter \n
  dds()        Print JSON \n
  copy(dds())  Copy JSON"


  ###
  In the following block of code, we hijack some design's methods to test if the design is current design. If it's not, we print a warning to console. Making it easier to debug if something goes wrong.
  ###
  ### jshint -W083 ###
  DESIGN_PROTOTYPE = Design.DesignImpl.prototype
  Design.DesignImpl.prototype = NEW_DESIGN_PROTOTYPE = {}
  for funcName, func of DESIGN_PROTOTYPE
    if not DESIGN_PROTOTYPE.hasOwnProperty funcName
      continue

    if not funcName.match(/refreshAppUpdate|cacheComponent|getCost|diff|onAwsResourceUpdated/)
      NEW_DESIGN_PROTOTYPE[ funcName ] = DESIGN_PROTOTYPE[ funcName ]
      continue

    NEW_DESIGN_PROTOTYPE[ funcName ] = (()->
      method = funcName
      ()->
        if @ isnt Design.instance()
          console.warn "The context of the calling function is not current Design object. Every function in Design should only be call if the context is the current Design object. This is a tradeoff to make the API easier to use. \n\nIn order to avoid this limilation. One should change something like : \n  myDesign.#{method}(); \nto :\n  var currentDesign = Design.instance();\n  myDesign.use(); \n  myDesign.#{method}(); \n  currentDesign.use();"
          console.warn "Context :", @, "Current Design :", Design.instance(), "Stack Trace :", (new Error()).stack.replace("Error", "")

        DESIGN_PROTOTYPE[ method ].apply @, arguments
    )()
  ### jshint +W083 ###
  null
