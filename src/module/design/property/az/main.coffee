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
    loadModule = ( uid, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        onViewModelLoaded = ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            data = model.getRenderData( uid )

            if !data.az_list or data.az_list.length == 0

                data.az_list = [
                    name      : data.component.name
                    selected  : true
                    available : true
                ]

                refreshList = ( new_az_data ) ->
                    # If we can't find a az panel with the same uid,
                    # then the panel is removed.
                    unloaded = !view.isPanelVisible( uid )
                    
                    # The fetch fails, wait for next fetch.
                    if !new_az_data && !unloaded
                        return

                    ide_event.off ide_event.RELOAD_AZ, refreshList

                    # If the property panel is unloaded, we will want
                    # to remove the event listener, but not to refresh the panel
                    if unloaded
                        return

                    # wait for 'Resouce Panel Module' to process the data
                    # the processed data will be stored at MC.data.config.zone
                    doRefresh = () ->
                        if ( new_az_data.item.length == 0 )
                            return

                        new_data = model.getRenderData uid
                        new_data.az_list = model.possibleAZList( new_az_data.item, new_data.component.name )

                        view.render( new_data )

                    setTimeout doRefresh, 0
                    null

                # If the az list is null/empty
                # We might want to listen ide_event.RELOAD_RESOURCE
                # so that we can update the list
                ide_event.onLongListen ide_event.RELOAD_AZ, refreshList
                
            else
                data.az_list = model.possibleAZList( data.az_list, data.component.name )

            view.model = model
            view.render ( data )

            view.on "SELECT_AZ", ( oldZoneID, newZone ) ->
                # Set data
                model.setNewAZ oldZoneID, newZone
                # Update Canvas
                MC.canvas.update oldZoneID, "text", "name", newZone

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

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
