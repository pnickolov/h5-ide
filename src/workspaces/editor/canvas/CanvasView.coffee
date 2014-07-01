
define [
  "../template/TplOpsEditor"
  "./CanvasElement"
  "Design"

  "./CeVpc"
  "./CeAz"
  "./CeSubnet"
  "./CeRtb"
  "./CeIgw"
  "./CeVgw"
  "./CeCgw"
  "./CeElb"
  "./CeEni"
  "./CeInstance"
  "./CeAsg"

  "backbone"
  "jquery"
  "svgjs"
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
        width : canvasSize[0] * MC.canvas.GRID_WIDTH
        height: canvasSize[1] * MC.canvas.GRID_WIDTH
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

      @svg.clear().add([
        @svg.group().classes("layer_vpc")
        @svg.group().classes("layer_az")
        @svg.group().classes("layer_subnet")
        @svg.group().classes("layer_line")
        @svg.group().classes("layer_node")
      ])

      @__itemMap = {}

      lines = []
      @design.eachComponent ( comp )->
        if comp.node_line
          lines.push comp
        else
          @addItem(comp)
        return
      , @

      @addItem(comp) for comp in lines
      return

    addItem : ( resourceModel )->
      ItemClass = CanvasElement.getClassByType( resourceModel.type )
      if not ItemClass then return

      if resourceModel.isVisual()
        item = new ItemClass({
          model  : resourceModel
          canvas : @
        })
        @__itemMap[ resourceModel.id ] = item
      return

    removeItem : ( resourceModel )->

    update : ()->


  }

  CanvasView
