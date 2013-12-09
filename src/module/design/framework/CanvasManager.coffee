
define [], ()->

  Design = null

  CanvasManager = {

    setDesign : (d)->
      Design = d
      null

    removeClass : ( element, theClass )->
      if element.length
        element = element[0]
      if not element
        return this

      klass = el.getAttribute "class"
      newKlass = klass.replace( new Reg("\\b#{theClass}\\b", "g"), "" )

      if klass isnt newKlass
        el.setAttribute "class", newKlass

      return this

    addClass : ( element, theClass )->
      if element.length
        element = element[0]
      if not element
        return this

      klass = el.getAttribute "class"

      if not klass.match( new Reg("\\b#{theClass}\\b") )
        klass += " " + theClass
        el.setAttribute "class", klass

      return this

    toggle : ( element, isShow ) ->
      if element.length
        element = element[0]
      if not element
        return this

      if isShow is null || isShow is undefined
        isShow = element.getAttribute("display") is "none"

      if isShow
        element.setAttribute "display", "inline"
        element.setAttribute "style", ""
        if element.getAttribute "data-tooltip"
          @addClass element, "tooltip"
      else
        element.setAttribute "display", "none"
        element.setAttribute "style", "opacity:0"
        @removeClass element, "tooltip"

      return this

    update : ( element, value, attr )->

      if _.isString element
        element = document.getElementById( element )

      element = $( element )

      if not attr
        element.text( value )
      else if attr is "href"
        element[0].setAttributeNS("http://www.w3.org/1999/xlink", "href", value)
      else if attr is "tooltip"
        element.data("tooltip", value).attr("data-tooltip", value)
        CanvasManager.addClass( element, "tooltip" )
      else if attr is "color"
        element.attr("style", "fill:#{value}")
      else
        element.attr( attr, value )

    move : ( compUid, x, y ) ->

      design = Design.instance()
      component = design.component compUid

      component.set "x", x
      component.set "y", y

      @position document.getElementById( compUid ), x, y
      null

    resize : ( compUid, w, h ) ->

      design = Design.instance()
      component = design.component compUid

      if not component.get("group")
        console.error "Only group element can be resized."
        return

      oldw = component.get "width"
      oldh = component.get "height"

      component.set "width", w
      component.set "height", h

      @size document.getElementById( compUid ), w, h, oldw, oldh
      null

    size : ( node, w, h, oldw, oldh )->

      pad    = 10
      w     *= MC.canvas.GRID_WIDTH
      h     *= MC.canvas.GRID_HEIGHT
      oldw  *= MC.canvas.GRID_WIDTH
      deltaW = w - oldw

      # Update layout
      $node = $(node)
      $node.children("group").attr("width", w).attr("height", h)

      # Update port if there's any
      # Currently we only have to update subnet's port
      $ports = $node.children("path")
      transformReg = /translate\(([^)]+)\)/
      for child in $ports
        transform = transformReg.exec( child.getAttribute("class") )
        if transform and transform[1]
          transform = transform[1].split(",")
          newX = x = parseInt( transform[0], 10 )
          y = parseInt( transform[1], 10 )
          newY = h / 2
          if x >= oldw
            newX += deltaW
          if x != newX || y != newY
            @position child, newX, newY

      # Update Resizer
      $wrap = $node.children('.resizer-wrap').children()
      if $wrap.length
        childMap = {}
        for child in $wrap
          childMap[ child.getAttribute("class") ] = child

        child = childMap["resizer-top"]
        if child then child.setAttribute("width", w - 2 * pad)
        child = childMap["resizer-bottom"]
        if child then child.setAttribute("width", w - 2 * pad)

        child = childMap["resizer-left"]
        if child then child.setAttribute("height", h - 2 * pad)
        child = childMap["resizer-right"]
        if child then child.setAttribute("height", h - 2 * pad)

        child = childMap["resizer-topright"]
        if child then child.setAttribute("x", w - pad)
        child = childMap["resizer-bottomleft"]
        if child then child.setAttribute("y", h - pad)
        child = childMap["resizer-bot"]
        if child
          child.setAttribute("x", w - pad)
          child.setAttribute("y", h - pad)

    position : ( node, x, y )->

      if node.length then node = node[0]

      if x < 0 then x = 0
      if y < 0 then y = 0

      transformVal = node.transform.baseVal

      x *= MC.canvas.GRID_WIDTH
      y *= MC.canvas.GRID_HEIGHT

      if transformVal.numberOfItems is 1
        transformVal.getItem(0).setTranslate(x, y)

      else
        translateVal = node.ownerSVGElement.createSVGTransform()
        translateVal.setTranslate(x, y)
        transformVal.appendItem(translateVal)

    drawLine : ( connection )->

      # Calculate the ports
      id_from   = connection.port1Comp().id
      id_to     = connection.port2Comp().id
      node_from = document.getElementById( id_from )
      node_to   = document.getElementById( id_to )
      pos_from  = node_from.getBoundingClientRect()
      pos_to    = node_to.getBoundingClientRect()

      from_port = connection.port1("name")
      to_port   = connection.port2("name")

      dirn_from = connection.port1("direction")
      dirn_to   = connection.port2("direction")

      if dirn_from and dirn_to
        if pos_from.left > pos_to.left
          from_port += "-left"
          to_port   += "-right"
        else
          from_port += "-right"
          to_port   += "-left"

        node_from = document.getElementById( id_from + "_port-" + from_port )
        node_to   = document.getElementById( id_to   + "_port-" + to_port   )

        pos_from = node_from.getBoundingClientRect()
        pos_to   = node_to.getBoundingClientRect()

      else if dirn_from

        node_to = document.getElementById( id_to   + "_port-" + to_port   )
        pos_to  = node_to.getBoundingClientRect()

        if dirn_from is "vertical"
          from_port += if pos_to.top > pos_from.top then "-bottom" else "-top"
        else if dirn_from is "horizontal"
          from_port += if pos_to.left > pos_from.left then "-right" else "-left"

        node_from = document.getElementById( id_from + "_port-" + from_port )
        pos_from  = node_from.getBoundingClientRect()

      else if dirn_to
        node_from = document.getElementById( id_from + "_port-" + from_port )
        pos_from  = node_from.getBoundingClientRect()

        if dirn_to is "vertical"
          to_port += if pos_from.top > pos_to.top then "-bottom" else "-top"
        else if dirn_to is "horizontal"
          to_port += if pos_from.left > pos_to.left then "-right" else "-left"

        node_to = document.getElementById( id_to + "_port-" + to_port )
        pos_to  = node_to.getBoundingClientRect()


      # Calculate port position
      scale    = MC.canvas_property.SCALE_RATIO
      pos_svg  = $('#svg_canvas').offset()

      start0 =
        x     : Math.floor(pos_from.left - pos_svg.left + pos_from.width  / 2) * scale
        y     : Math.floor(pos_from.top  - pos_svg.top  + pos_from.height / 2) * scale
        angle : parseInt( node_from.getAttribute("data-angle"), 10 ) || 0

      end0 =
        x     : Math.floor(pos_to.left - pos_svg.left + pos_to.width   / 2) * scale
        y     : Math.floor(pos_to.top  - pos_svg.top  + pos_to.height  / 2) * scale
        angle : parseInt( node_to.getAttribute("data-angle"), 10 ) || 0


      # Calculate line path
      if start0.x is end0.x or start0.y is end0.y
        path = "M#{start0.x} #{start0.y} L#{end0.x} #{end0.y}"
      else
        controlPoints = MC.canvas.route2( start0, end0 )
        if controlPoints
          LINE_STYLE = if connection.get("lineType") is 'sg' then MC.canvas_property.LINE_STYLE else 777

          switch LINE_STYLE
            when 0
              path = "M#{controlPoints[0].x} #{controlPoints[0].y} L#{controlPoints[1].x} #{controlPoints[1].y} L#{controlPoints[controlPoints.length-2].x} #{controlPoints[controlPoints.length-2].y} L#{controlPoints[controlPoints.length-1].x} #{controlPoints[controlPoints.length-1].y}"
            when 1 then path = MC.canvas._round_corner(controlPoints)
            when 2 then path = MC.canvas._bezier_q_corner(controlPoints)
            when 3 then path = MC.canvas._bezier_qt_corner(controlPoints)
            when 777 then path = MC.canvas._round_corner(controlPoints)



      # Create or redraw line
      svg_line = document.getElementById( connection.id )
      if svg_line
        $( svg_line ).children().attr( 'd', path )
      else
        MC.paper.start()

        MC.paper.path(path)
        MC.paper.path(path).attr 'class', 'fill-line'

        if connection.get("dashLine")
          MC.paper.path(path).attr 'class', 'dash-line'

        svg_line = $(MC.paper.save()).attr({
          'class'     : 'line line-' + connection.get("lineType"),
          'data-type' : 'line'
        })

        document.getElementById( "line_layer" ).appendChild( svg_line[0] )
      null

    updateSGLabel : ( uid, sgLabelGroup )->
      # TODO : Change this function to use the framework

      # Prepare data
      labels = [{
        color : "#f26c4f"
        name  : "DefaultSG"
      }]

      # Update canvas sg label
      if not sgLabelGroup
        sgLabelGroup = $( uid + "_node-sg-color-group" ).children()
      else
        sgLabelGroup = sgLabelGroup.children()

      i = 0
      while i < MC.canvas.SG_MAX_NUM
        if i < labels.length and labels[i]
          Canvon( sgLabelGroup.eq(i).attr( "fill", labels[i].color ) )
            .addClass("tooltip").data("tooltip", labels[i].name )
            .attr("data-tooltip", labels[i].name )

        else
          Canvon( sgLabelGroup.eq(i).attr( "fill", "none" ) )
            .addClass("tooltip").data("tooltip", "" )
            .attr("data-tooltip", "" )

        ++i

  }

  CanvasManager
