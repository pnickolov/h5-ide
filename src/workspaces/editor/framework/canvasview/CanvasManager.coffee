
define ['CloudResources'], (CloudResources)->

  CanvasManager = {

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

      if targetModel.design().modeIsApp() or targetModel.design().modeIsAppView()
        resource_list = CloudResources(targetModel.type, targetModel.design().region())
        res = resource_list.get(targetModel.get('appId'))
        if toggle and res
          res = res.toJSON()
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
        element.text( MC.truncate value, 17 )
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

      MC.canvas.position( node, x, y )
      null
  }

  CanvasManager
