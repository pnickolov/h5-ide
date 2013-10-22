#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', 'constant' ], ( PropertyModel, constant ) ->

    StaticSubModel = PropertyModel.extend {

        init : ( uid ) ->

            # If this uid is ami uid
            if MC.data.dict_ami[ uid ]
                @set MC.data.dict_ami[ uid ]
                @set "name", "Ami"
                @set "ami", true

            null
    }

    new StaticSubModel()
