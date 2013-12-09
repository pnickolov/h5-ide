####################################
#  Controller for design/property/az module
####################################

define [ '../base/main', './model', './view', 'constant', 'event' ], ( PropertyModule, model, view, constant, ide_event ) ->

    ideEvents = {}
    ideEvents[ ide_event.RELOAD_AZ ] = ( new_az_data ) ->

        if !new_az_data
            return

        me = this

        # wait for 'Resouce Panel Module' to process the data
        # the processed data will be stored at MC.data.config.zone
        setTimeout ()->
            me.model.reInit()
            me.view.render()
        , 0

        null


    AZModule = PropertyModule.extend {

        ideEvents : ideEvents

        handleTypes : "Stack:" + constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone

        setupStack : ()->
            me = this
            @view.on "SELECT_AZ", ( newZone ) ->
                # Set data
                oldZone = me.model.setName newZone

                # Update Resource Panel
                res_type = constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
                filter   = ( data ) -> return data.option.name is name

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

