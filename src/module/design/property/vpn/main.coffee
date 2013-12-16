####################################
#  Controller for design/property/vpn module
####################################

define [ '../base/main',
         './model',
         './view',
         'constant',
         'event'
], ( PropertyModule, model, view, constant, ide_event ) ->

    VPNModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNConnection

        initStack : () ->
            @view  = view
            @model = model
            @model.isApp = false
            null


        initApp : () ->
            @view = view
            @model = model
            @model.isApp = true
            null

        initAppEdit : () ->
            @view = view
            @model = model
            @model.isApp = true
            null


    }
    null
