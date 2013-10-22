####################################
#  Controller for design/property/cgw module
####################################

define [ '../base/main',
         './model',
         './view'
], ( PropertyModule, model, view ) ->

    ConnectionModule = PropertyModule.extend {

        handleTypes : [ "eni-attach>instance-attach", "elb-assoc>subnet-assoc-in" ]

        initStack : ()->
            @model = model
            @view  = view
            null

        initApp : () ->
            @model = model
            @view  = view
            null
    }
    null
