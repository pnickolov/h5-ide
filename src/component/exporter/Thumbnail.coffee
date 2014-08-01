
define ['UI.canvg', 'component/exporter/Download'], ()->

  GridBackground      = undefined
  ThumbGridBackground = undefined
  DefsTpl             = undefined
  Href                = undefined

  exportBeforeRender = (ctx) ->
    cWidth  = ctx.canvas.clientWidth  || ctx.canvas.width
    cHeight = ctx.canvas.clientHeight || ctx.canvas.height

    orgFS = ctx.fillStyle
    ctx.fillStyle = ctx.createPattern(GridBackground, "repeat")
    ctx.fillRect( 0, 54, cWidth, cHeight - 54 )
    ctx.fillStyle = orgFS
    null

  thumbBeforeRender = (ctx) ->
    cWidth  = ctx.canvas.clientWidth  || ctx.canvas.width
    cHeight = ctx.canvas.clientHeight || ctx.canvas.height

    if cWidth  > 1500 then cWidth = 1500
    if cHeight > 1000 then cWidth = 1000

    ratio1 = 228 / cWidth
    ratio2 = 150 / cHeight
    ratio  = if ratio1 <= ratio2 then ratio2 else ratio1

    ctx.canvas.width  = 228
    ctx.canvas.height = 150
    ctx.fillStyle = ctx.createPattern(ThumbGridBackground, "repeat")
    ctx.fillRect 0, 0, cWidth, cHeight
    ctx.scale ratio, ratio
    null

  prepareDefTpl = ()->
    clone = $("#svgDefs")[0].cloneNode( true )
    clone.setAttribute "xmlns:xlink", "http://www.w3.org/1999/xlink"

    $("#ExportPngWrap").append( clone )

    for ch in clone.children or clone.childNodes
      if not ch.tagName then continue
      fixSVG ch, [], true

    DefsTpl = (new XMLSerializer()).serializeToString(clone).replace(/^<svg[^>]+>/, "").replace(/<\/svg>$/,"").replace(/(fill:rgb\(0, 0, 0\)|stroke:none);?/g, "")
    return

  exportPNG = ( $svg_canvas_element, data ) ->
    #
    # data = {
    #   isExport   : boolean
    #   size       : { width : x, height : x }
    #   createBlob : false
    #   drawInfo   : true
    #   onFinish   : function (required)
    #   name       : string
    # }
    #
    if not data.onFinish then return

    # Insert the document so that we can calculate the style.
    $wrap = $("#ExportPngWrap")
    if not $wrap.length
      $wrap = $("<div id='ExportPngWrap'></div>").appendTo("body").hide()


    # Prepare grid background
    if not GridBackground
      GridBackground = document.createElement("img")
      GridBackground.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAIAAAACUFjqAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAHUlEQVQYV2P48ePHf9yAgabSHz9+/I4bENI9gNIA0iYpJd74eOIAAAAASUVORK5CYII="
      ThumbGridBackground = document.createElement("img")
      ThumbGridBackground.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAMAAABh9kWNAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAAAZQTFRF9fX1////0eouzwAAABRJREFUeNpiYGBkZGBkYABhgAADAAApAAUR1P0IAAAAAElFTkSuQmCC"

      prepareDefTpl()


    clone = $svg_canvas_element[0].cloneNode(true)
    size  = $svg_canvas_element[0].getBBox()

    # cloneNode won't clone the xmlns:xlink attribute
    clone.setAttribute "xmlns:xlink", "http://www.w3.org/1999/xlink"

    $wrap.append(clone)

    # Inline styles
    removeArray = [ clone ] # Detach the clone from document.
    children = clone.children or clone.childNodes

    for ch in children
      if not ch.tagName then continue
      fixSVG ch, removeArray

    # Remove unnecessary elements
    for ch in removeArray
      if ch.remove then ch.remove() else ch.parentNode.removeChild ch

    origin = { x : 0, y : 0 }
    # Prepare to insert header for Exporting Image
    if data.isExport
      # Get each layouts BBox and calc the best origin of the export image.
      origin = { x : size.width, y : size.height }
      for ch in ($svg_canvas_element[0].children or $svg_canvas_element[0].childNodes)
        if (not ch.tagName) or (ch.tagName.toLowerCase() isnt "g") then continue
        bbox = ch.getBBox()
        if not (bbox.x + bbox.y + bbox.width + bbox.height)
          continue
        if bbox.x < origin.x then origin.x = bbox.x
        if bbox.y < origin.y then origin.y = bbox.y
      origin.x -= 30
      origin.y -= 30


    replaceEl = document.createElementNS("http://www.w3.org/2000/svg", "g")
    replaceEl.textContent = "PLACEHOLDER"
    clone.insertBefore replaceEl, children[0]

    # Generate svg text, and remove data attributes
    svg = (new XMLSerializer()).serializeToString(clone)#.replace(/data-[^=<>]+="[^"]*?"/g, "")

    insertTpl = DefsTpl

    # Insert header
    if data.isExport
      # In IE, XMLSerializer will change xlink:href to href
      Href = (if svg.indexOf("xlink:href") is -1 then "href" else "xlink:href")  if Href is undefined
      time = ""
      name = ""
      if data.drawInfo isnt false
        time = MC.dateFormat(new Date(), "yyyy-MM-dd hh:mm:ss")
        name = data.name

      # We use canvg's translate instead of calling context.translate()
      # because context.translate seems a little bit slow.
      svg = svg.replace("</svg>", "</g></svg>")
      insertTpl += """<g transform='translate(#{-origin.x} #{54-origin.y})'>
<g transform='translate(#{origin.x} #{origin.y-54})'>
  <rect fill='#3b1252' width='100%' height='4'></rect>
  <rect fill='#723197' width='100%' height='50' y='4'></rect>
  <image #{Href}='/assets/images/ide/logo-t.png?v=2' x='10' y='11' width='116' height='35'></image>
  <text x='100%' y='40' fill='#fff' text-anchor='end' transform='translate(-10 0)'>#{time}</text>
  <text x='100%' y='24' fill='#fff' text-anchor='end' transform='translate(-10 0)'>#{name}</text>
</g>
"""

    svg = svg.replace("<g>PLACEHOLDER</g>", insertTpl)

    # Calc the size for the canvas
    # In IE, getBBox returns SvgRect which is not allowed to modified.
    size =
      width  : size.width  + 30*2
      height : size.height + 30*2


    # Calc the perfect size
    if data.isExport
      size.height += 54
      if size.width  < 360 then size.width  = 360
      if size.height < 380 then size.height = 380
      beforeRender = exportBeforeRender
    else
      beforeRender = thumbBeforeRender

    # Draw
    canvas = document.createElement("canvas")
    canvas.width  = size.width
    canvas.height = size.height

    canvg canvas, svg,
      beforeRender : beforeRender
      afterRender  : ()->
        onFinish = data.onFinish
        data.onFinish = null
        if data.createBlob is true
          canvas.toBlob (blob, possibleDataURL) ->
            if typeof possibleDataURL is "string"

              # We are using an 3rd party implementation of toBlob
              # And we get the DataURL.
              data.image = possibleDataURL
            else
              data.image = canvas.toDataURL()
            data.blob = blob
            onFinish data

        else
          data.image = canvas.toDataURL()
          onFinish data

  svgHasClass = ( svg, test )->
    if svg.classList
      svg.classList.contains( test )
    else
      (svg.getAttribute("class") || "").indexOf( test ) isnt -1

  fixSVG = (element, removeArray, keepDefaultStyle ) ->
    tagName = element.tagName.toLowerCase()

    # Remove <defs/>, empty <g/> and rect.group-resizer, .fill-line
    children = element.children or element.childNodes

    switch tagName
      when "g"
        remove = children.length is 0
      when "path"
        remove = svgHasClass( element, "fill-line" )
      when "rect"
        remove = svgHasClass( element, "group-resizer" )

    if remove then return removeArray.push(element)

    ss = window.getComputedStyle(element)

    # Remove non-visual element
    if ss.visibility is "hidden" or ss.display is "none" or ss.opacity is "0"
      return removeArray.push(element)

    # Store the inline stylesheet in stylez
    s = []
    s.push "opacity:#{ss.opacity}" if "" + ss.opacity isnt "1"
    if tagName isnt "g" and tagName isnt "image" and tagName isnt "defs"

      # Fill
      fo = "" + ss.fillOpacity
      if not keepDefaultStyle and ( fo is "0" or ss.fill.match(/rgba\([^)]+0\)/) )
        s.push "fill:none"
      else
        s.push "fill:#{ss.fill}"                if ss.fill isnt "#000000"
        s.push "fill-opacity:#{ss.fillOpacity}" if fo isnt "1"

      # Stroke
      t1 = (ss.strokeWidth + "").replace("px", "")
      fo = "" + ss.strokeOpacity

      if not keepDefaultStyle and ( "" + ss.strokeWidth is "0" or fo is "0" )
        s.push "stroke:none"
      else
        s.push "stroke:#{ss.stroke}"
        s.push "stroke-width:#{ss.strokeWidth}"     if t1 isnt "1"
        s.push "stroke-opacity:#{ss.strokeOpacity}" if fo isnt "1"

      s.push "stroke-linejoin:#{ss.strokeLinejoin}"   if ss.strokeLinejoin  isnt "miter"
      s.push "stroke-dasharray:#{ss.strokeDasharray}" if ss.strokeDasharray isnt "none"

      # Text ( Font-family is hard coded in UI.canvg )
      if tagName is "text"
        s.push "font-size:#{ss.fontSize}" if ss.fontSize isnt "14px"
        s.push "text-anchor:#{ss.textAnchor}" if ss.textAnchor isnt "start"

    if s.length then element.setAttribute "stylez", s.join(";")

    for ch in children
      if not ch.tagName then continue
      fixSVG ch, removeArray, keepDefaultStyle
      ch.removeAttribute "data-id"
      ch.removeAttribute "data-tooltip"
    null

  saveThumbnailFinish = ( data )->
    cache = localStorage.getItem("thumbnails") or ""
    c = "#{data.id},"
    index = cache.indexOf c

    if index == -1
      if localStorage.length > 300
        firstIndex = cache.indexOf(",")
        localStorage.removeItem "tn/" + cache.substring(0, firstIndex)
        cache = cache.substring(firstIndex)
    else
      cache = cache.replace(c,"")

    localStorage.setItem "thumbnails", cache + c
    localStorage.setItem "tn/#{data.id}", data.image
    null

  createThumbnail = ( $svg_element, size )->
    defer = Q.defer()
    exportPNG $svg_element, {
      size     : size
      onFinish : ( data )-> defer.resolve( data.image || "" )
    }

    defer.promise

  saveThumbnail = ( id, $svg_element, size )->
    if typeof $svg_element is "string"
      saveThumbnailFinish {
        id    : id
        image : $svg_element
      }
    else
      exportPNG $svg_element, {
        id       : id
        size     : size
        onFinish : saveThumbnailFinish
      }
    null

  getThumbnail = ( id )->
    localStorage.getItem "tn/#{id}"

  removeThumbnail = ( id )->
    if not id then return
    cache = localStorage.getItem("thumbnails") or ""
    localStorage.setItem "thumbnails", cache.replace("#{id},","")

    localStorage.removeItem "tn/#{id}"
    null

  cleanupThumbnail = ( keepArray )->
    validId = {}
    for keepId in keepArray
      validId[ keepId ] = true

    # Remove expired thumbnail
    oldArray    = (localStorage.getItem("thumbnails") or "").split(",")
    removeArray = []
    keepArray   = []
    for id in oldArray
      if not id then continue
      if validId[ id ]
        keepArray.push id
      else
        removeArray.push id

    if removeArray.length
      if keepArray.length
        c = keepArray.join(",") + ","

      localStorage.setItem "thumbnails", c || ""
      for id in removeArray
        localStorage.removeItem "tn/#{id}"
      console.debug "Cleaning up unused thumbnails:", removeArray
    null

  {
    exportPNG : exportPNG

    # Returns a promise when the thumbnail is created.
    generate  : createThumbnail

    save      : saveThumbnail
    fetch     : getThumbnail
    remove    : removeThumbnail
    cleanup   : cleanupThumbnail
  }
