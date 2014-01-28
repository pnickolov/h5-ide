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

        handleTypes : [ constant.AWS_RESOURCE_TYPE.AWS_EBS_Volume, "component_asg_volume" ]

        setupStack : () ->
            me = this
            @view.on 'VOLUME_SIZE_CHANGED', ( value ) ->
                me.model.setVolumeSize value
                MC.canvas.update model.attributes.uid, "text", "volume_size", value + "GB"

                #patch: update volumeSize in dom
                vol_data = $("#" + model.attributes.uid ).data("json")
                vol_data.volumeSize = value
                $("#" + model.attributes.uid ).attr( "data-json", JSON.stringify(vol_data) )

                null


            @model.once 'REFRESH_PANEL', ()->
                me.view.render()

            @view.on "OPEN_SNAPSHOT", (id)->
                PropertyModule.loadSubPanel "STATIC", id
                null

            null

        initStack : ()->
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
