####################################
#  Controller for design/property/igw module
####################################

define [ '../base/main', './model', './view', 'constant' ], ( PropertyModule, model, view, constant )->

    IGWModule = PropertyModule.extend {

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

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
