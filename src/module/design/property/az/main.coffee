####################################
#  Controller for design/property/az module
####################################

define [ 'jquery',
         'text!/module/design/property/az/template.html',
         'constant'
         'event'
], ( $, template, constant, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-az-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/az/view', './module/design/property/az/model' ], ( view, model ) ->

            data =
                id        : uid
                component : MC.canvas_data.layout.component.group[uid]
                az_list   : MC.data.config[ MC.canvas_data.region ]

            if data.az_list && data.az_list.zone
                data.az_list = data.az_list.zone.item
            else
                data.az_list = null

            # In case we get a null az list
            if !data.az_list or data.az_list.length == 0
                data.az_list = [
                    name      : data.component.name
                    selected  : true
                    available : true
                ]

                refreshList = ( new_az_data ) ->

                    # If we can't find a az panel with the same uid,
                    # then the panel is removed.
                    unloaded = $("az-quick-select").data("component") != uid
                    
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

                        new_data =
                            id        : uid
                            component : MC.canvas_data.layout.component.group[uid]

                        new_data.az_list = possibleAZList( new_az_data.item, new_data.component.name )

                        view.render( new_data )

                    setTimeout doRefresh, 0
                    null

                # If the az list is null/empty
                # We might want to listen ide_event.RELOAD_RESOURCE
                # so that we can update the list
                ide_event.on ide_event.RELOAD_AZ, refreshList

            else
                data.az_list = possibleAZList( data.az_list, data.component.name )

            #view
            view.model = model
            #render
            view.render( data )

            view.on "SELECT_AZ", updateAZ
            null
        null

    unLoadModule = () ->
        null

    possibleAZList = ( datalist, selectedItemName ) ->
        if !datalist
            return

        used_list = {}
        for uid, az of MC.canvas_data.layout.component.group
            used_list[az.name] = true

        possible_list = []
        for az in datalist
            if az.zoneName == selectedItemName or used_list[az.zoneName] != true
                possible_list.push
                    name      : az.zoneName
                    selected  : az.zoneName  == selectedItemName
                    available : az.zoneState =="available"

        possible_list

     updateAZ = ( oldZoneID, newZone ) ->

        oldZone = MC.canvas_data.layout.component.group[oldZoneID]

        # The property panel is not representing the current canvas,
        # which should be a bug.
        if oldZone == undefined
            console.log "[Error!] Trying to modify az which is not belong to current canvas"
            return

        # Zone is not changed
        if oldZone.name == newZone
            return

        # Update data ( and instance、volume、eni )
        oldZoneName   = oldZone.name
        oldZone.name  = newZone
        resource_type = constant.AWS_RESOURCE_TYPE
        for uid, component of MC.canvas_data.component

            console.log component.type, component.AvailabilityZone, oldZoneName

            if component.type == resource_type.AWS_EC2_Instance
                placement = component.resource.Placement
                if placement.AvailabilityZone == oldZoneName
                    placement.AvailabilityZone = newZone

            else if component.type == resource_type.AWS_EBS_Volume
                if component.resource.AvailabilityZone == oldZoneName
                    component.resource.AvailabilityZone = newZone

        # Update Canvas
        MC.canvas.update oldZoneID, "text", "az_name", newZone



    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
