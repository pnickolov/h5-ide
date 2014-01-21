define ["text!./diff.html", "text!./view.html", "./JsonDiffLib", "./jqUi" ], ( tplDiff, tplView, jsond )->

  tplDiff = Handlebars.compile tplDiff
  tplView = Handlebars.compile tplView

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

      jsond.compare( json1, json2, "root", $("#jsondiffContainer")[0] )

      $("#modal-box").on "click", "ul", ( e )->
        if e.target.tagName and e.target.tagName.toUpperCase() is "UL"
          $(e.target).toggleClass("closed")
        false

      $("#diffTextarea1, #diffTextarea2").on "focus", ()->
        $(this).select()
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

      showChangesOnly = ()->
        if $("#diffChangesOnly").is(":checked")
          $("#jsondiffContainer").toggleClass("changesOnly", true)
          $("#jsondiffContainer").find(".changed, .added, .removed").each ( idx, el )->
            p = $(el).parent()
            while p.attr("id") isnt "jsondiffContainer"
              p.toggleClass("hasChanges", true)
              p = p.parent()
            null

        else
          $("#jsondiffContainer").removeClass("changesOnly")

        null

      $("#diffChangesOnly").on "change", (e)->
        showChangesOnly()
        null

      null


    showViewDialog : ( canvas_data )->
      $( tplView() ).appendTo( "body" ).resizable().draggable({handle:".modal-header"})

      component = canvas_data.component
      layout    = canvas_data.layout

      delete canvas_data.component
      delete canvas_data.layout

      attributes = $.extend true, {}, canvas_data
      jsond.compare( attributes, attributes, "attributes", $("#jsonAttrContainer").empty()[0] )
      jsond.compare( component, component, "components", $("#jsonCompContainer").empty()[0] )
      jsond.compare( layout, layout, "layouts", $("#jsonLayoutContainer").empty()[0] )

      $("#jsonViewer").on "click", "ul", ( e )->
        if e.target.tagName and e.target.tagName.toUpperCase() is "UL"
          $(e.target).toggleClass("closed")
        false

      $("#jsonViewer").on "dblclick", ".modal-header", ()->
        $wrap = $("#diffWrap")
        if $wrap.is(":hidden")
          $("#jsonViewer").css({"height": $("#jsonViewer").attr("data-height") || "70%" })
          $wrap.show()
        else
          $("#jsonViewer").attr({"data-height": $("#jsonViewer").height()}).css({"height":"auto"})
          $wrap.hide()
        null

      $("#jsonViewer").on "click", ".modal-close", ()->
        $("#jsonViewer").remove()
        null

      null
  }


