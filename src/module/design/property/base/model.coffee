
####################################
#  Base Class for Model of Property Module
####################################

define [ 'backbone' ], ( Backbone )->

    ###

    -------------------------------
     PropertyModel is a base class that every property view should inherit. Currently it does nothing.
    -------------------------------

    ###

    PropertyModel = Backbone.Model.extend {

      init : () ->
        null

    }

    PropertyModel
