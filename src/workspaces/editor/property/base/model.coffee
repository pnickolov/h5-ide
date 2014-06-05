
####################################
#  Base Class for Model of Property Module
####################################

define [ 'backbone', 'Design' ], ( Backbone, Design )->

    ###

    -------------------------------
     PropertyModel is a base class that every property view should inherit.
    -------------------------------

    ###

    PropertyModel = Backbone.Model.extend {

        init : () ->
            null

        setName : ( name )->
            id = @get("uid")
            console.assert( id, "This property model doesn't have an id" )

            Design.instance().component( id ).setName( name )
            @set "name", name
            null


        isNameDup : ( newName )->

            id = @get("uid")
            console.assert( id, "This property model doesn't have an id" )

            comp = Design.instance().component( id )

            if comp.get("name") is newName
                return false

            dup = false
            Design.instance().eachComponent ( comp )->
                if comp.get("name") is newName
                    dup = true
                    return false

            dup

        isReservedName : ( newName ) ->

            result = false
            if newName in ['self', 'this', 'global', 'meta', 'madeira']
                result = true

            return result
    }

    PropertyModel
