
define [ "./Design", "./ComplexResModel" ], ( Design, ComplexResModel )->

  GroupModel = ComplexResModel.extend {

    defaults :
      group : true

    ctype : "Framework_G"

    remove : ()->
      console.debug "GroupModel.remove, Removing Children"

      # Remove children
      if @.attributes.__children
        for child in @.attributes.__children
          child.off "REMOVED", @removeChild, @
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

      # Listen child's removal
      child.on "REMOVED", @removeChild, @
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

      child.off "REMOVED", @removeChild, @
      null

    children : ()-> this.get("__children") || []
  }

  GroupModel

