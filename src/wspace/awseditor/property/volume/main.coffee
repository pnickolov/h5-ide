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

            # Volume on Running LC
            if owner.type is constant.RESTYPE.LC and owner.get 'appId'
                @model.isAppEdit = true
            else
                @model.isAppEdit = false

            null

        initApp : ()->
            @model = app_model
            @view  = app_view
            null

        initAppEdit : ()->
            @model = app_model
            @view  = app_view
            null
    }
    null
