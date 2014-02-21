
define [ "Design", "./ComplexResModel" ], ( Design, ComplexResModel )->

  GroupModel = ComplexResModel.extend {

    node_group : true
    type       : "Framework_G"

    remove : ()->
      # Remove children
      if @attributes.__children
        # Need to copy the __children first.
        # Because when we removes a child, the child might just remove another child
        # Since the remove() will do nothing if the child is removed, so we can
        # remove() a child multiple times.
        for child in @attributes.__children.splice(0)
          child.off "destroy", @removeChild, @
          child.remove()

      ComplexResModel.prototype.remove.call this
      null

    addChild : ( child )->
      ###
      addChild.call(this) # This is used to suppress the warning in ResourceModel.extend.
      ###

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
      ###
      removeChild.call(this) # This is used to suppress the warning in ResourceModel.extend.
      ###

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

    generateLayout : ()->
      layout = ComplexResModel.prototype.generateLayout.call this
      layout.size = [ @width(), @height() ]
      layout
  }

  GroupModel

