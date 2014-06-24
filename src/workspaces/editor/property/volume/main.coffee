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

        handleTypes : [ constant.RESTYPE.VOL, "component_asg_volume" ]

        setupStack : () ->
            me = this
            @view.on 'VOLUME_SIZE_CHANGED', ( value ) ->
                me.model.setVolumeSize value
                MC.canvas.update model.attributes.uid, "text", "volume_size", value + "GB"

            @model.once 'REFRESH_PANEL', ()->
                me.view.render()

            @view.on "OPEN_SNAPSHOT", (id)->
                PropertyModule.loadSubPanel "STATIC", id
                null

            null

        initStack : ( uid )->
            volume = Design.instance().component uid
            owner = volume.get 'owner'

            # Volume on Running LC
            if owner.type is constant.RESTYPE.LC and owner.get 'appId'
                @model = app_model
                @view  = app_view
            else
                @model = model
                @view  = view

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
