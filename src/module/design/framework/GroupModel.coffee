
define [ "./Design", "./ComplexResModel" ], ( Design, ComplexResModel )->

  GroupModel = ComplexResModel.extend {

    defaults :
      __children : []

    ctype : "Framework_G"

    remove : ()->
      console.debug "GroupModel.remove, Removing Children"

      # Remove children
      for child in @.attributes.__children
        child.off "REMOVED", @removeChild, @
        child.remove()
      null

    addChild : ( child )->
      console.assert( child.remove, "This child is not a ResourceModel object" )

      if @attributes.__children.indexOf( child ) != -1
        return

      children = @get("__children")
      children.push( child )
      @set("__children", children)

      # Listen child's removal
      child.on "REMOVED", @removeChild, @
      null

    removeChild : ( child )->
      children = @get("__children")
      children.splice( children.indexOf( child ), 1 )

      @set("__children", children)

      child.off "REMOVED", @removeChild, @
      null

    children : ()-> this.get("__children")
  }

  GroupModel

