
define [ "Design", "./ComplexResModel" ], ( Design, ComplexResModel )->

  GroupModel = ComplexResModel.extend {

    node_group : true
    type       : "Framework_G"

    remove : ()->
      console.debug "GroupModel.remove, Removing Children"

      # Remove children
      if @.attributes.__children
        for child in @.attributes.__children
          child.off "remove", @removeChild, @
          child.remove()
      null

    addChild : ( child )->
      console.assert( child.remove, "This child is not a ResourceModel object" )

      children = @.attributes.__children

      if not children
        children = []

      else if children.indexOf( child ) != -1
        return

      children.push( child )
      @set("__children", children)

      # Set child's parent to this
      child.set("__parent", this)

      # Listen child's removal
      child.on "remove", @removeChild, @
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

      child.off "remove", @removeChild, @
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
                .attr({'class':'resizer-top'}),

          Canvon.rectangle( 0, pad, pad, height - 2 * pad )
                .attr({'class':'resizer-left'}),

          Canvon.rectangle( width - pad, pad, pad, height - 2 * pad )
                .attr({'class':'resizer-right'}),

          Canvon.rectangle( pad, height - pad, width - 2 * pad, pad )
                .attr({'class':'resizer-bottom'}),

          Canvon.rectangle( 0, 0, pad, pad )
                .attr({'class':'resizer-topleft'}),

          Canvon.rectangle( width - pad, 0, pad, pad )
                .attr({'class':'resizer-topright'}),

          Canvon.rectangle( 0, height - pad, pad, pad )
                .attr({'class':'resizer-bottomleft'}),

          Canvon.rectangle( width - pad, height - pad, pad, pad )
                .attr({'class':'resizer-bottomright'})

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

