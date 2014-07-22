
define [ "backbone" ], ()->

  Backbone.View.extend {

    type : "CanvasPopup" # Only one popup of each type allowed.

    attachType  : "float" # "float" || "overlay"
    closeOnBlur : false # Close when the clase is clicked
    className   : "canvas-pp"

    initialize : ( data )->
      console.assert data.canvas

      console.info "Showing canvas popup"

      canvas = data.canvas
      if not canvas.__popupCache then canvas.__popupCache = {}
      if canvas.__popupCache[ @type ] then canvas.__popupCache[ @type ].remove()
      canvas.__popupCache[ @type ] = @

      $.extend @, data

      @$el.insertAfter( @canvas.__getCanvasView() )

      @render()

      if @closeOnBlur
        self = @
        ac = ( evt )->
          if self.autoclose( evt )
            self.canvas.$el[0].removeEventListener "mousedown", ac, true
          return

        @canvas.$el[0].addEventListener "mousedown", ac, true
      return

    autoclose : ( evt )->
      popup = $( evt.target ).closest(".canvas-pp")
      if popup.length and popup[0] is @$el[0]
        return false

      @remove()
      true

    render : ()->
      @$el.html( @content() )
      @attachTo( @attachment )
      return

    attachTo : ( svgNodeOrCanvasElement )->
      if svgNodeOrCanvasElement.$el
        @attachment = svgNodeOrCanvasElement.$el[0]
      else
        @attachment = svgNodeOrCanvasElement

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
      @canvas.__popupCache[ @type ] = null
      if @onRemove then @onRemove()
      Backbone.View.prototype.remove.call this

    # Returns html to be inserted in the popup
    content : ()->

  }
