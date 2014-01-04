
define [ "Design", "./ComplexResModel" ], ( Design, ComplexResModel )->

  GroupModel = ComplexResModel.extend {

    node_group : true
    type       : "Framework_G"

    remove : ()->
      # Remove children
      if @attributes.__children
        for child in @attributes.__children
          child.off "destroy", @removeChild, @
          child.remove()
      null

    addChild : ( child )->
      console.assert( child.remove, "This child is not a ResourceModel object" )

      # Remove from old parent
      oldParent = child.parent()
      if oldParent is this then return

      if oldParent
        oldParent.removeChild( child )

      # Add to this parent
      children = @attributes.__children

      if not children
        children = []

      else if children.indexOf( child ) != -1
        return

      children.push( child )
      @set("__children", children)

      # Set child's parent to this
      child.set("__parent", this)

      # Listen child's removal
      child.once "destroy", @removeChild, @

      # Trigger child's callback
      if child.onParentChanged then child.onParentChanged()
      null

    removeChild : ( child )->
      children = @get("__children")

      if not children or children.length == 0
        console.warn "Child not found when removing."
        return

      idx = children.indexOf( child )
      if idx == -1
        console.warn "Child not found when removing."
        return

      children.splice( idx, 1 )

      @set("__children", children)

      child.off "destroy", @removeChild, @
      null

    children : ()-> this.get("__children") || []

    createNode : ( name )->
      # A helper function to create a SVG Element to represent a group
      x      = @x()
      y      = @y()
      width  = @width()  * MC.canvas.GRID_WIDTH
      height = @height() * MC.canvas.GRID_HEIGHT

      text_pos = MC.canvas.GROUP_LABEL_COORDINATE[ @type ]

      pad = 10


      Canvon.group().append(
        Canvon.rectangle( 0, 0, width, height ).attr({
          'class' : 'group'
          'rx'    : 5
          'ry'    : 5
        }),

        Canvon.group().append(
          Canvon.rectangle( pad, 0, width - 2 * pad, pad )
                .attr({
                  'class':'group-resizer resizer-top'
                  'data-direction':'top'
                }),

          Canvon.rectangle( 0, pad, pad, height - 2 * pad )
                .attr({
                  'class':'group-resizer resizer-left'
                  'data-direction':'left'
                }),

          Canvon.rectangle( width - pad, pad, pad, height - 2 * pad )
                .attr({
                  'class':'group-resizer resizer-right'
                  "data-direction":"right"
                }),

          Canvon.rectangle( pad, height - pad, width - 2 * pad, pad )
                .attr({
                  'class':'group-resizer resizer-bottom'
                  "data-direction":"bottom"
                }),

          Canvon.rectangle( 0, 0, pad, pad )
                .attr({
                  'class':'group-resizer resizer-topleft'
                  "data-direction":"topleft"
                }),

          Canvon.rectangle( width - pad, 0, pad, pad )
                .attr({
                  'class':'group-resizer resizer-topright'
                  "data-direction":"topright"
                }),

          Canvon.rectangle( 0, height - pad, pad, pad )
                .attr({
                  'class':'group-resizer resizer-bottomleft'
                  "data-direction":"bottomleft"
                }),

          Canvon.rectangle( width - pad, height - pad, pad, pad )
                .attr({
                  'class':'group-resizer resizer-bottomright'
                  "data-direction":"bottomright"
                })

        ).attr({'class':'resizer-wrap'}),

        Canvon.text(text_pos[0], text_pos[1], name).attr({
          'class' : 'group-label name'
        })
      ).attr({
        'id'         : @id
        'class'      : 'dragable ' + @type.replace(/\./g, "-")
        'data-type'  : 'group'
        'data-class' : @type
      })
  }

  GroupModel

