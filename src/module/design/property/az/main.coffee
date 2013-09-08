####################################
#  Controller for design/property/az module
####################################

define [ 'constant',
         'jquery',
         'text!./template.html',
         'event'
], ( constant, $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-az-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        if tab_type is "OPEN_APP"
            # Do nothing
            return

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/az/view', './module/design/property/az/model' ], ( view, model ) ->

            # added by song
            model.clear({silent: true})
            
            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            model.setId uid
            data = model.attributes

            if data.needRefresh

                refreshList = ( new_az_data ) ->
                    # If we can't find a az panel with the same uid,
                    # then the panel is removed.
                    unloaded = !view.isPanelVisible( uid )

                    # The fetch fails, wait for next fetch.
                    if !new_az_data && !unloaded
                        return

                    ide_event.offListen ide_event.RELOAD_AZ, refreshList

                    # If the property panel is unloaded, we will want
                    # to remove the event listener, but not to refresh the panel
                    if unloaded
                        return

                    # wait for 'Resouce Panel Module' to process the data
                    # the processed data will be stored at MC.data.config.zone
                    doRefresh = () ->
                        if ( new_az_data.item.length == 0 )
                            return

                        model.setId uid
                        view.render()

                    setTimeout doRefresh, 0
                    null

                # If the az list is null/empty
                # We might want to listen ide_event.OPEN_DESIGN
                # so that we can update the list
                ide_event.onLongListen ide_event.RELOAD_AZ, refreshList


            view.model = model
            view.render()

            # Set title
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, "Availability Zone"

            view.on "SELECT_AZ", ( oldZoneID, newZone ) ->
                # Set data
                oldZone = model.setNewAZ oldZoneID, newZone

                if !oldZone
                    return

                # Update Canvas
                MC.canvas.update oldZoneID, "text", "name", newZone
                # Update Resource Panel

                res_type = constant.AWS_RESOURCE_TYPE.AWS_EC2_AvailabilityZone
                filter   = ( data ) ->
                    return data.option.name == name

                name = oldZone
                ide_event.trigger ide_event.ENABLE_RESOURCE_ITEM, res_type, filter

                name = newZone
                ide_event.trigger ide_event.DISABLE_RESOURCE_ITEM, res_type, filter
            null

        null


    unLoadModule = () ->
        if !current_view then return
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

        # AZ use ide_event, but it's not need to unload here.
        # The event callback will only be fired one time. And it also check if
        # the panel is unloaded.

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
