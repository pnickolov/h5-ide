####################################
#  Controller for design/property/az module
####################################

define [ '../base/main', './model', './view', 'constant' ], ( PropertyModule, model, view, constant ) ->

    ideEvents = {}
    ideEvents[ ide_event.RELOAD_AZ ] = ( new_az_data ) ->

        if !new_az_data
            return

        me = this

        # wait for 'Resouce Panel Module' to process the data
        # the processed data will be stored at MC.data.config.zone
        doRefresh = () ->
            if ( new_az_data.item.length == 0 )
                return

            me.model.reInit()
            me.view.render()

        setTimeout doRefresh, 0

        null


    AZModule = PropertyModule.extend {

        ideEvents : ideEvents

        hanldeTypes : "Stack:" + constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

        setupStack : ()->
            me = this
            @view.on "SELECT_AZ", ( oldZoneID, newZone ) ->
                # Set data
                oldZone = me.model.setNewAZ oldZoneID, newZone

                if !oldZone
                    return

                # Update Canvas
                MC.canvas.update oldZoneID, "text", "label", newZone
                # Update Resource Panel

                res_type = constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
                filter   = ( data ) ->
                    return data.option.name == name

                name = oldZone
                ide_event.trigger ide_event.ENABLE_RESOURCE_ITEM, res_type, filter

                name = newZone
                ide_event.trigger ide_event.DISABLE_RESOURCE_ITEM, res_type, filter
            null


        initStack : ()->
            @model = model
            @view  = view

            null
    }

    null

