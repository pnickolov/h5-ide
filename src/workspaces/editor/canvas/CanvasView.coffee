
define [
  "../template/TplOpsEditor"
  "./CanvasElement"
  "Design"

  "backbone"
  "jquery"
  "svgjs"
  "MC.canvas.constant"
], ( OpsEditorTpl, CanvasElement, Design )->

  # Insert svg defs template.
  $( OpsEditorTpl.svgDefs() ).appendTo("body")

  CanvasView = Backbone.View.extend {

    initialize : ( options )->
      @workspace = options.workspace
      @design    = @workspace.design
      @parent    = options.parent

      @listenTo @design, Design.EVENT.Deserialized,   @reload
      @listenTo @design, Design.EVENT.AddResource,    @addItem
      @listenTo @design, Design.EVENT.RemoveResource, @removeItem

      @setElement @parent.$el.find(".OEPanelCenter")
      @svg = SVG( @$el.find("svg")[0] )
      canvasSize = @design.get("canvasSize")

      @$el.children(".canvas-view").css({
        width : canvasSize[0] * CanvasView.GRID_WIDTH
        height: canvasSize[1] * CanvasView.GRID_WIDTH
      })

      @reload()
      return

    __appendSvg : ( svgEl, layer )->
      svgEl.node.instance = svgEl
      $( @svg.node ).children(layer).append( svgEl.node )
      svgEl

    appendVpc    : ( svgEl )-> @__appendSvg(svgEl, ".layer_vpc")
    appendAz     : ( svgEl )-> @__appendSvg(svgEl, ".layer_az")
    appendSubnet : ( svgEl )-> @__appendSvg(svgEl, ".layer_subnet")
    appendLine   : ( svgEl )-> @__appendSvg(svgEl, ".layer_line")
    appendNode   : ( svgEl )-> @__appendSvg(svgEl, ".layer_node")

    reload : ()->
      console.log "Reloading svg canvas."

      @initializing = true

      @svg.clear().add([
        @svg.group().classes("layer_vpc")
        @svg.group().classes("layer_az")
        @svg.group().classes("layer_subnet")
        @svg.group().classes("layer_line")
        @svg.group().classes("layer_node")
      ])

      @__itemMap = {}

      lines = []
      types = {}
      @design.eachComponent ( comp )->
        if comp.node_line
          lines.push comp
        else
          @addItem(comp)
        types[ comp.type ] = true
        return
      , @

      @addItem(comp) for comp in lines

      for t of types
        ItemClass = CanvasElement.getClassByType( t )
        if ItemClass and ItemClass.render
          ItemClass.render( this )

      @initializing = false
      return

    addItem : ( resourceModel )->
      ItemClass = CanvasElement.getClassByType( resourceModel.type )
      if not ItemClass then return

      if resourceModel.isVisual()
        item = new ItemClass({
          model  : resourceModel
          canvas : @
        })

        if not item.cid then return

        @__itemMap[ resourceModel.id ] = item
        @__itemMap[ item.cid ] = item
      return

    removeItem : ( resourceModel )->
      item = @getItem( resourceModel.id )
      delete @__itemMap[ resourceModel.id ]
      delete @__itemMap[ item.cid ]
      item.remove()
      return

    getItem : ( id )-> @__itemMap[ id ]

    update : ()->


  }, {
    GRID_WIDTH  : 10
    GRID_HEIGHT : 10
  }

  CanvasElement.setCanvasViewClass CanvasView

  CanvasView
