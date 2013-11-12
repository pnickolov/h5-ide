####################################
#  Controller for design/property/vgw module
####################################

define [ '../base/main', './model', './view', 'constant' ], ( PropertyModule, model, view, constant )->

    StaticModule = PropertyModule.extend {

        handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway, constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway ]

        initStack : ()->
            @model = model
            @view  = view
            null

        initApp : ()->
            @model = model
            @view  = view
            null

        initAppEdit : ()->
            @model = model
            @view  = view
            null
    }

    null
