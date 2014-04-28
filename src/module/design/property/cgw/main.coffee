####################################
#  Controller for design/property/cgw module
####################################

define [ '../base/main',
         './model',
         './view',
         './app_model',
         './app_view',
         'constant'
], ( PropertyModule, model, view, app_model, app_view, constant ) ->

    CGWModule = PropertyModule.extend {

        handleTypes : constant.RESTYPE.CGW

        setupStack : () ->
            me = this
            @view.on "CHANGE_NAME", ( value ) ->
                me.model.setName value
                # Sync the name to canvas
                MC.canvas.update uid, "text", "name", value
                null

        initStack : ()->
            @model = model
            @view  = view
            null

        initApp : () ->
            @model = app_model
            @view  = app_view
            null

        initAppEdit : () ->
            @model = app_model
            @view  = app_view
            null
    }
    null
