define ["event", "./diff", "./view", "./JsonDiffLib", "./jqUi" ], (ide_event, tplDiff, tplView, jsond )->

  componentData = null
  selectedComponetUid = "."

  ide_event.on ide_event.OPEN_PROPERTY, ( type, id )->
    if $("#jsonViewer").length
      selectedComponetUid = id || "."
      applyViewFilter()
    null

  showChangesOnly = ()->
    if $("#diffChangesOnly").is(":checked")
      $("#jsondiffContainer").toggleClass("changesOnly", true)
      $("#jsondiffContainer").find(".changed, .added, .removed").each ( idx, el )->
        p = $(el).parent()
        while p.attr("id") isnt "jsondiffContainer"
          p.toggleClass("hasChanges", true).removeClass("closed")
          p = p.parent()
        null

    else
      $("#jsondiffContainer").removeClass("changesOnly")

    null

  applyViewFilter = ()->
    filterText = $.trim( $("#diffSearch").val() )
    filterType = $("#diffTypeSelect").val() or "."

    shown = 0
    shownTarget = null

    for uidChild in $("#jsonCompContainer").children().children("li").children().children("span")

      uidChild = $(uidChild)

      uid = uidChild.children(":first-child").text().replace(": ", "")
      comp = componentData[ uid ]
      if not filterText or comp.uid.indexOf( filterText ) isnt -1 or comp.type.indexOf( filterText ) isnt -1 or comp.name.indexOf( filterText ) isnt -1
        show = true
      else
        show = false

      if filterType is "selected"
        if comp.uid isnt selectedComponetUid and selectedComponetUid isnt "."
          show = false
      else if comp.type.indexOf( filterType ) is -1
        show = false

      if show
        ++shown
        shownTarget = uidChild.parent()

      if show
        uidChild.parent().parent().css({ "display" : "" })
      else
        uidChild.parent().parent().css({ "display" : "none" })

    if selectedComponetUid is "." and filterType is "selected"
      $("#jsonCompContainer").children().children("li").children().addClass("closed")
    else
      if shown is 1
        shownTarget.removeClass("closed")
    null


  updateViewDialog = ( canvas_data )->
    component = canvas_data.component
    layout    = canvas_data.layout

    delete canvas_data.component
    delete canvas_data.layout

    componentData = component

    attributes = $.extend true, {}, canvas_data
    jsond.compare( attributes, attributes, "attribute", $("#jsonAttrContainer").empty()[0] )
    jsond.compare( component, component, "component", $("#jsonCompContainer").empty()[0] )
    jsond.compare( layout, layout, "layout", $("#jsonLayoutContainer").empty()[0] )

    $("#jsonCompContainer, #jsonAttrContainer, #jsonLayoutContainer").children().removeClass("closed")

    typeMap = {}
    typeArr = []
    for uid, comp of component
      if not typeMap[ comp.type ]
        typeMap[ comp.type ] = true
        typeArr.push comp.type

    selectOptions = "<option value='.'>All</option><option value='selected' selected='selected'>Selected Component</option><option value='.'>----------</option>"

    if $canvas.selected_node().length
      selectedComponetUid = $canvas.selected_node()[0]
    else
      selectedComponetUid = "."

    for type in typeArr.sort()
      selectOptions += "<option value='#{type}'>#{type}</option>"

    $("#diffTypeSelect").html(selectOptions)

    applyViewFilter()
    null



  {
    showDiffDialog : ( json1, json2 )->
      modal tplDiff()

      $("#modal-box").css({
        width  : "98%"
        height : "98%"
        top    : "1%"
        left   : "1%"
      })

      $("#diffTextarea1").val(JSON.stringify(json1))
      $("#diffTextarea2").val(JSON.stringify(json2))

      jsond.compare( json1, json2, "CanvasData", $("#jsondiffContainer")[0] )

      $("#modal-box").on "click", "ul", ( e )->
        if e.target.tagName and e.target.tagName.toUpperCase() is "UL"
          $(e.target).toggleClass("closed")
        false

      $("#diffTextarea1, #diffTextarea2").on "focus", ()->
        setTimeout (()=>$(this).select()), 10
        null

      $("#diffSwap").on "click", ()->
        j1 = $("#diffTextarea1").val()
        $("#diffTextarea1").val( $("#diffTextarea2").val() )
        $("#diffTextarea2").val( j1 )
        null

      $("#diffClear").on "click", ()->
        $("#diffTextarea1").val( "" )
        $("#diffTextarea2").val( "" )
        null

      $("#diffCompare").on "click", ()->
        try
          j1 = JSON.parse( $("#diffTextarea1").css({"background":""}).val() )
        catch e
          $("#diffTextarea1").css({"background" : "res"})

        try
          j2 = JSON.parse( $("#diffTextarea2").css({"background":""}).val() )
        catch e
          $("#diffTextarea2").css({"background" : "res"})

        if j1 and j2
          jsond.compare( j1, j2, "CanvasData", $("#jsondiffContainer").empty()[0] )

        showChangesOnly()
        null

      showChangesOnly()

      $("#diffChangesOnly").on "change", (e)->
        showChangesOnly()
        null

      null


    showViewDialog : ( canvas_data )->

      if $("#jsonViewer").length
        $("#diffWrap").hide()
        $("#jsonViewer .modal-header").dblclick()
        return null

      $( tplView() ).appendTo( "body" ).resizable().draggable({handle:".modal-header"})

      w = localStorage.getItem "debug/jsonViewW"
      h = localStorage.getItem "debug/jsonViewH"
      if w and h
        $("#jsonViewer").width(w).height(h)

      updateViewDialog( canvas_data )

      $("#jsonViewer").on "click", "ul", ( e )->
        if e.target.tagName and e.target.tagName.toUpperCase() is "UL"
          $(e.target).toggleClass("closed")
        false

      $("#jsonViewer").on "dblclick", ".modal-header", ()->
        $wrap = $("#diffWrap")
        if $wrap.is(":hidden")
          $("#jsonViewer").css({
            "height" : $("#jsonViewer").attr("data-height") || "70%"
            "width"  : $("#jsonViewer").attr("data-width")  || "50%"
            "min-width" : "540px"
          })
          $wrap.show()
        else
          $("#jsonViewer").attr({
            "data-height" : $("#jsonViewer").height()
            "data-width"  : $("#jsonViewer").width()
          }).css({"height":"auto","width":"150px","min-width":"150px"})
          $wrap.hide()
        null

      $("#jsonViewer").on "click", ".modal-close", ()->
        localStorage.setItem "debug/jsonViewW", $("#jsonViewer").width()
        localStorage.setItem "debug/jsonViewH", $("#jsonViewer").height()
        $("#jsonViewer").remove()
        null

      $("#diffRefresh").on "click", ()-> updateViewDialog( d().serialize() )

      updateTO = null
      $("#diffSearch").on "keydown", ()->
        if updateTO then clearTimeout( updateTO )
        updateTO = setTimeout ()->
          applyViewFilter()
        , 200
        null

      $("#diffTypeSelect").on "change", applyViewFilter
      null
  }


