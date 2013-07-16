####################################
#  Controller for design/property/az module
####################################

define [ 'jquery',
         'ec2_model',
         'text!/module/design/property/az/template.html',
         'event'
], ( $, ec2_model, template, ide_event ) ->

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
                az_list   : MC.data.config[ MC.canvas_data.region ]?.zone?.item

            # In case we get a null az list
            if !data.az_list or data.az_list.length == 0
                data.az_list = [
                    name      : data.component.name
                    selected  : true
                    available : true
                ]

                refreshList = () ->
                    
                    # ec2_model has fetched availabilty zone infos.

                    new_az_data = MC.data.config[ MC.canvas_data.region ]?.zone
                    # The fetch fails, wait for next fetch.
                    if !new_az_data
                        return

                    ec2_model.off 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN', refreshList

                    # wait for 'Resouce Panel Module' to process the data
                    # the processed data will be stored at MC.data.config.zone
                    doRefresh = () ->
                        if ( new_az_data.item.length == 0 )
                            return

                        new_data =
                            id        : uid
                            component : MC.canvas_data.layout.component.group[uid]

                        new_data.az_list = for az in new_az_data.item
                            name      : az.zoneName
                            selected  : az.zoneName  == new_data.component.name
                            available : az.zoneState =="available"

                        view.render( new_data )

                    setTimeout doRefresh, 0
                    null

                # If the az list is null/empty
                # We might want to listen ide_event.RELOAD_RESOURCE
                # so that we can update the list
                ec2_model.on 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN', refreshList

            else
                data.az_list = for az in data.az_list
                    name      : az.zoneName
                    selected  : az.zoneName  == data.component.name
                    available : az.zoneState =="available"

            #view
            view.model = model
            #render
            view.render( data )

            view.on "SELECT_AZ", selectAZ
            null
        null

    unLoadModule = () ->
        #view.remove()

    selectAZ = ( oldZoneID, newZone ) ->

        oldZone = MC.canvas_data.layout.component.group[oldZoneID]

        # The property panel is not representing the current canvas,
        # which should be a bug.
        if oldZone == undefined
            console.log "[Error!] Trying to modify az which is not belong to current canvas"
            return

        # Zone is not changed
        if oldZone.name == newZone
            return

        # !!!!!!!!!! TODO:
        # Update data ( and hosts' data )
        oldZoneName  = oldZone.name
        oldZone.name = newZone

        # Update Canvas



    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
