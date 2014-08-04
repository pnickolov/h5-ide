
####################################
#  Base Class for Model of Property Module
####################################

define [ 'backbone', 'Design', "constant" ], ( Backbone, Design, constant )->

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
    }

    PropertyModel
