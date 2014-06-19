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

        handleTypes : constant.RESTYPE.VPN

        initStack : () ->
            @view  = view
            @model = model
            @model.isApp = false
            @model.isAppEdit = false
            null


        initApp : () ->
            @view = view
            @model = model
            @model.isApp = true
            @model.isAppEdit = false
            null

        initAppEdit : () ->
            @view = view
            @model = model
            @model.isApp = false
            @model.isAppEdit = true
            null


    }
    null
