####################################
#  Controller for design/property/volume module
####################################

define [ "../base/main",
         "./model",
         "./view",
         "./app_model",
         "./app_view",
         "constant"
], ( PropertyModule, model, view, app_model, app_view, constant )->

    VolumeModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.VOL ]

        setupStack : () ->
            @view.on "OPEN_SNAPSHOT", (id)->
                PropertyModule.loadSubPanel "STATIC", id
                null

            null

        initStack : ( uid )->
            volume = Design.instance().component uid
            owner = volume.get 'owner'

            @model = model
            @view  = view

            null

        initApp : ()->
            @model = app_model
            @view  = app_view
            @model.isAppEdit = false
            null

        initAppEdit : ()->
            @model = app_model
            @view  = app_view
            @model.isAppEdit = true
            null
    }
    null
