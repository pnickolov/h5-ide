#############################
#  View Mode for design/property/instance (app)
#############################

define [ '../base/model' ], ( PropertyModel ) ->

    AmiAppEditModel = PropertyModel.extend {

        init : ( uid ) ->
            null

    }

    new AmiAppEditModel()
