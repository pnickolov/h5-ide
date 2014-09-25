
define ["constant"], (constant)->

  CanvasManager = {

    hasClass : ( elements, klass )->
      if not elements
        return false

      if not elements.length and elements.length isnt 0 then elements = [ elements ]

      for element in elements
        k = " " + (element.getAttribute("class") || "") + " "
        if k.indexOf( " #{klass} " ) >= 0
          return true

      false

    removeClass : ( elements, theClass )->
      if not elements
        return this

      if not elements.length and elements.length isnt 0 then elements = [ elements ]

      for element in elements
        klass = element.getAttribute("class") || ""
        newKlass = klass.replace( new RegExp("\\b#{theClass}\\b", "g"), "" )

        if klass isnt newKlass
          element.setAttribute "class", newKlass

      return this

    addClass : ( elements, theClass )->
      if not elements
        return this

      if not elements.length and elements.length isnt 0 then elements = [ elements ]

      for element in elements
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
        element.setAttribute "display", ""
        if element.getAttribute "data-tooltip"
          @addClass element, "tooltip"
      else
        element.setAttribute "display", "none"
        @removeClass element, "tooltip"

      return this

    updateEip : ( node, targetModel )->
      if node.length then node = node[0]

      toggle = targetModel.hasPrimaryEip()

      if toggle
        tootipStr = 'Detach Elastic IP from primary IP'
        imgUrl    = 'ide/icon/icn-eipon.png'
      else
        tootipStr = 'Associate Elastic IP to primary IP'
        imgUrl    = 'ide/icon/icn-eipoff.png'

      if targetModel.design().modeIsApp()
        if targetModel.getEmbedEni then targetModel = targetModel.getEmbedEni()
        if targetModel
          ip = (targetModel.get("ips") || [])[0]
          tootipStr = ip?.eipData?.publicIp || ""
        else
          console.warn "updateEip(): can not found EmbedEni"

      node.setAttribute "data-tooltip", tootipStr

      $( node ).data("tooltip", tootipStr)

      this.update( node, imgUrl, "href" )

      null

    updateFip : ( node, targetModel )->
      if not node.size() then return false
      if node.length then node = node[0]

      if targetModel.type is constant.RESTYPE.OSSERVER
        toggle = !!targetModel.embedPort().getFloatingIp()

      if toggle
        tootipStr = 'Detach Floating IP'
        imgUrl    = 'ide/icon/openstack/icn-fipon.png'
      else
        tootipStr = 'Associate Floating IP'
        imgUrl    = 'ide/icon/openstack/icn-fipoff.png'

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

        for el in element
          href = el.getAttributeNS("http://www.w3.org/1999/xlink", "href")
          if href isnt value
            el.setAttributeNS("http://www.w3.org/1999/xlink", "href", value)

      else if attr is "tooltip"
        element.data("tooltip", value).attr("data-tooltip", value)
        for el in element
          if value
            CanvasManager.addClass( el, "tooltip" )
          else
            CanvasManager.removeClass( el, "tooltip" )

      else if attr is "color"
        element.attr("style", "fill:#{value}")
      else
        element.attr( attr, value )

    setLabel : ( canvasItem, labelElement )->

      text     = canvasItem.label()
      maxWidth = canvasItem.labelWidth()

      if _.isString labelElement
        labelElement = document.getElementById( labelElement )

      if not labelElement.length and labelElement.length isnt 0 then labelElement = [ labelElement ]

      if not text.length
        $( labelElement ).text( text )
        # If the text is empty, return now. Since the getSubStringLength will throw error.
        return

      $(labelElement[0]).text( text )
      try
        # There's a bug in webkit browser.
        # If the text element is not displayed, then its internal textLength would be 0
        # Resulting getSubStringLength will throw error.
        currentLength = labelElement[0].getSubStringLength(0, text.length)
      catch e
        currentLength = 0

      if currentLength > maxWidth
        length = text.length - 1
        while true and length > 0
          if labelElement[0].getSubStringLength(0, length) + 8 <= maxWidth
            text = text.substr( 0, length ) + "..."
            break
          --length

      for el in labelElement
        $(el).text( text )

      return
  }

  CanvasManager
