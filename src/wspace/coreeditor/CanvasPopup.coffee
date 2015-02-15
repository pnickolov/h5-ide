
define [ "backbone" ], ()->

  Backbone.View.extend {

    type : "CanvasPopup" # Only one popup of each type allowed.

    attachType  : "float" # "float" || "overlay"
    closeOnBlur : false # Close when the clase is clicked
    className   : "canvas-pp"

    initialize : ( data )->
      console.info "Showing canvas popup"

      console.assert data.canvas
      console.assert data.attachment, "Canvas popup must be attached to some element"

      $.extend @, data

      @$el.appendTo( @canvas.__getCanvasView().parent() )
      @render()


      if @closeOnBlur
        self = @
        @ac = ac = ( evt )-> self.autoclose( evt )

        @canvas.$el[0].addEventListener "mousedown", ac, true


      ceItem = @canvas.getItem($( @attachment ).closest( ".canvasel" ).attr("data-id")) || @attachment

      if not ceItem.__popupCache then ceItem.__popupCache = {}
      oldPoup = ceItem.__popupCache[ @type ]
      ceItem.__popupCache[ @type ] = @
      if oldPoup
        @migrate( oldPoup )
        oldPoup.remove()

      @canvas.registerPopup( @type, @ )
      return

    migrate : ( oldPopup )->

    autoclose : ( evt )->
      popup = $( evt.target ).closest(".canvas-pp")
      if popup.length and popup[0] is @$el[0]
        return false

      @remove()
      true

    render : ()->
      @$el.html( @content() )

      if @attachType is "float"
        @attachFloat()
      else
        @attachOverlay()
      return

    attachFloat : ()->
      attachment    = @attachment.getBoundingClientRect()
      canvaswrapper = @canvas.$el[0].getBoundingClientRect()
      canvasview    = @canvas.__getCanvasView()[0].getBoundingClientRect()

      viewportX = attachment.left - canvaswrapper.left

      width = @$el.outerWidth( true )

      if viewportX > width + 20
        @$el.addClass("pp-left")
        x = attachment.left - canvasview.left - width
      else
        @$el.addClass("pp-right")
        x = attachment.right - canvasview.left

      @$el.css {
        left : x
        top  : attachment.top - canvasview.top + (attachment.height - @$el.outerHeight( true )) / 2
      }
      return

    attachOverlay : ()->
      attachment    = @attachment.getBoundingClientRect()
      canvasview    = @canvas.__getCanvasView()[0].getBoundingClientRect()

      @$el.css {
        left : attachment.left- canvasview.left
        top  : attachment.top - canvasview.top
      }
      return

    remove : ()->
      @canvas.registerPopup( @type, @, false )

      ceItem = @canvas.getItem($( @attachment ).closest( ".canvasel" ).attr("data-id")) || @attachment
      oldPoup = (ceItem.__popupCache || {})[ @type ]
      if oldPoup is @
        delete ceItem.__popupCache[ @type ]

      if @autoclose
        @canvas.$el[0].removeEventListener "mousedown", @ac, true

      if @onRemove then @onRemove()
      Backbone.View.prototype.remove.call this

    # Returns html to be inserted in the popup
    content : ()->

  }
