####################################
#  Controller for design/property/az module
####################################

define [ '../base/main', './model', './view', 'constant', 'event' ], ( PropertyModule, model, view, constant, ide_event ) ->

    AZModule = PropertyModule.extend {

        handleTypes : "Stack:" + constant.RESTYPE.AZ

        setupStack : ()->
            me = this
            @view.on "SELECT_AZ", ( newZone ) ->
                # Set data
                oldZone = me.model.get("name")

                me.model.setName newZone

                # Update Resource Panel
                res_type = constant.RESTYPE.AZ
                filter   = ( data ) -> return data.option.name is name

                name = oldZone
                ide_event.trigger ide_event.ENABLE_RESOURCE_ITEM, res_type, filter

                name = newZone
                ide_event.trigger ide_event.DISABLE_RESOURCE_ITEM, res_type, filter
            null


        initStack : ()->
            # Quick hack.
            # In AppEdit, AZ's property will be opened.
            # Throw an error to do nothing.
            if Design.instance().modeIsAppEdit()
                throw new Error("Cannot open az property panel in AppEdit mode.")

            @model = model
            @view  = view
            null
    }

    null

