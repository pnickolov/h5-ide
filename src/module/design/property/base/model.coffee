
####################################
#  Base Class for Model of Property Module
####################################

define [ 'backbone', 'Design' ], ( Backbone, Design )->

    ###

    -------------------------------
     PropertyModel is a base class that every property view should inherit. Currently it does nothing.
    -------------------------------

    ###

    PropertyModel = Backbone.Model.extend {

        init : () ->
            null

        setName : ( name )->
            id = @get("uid")
            console.assert( id, "This property model doesn't have an id" )

            Design.instance().component( id ).setName( name )
            null


        isNameDup : ( newName )->

            id = @get("uid")
            console.assert( id, "This property model doesn't have an id" )

            comp = Design.instance().component( id )

            if comp.get("name") is newName
                return false

            _.some Design.modelClassForType( comp.type ).allObjects(), ( obj )->
                obj.get("name") is newName
    }

    PropertyModel
