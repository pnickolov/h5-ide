
define [], ()->

  Design = null

  CanvasManager = {

    setDesign : (d)->
      Design = d
      null

    remove : ( element )->
      if element then MC.canvas.remove( element )
      null

    removeClass : ( element, theClass )->
      if element.length
        element = element[0]
      if not element
        return this

      klass = element.getAttribute("class") || ""
      newKlass = klass.replace( new RegExp("\\b#{theClass}\\b", "g"), "" )

      if klass isnt newKlass
        element.setAttribute "class", newKlass

      return this

    addClass : ( element, theClass )->
      if element.length
        element = element[0]
      if not element
        return this

      klass = element.getAttribute("class") || ""

      if not klass.match( new RegExp("\\b#{theClass}\\b") )
        klass = $.trim(klass) + " " + theClass
        element.setAttribute "class", klass

      return this

    toggle : ( element, isShow ) ->
      if element.hasOwnProperty("length")
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

    updateEip : ( node, targetModel )->
      if node.length then node = node[0]

      toggle = targetModel.hasPrimaryEip()

      if toggle
        tootipStr = 'Detach Elastic IP from primary IP'
        imgUrl    = 'ide/icon/eip-on.png'
      else
        tootipStr = 'Associate Elastic IP to primary IP'
        imgUrl    = 'ide/icon/eip-off.png'

      if Design.instance().modeIsApp()
        resource_list = MC.data.resource_list[ Design.instance().region() ]
        res = resource_list[ targetModel.get("appId") ]
        if toggle and res
          if res.privateIpAddressesSet and res.privateIpAddressesSet.item and res.privateIpAddressesSet.item.length
            res = res.privateIpAddressesSet.item[0]
            if res.association and res.association
              tootipStr = res.association.publicIp || ""
          else
            tootipStr = res.ipAddress || ""
        else
          tootipStr = ""

      node.setAttribute "data-tooltip", tootipStr

      $( node ).data("tooltip", tootipStr)

      this.update( node, imgUrl, "href" )

      null

    update : ( element, value, attr )->

      if _.isString element
        element = document.getElementById( element )

      element = $( element )

      if not attr
        element.text( value )
      else if attr is "href" or attr is "image"
        value = MC.IMG_URL + value
        href = element[0].getAttributeNS("http://www.w3.org/1999/xlink", "href")
        if href isnt value
          element[0].setAttributeNS("http://www.w3.org/1999/xlink", "href", value)
      else if attr is "tooltip"
        element.data("tooltip", value).attr("data-tooltip", value)
        if value
          CanvasManager.addClass( element, "tooltip" )
        else
          CanvasManager.removeClass( element, "tooltip" )
      else if attr is "color"
        element.attr("style", "fill:#{value}")
      else
        element.attr( attr, value )

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

    setPoisition : ( node, x, y )->
      transformVal = node.transform.baseVal

      if (transformVal.numberOfItems is 1)
        transformVal.getItem(0).setTranslate(x * 10, y * 10)
      else
        translateVal = node.ownerSVGElement.createSVGTransform()
        translateVal.setTranslate(x * 10, y * 10)
        transformVal.appendItem(translateVal)
      null

    position : ( node, x, y, updateLine )->
      if node.length
        node = node[0]

      node.setAttribute( "data-x", x * 10 )
      node.setAttribute( "data-y", y * 10 )

      MC.canvas.position( node, x, y )
      null

    initNode : ( node, x, y )->
      @position( node, x, y )
      @setPortPosition( node )
      null

    setPortPosition : ( node )->
      if node.length then node = node[0]
      for child in node.children || node.childNodes
        if child.tagName is "PATH" or child.tagName is "path"
          x = child.getAttribute("data-x")
          if x is null or x is undefined then continue
          y = child.getAttribute("data-y")
          if y is null or y is undefined then continue

          @setPoisition( child, x / 10, y / 10)
      null

    _getPort : ( node, port1Class )->
      for child in node.children || node.childNodes
          if ( child.getAttribute("class") || "" ).indexOf( port1Class ) != -1
            return child
      null

    drawLine : ( connection )->

      # Calculate the ports
      type_from = connection.port1Comp().type
      type_to   = connection.port2Comp().type
      id_from   = connection.port1Comp().id
      id_to     = connection.port2Comp().id

      item_from = document.getElementById( id_from )
      item_to   = document.getElementById( id_to )

      if not item_from or not item_to
        return

      pos_from  = {
        left : parseInt( item_from.getAttribute( "data-x" ), 10 ) || 0
        top  : parseInt( item_from.getAttribute( "data-y" ), 10 ) || 0
      }
      pos_to  = {
        left : parseInt( item_to.getAttribute( "data-x" ), 10 ) || 0
        top  : parseInt( item_to.getAttribute( "data-y" ), 10 ) || 0
      }

      from_port = "port-" + connection.port1("name")
      to_port   = "port-" + connection.port2("name")

      dirn_from = connection.port1("direction")
      dirn_to   = connection.port2("direction")

      if dirn_from and dirn_to
        if pos_from.left > pos_to.left
          from_port += "-left"
          to_port   += "-right"
        else
          from_port += "-right"
          to_port   += "-left"

        node_from = @_getPort( item_from, from_port )
        node_to   = @_getPort( item_to,   to_port   )

        if not node_from or not node_to
          return

        pos_from.left += parseInt( node_from.getAttribute("data-x"), 10) or 0
        pos_from.top  += parseInt( node_from.getAttribute("data-y"), 10) or 0

        pos_to.left += parseInt( node_to.getAttribute("data-x"), 10) or 0
        pos_to.top  += parseInt( node_to.getAttribute("data-y"), 10) or 0

      else if dirn_from

        node_to = @_getPort( item_to, to_port )
        if not node_to
          return

        pos_to.left += parseInt( node_to.getAttribute("data-x"), 10) or 0
        pos_to.top  += parseInt( node_to.getAttribute("data-y"), 10) or 0

        if dirn_from is "vertical"
          from_port += if pos_to.top > pos_from.top then "-bottom" else "-top"
        else if dirn_from is "horizontal"
          from_port += if pos_to.left > pos_from.left then "-right" else "-left"

        node_from = @_getPort( item_from, from_port )
        if not node_from
          return
        pos_from.left += parseInt( node_from.getAttribute("data-x"), 10) or 0
        pos_from.top  += parseInt( node_from.getAttribute("data-y"), 10) or 0

      else if dirn_to
        node_from = @_getPort( item_from, from_port )
        if not node_from
          return
        pos_from.left += parseInt( node_from.getAttribute("data-x"), 10) or 0
        pos_from.top  += parseInt( node_from.getAttribute("data-y"), 10) or 0

        if dirn_to is "vertical"
          to_port += if pos_from.top > pos_to.top then "-bottom" else "-top"
        else if dirn_to is "horizontal"
          to_port += if pos_from.left > pos_to.left then "-right" else "-left"

        node_to = @_getPort( item_to, to_port )
        if not node_to
          return

        pos_to.left += parseInt( node_to.getAttribute("data-x"), 10) or 0
        pos_to.top  += parseInt( node_to.getAttribute("data-y"), 10) or 0

      else

        node_from = @_getPort( item_from, from_port )
        node_to   = @_getPort( item_to,   to_port   )

        if not node_from or not node_to
          return

        pos_from.left += parseInt( node_from.getAttribute("data-x"), 10 ) or 0
        pos_from.top  += parseInt( node_from.getAttribute("data-y"), 10 ) or 0

        pos_to.left += parseInt( node_to.getAttribute("data-x"), 10 ) or 0
        pos_to.top  += parseInt( node_to.getAttribute("data-y"), 10 ) or 0


      start0 =
        x     : pos_from.left
        y     : pos_from.top
        angle : parseInt( node_from.getAttribute("data-angle"), 10 ) || 0
        type  : type_from
        name  : from_port

      end0 =
        x     : pos_to.left
        y     : pos_to.top
        angle : parseInt( node_to.getAttribute("data-angle"), 10 ) || 0
        type  : type_to
        name  : to_port


      # Calculate line path
      if start0.x is end0.x or start0.y is end0.y
        path = "M#{start0.x} #{start0.y} L#{end0.x} #{end0.y}"
      else
        controlPoints = MC.canvas.route2( start0, end0 )
        if controlPoints
          ls = if connection.get("lineType") is 'sg' then $canvas.lineStyle() else 777

          switch ls
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
          'id'        : connection.id
        })

        document.getElementById( "line_layer" ).appendChild( svg_line[0] )
      null
  }

  CanvasManager
