####################################
#  Controller for design/property/az module
####################################

define [ 'jquery',
         'text!/module/design/property/az/template.html',
         'event'
], ( $, template, ide_event ) ->

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

        onViewModelLoaded = ( view, model ) ->

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
                # We might want to listen ide_event.RELOAD_RESOURCE
                # so that we can update the list
                ide_event.onLongListen ide_event.RELOAD_AZ, refreshList


            view.model = model
            view.render()

            view.on "SELECT_AZ", ( oldZoneID, newZone ) ->
                # Set data
                model.setNewAZ oldZoneID, newZone
                # Update Canvas
                MC.canvas.update oldZoneID, "text", "name", newZone

                #ide_event.trigger ide_event.CHANGE_AZ, MC.canvas_data.layout.group[oldZoneID].name, newZone

            null

        #
        require [ './module/design/property/az/view', './module/design/property/az/model' ], onViewModelLoaded
        null


    unLoadModule = () ->
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
