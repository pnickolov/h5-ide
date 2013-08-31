####################################
#  Controller for design/property/volume module
####################################

define [ 'jquery',
         'text!./template.html',
         'text!./app_template.html',
         'event'
], ( $, template, app_template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-volume-tmpl">' + template + '</script>'
    app_template = '<script type="text/x-handlebars-template" id="property-volume-app-tmpl">' + app_template + '</script>'
    #load remote html template
    $( 'head' ).append( template ).append( app_template )
    console.log 'volume loaded'

    #private
    loadModule = ( uid, current_main, tab_type ) ->

        MC.data.current_sub_main = current_main

        #set view_type
        if tab_type is 'OPEN_APP'
            loadAppModule uid
            return

        #
        require [ './module/design/property/volume/view',
                  './module/design/property/volume/model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model

            renderPropertyPanel = ( uid ) ->

                model.getVolume uid
                #render
                #view.render( view.model.attributes )
                view.render()
                ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.volume_detail.name

            renderPropertyPanel( uid )

            view.on "DEVICE_NAME_CHANGED", ( name )->

                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setDeviceName volume_uid, name

                # retrive again due to uid may be change in launch configuration
                volume_uid = $("#property-panel-volume").attr 'uid'

                renderPropertyPanel( volume_uid )

            view.on 'VOLUME_SIZE_CHANGED', ( value ) ->

                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setVolumeSize volume_uid, value

                MC.canvas.update volume_uid, "text", "volume_size", value + "GB"

                #renderPropertyPanel( volume_uid )

            view.on 'VOLUME_TYPE_STANDARD', ()->

                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setVolumeTypeStandard volume_uid

            view.on 'VOLUME_TYPE_IOPS', ( value )->


                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setVolumeTypeIops volume_uid, value

                #renderPropertyPanel( volume_uid )

            view.on 'IOPS_CHANGED' , ( value ) ->

                volume_uid = $("#property-panel-volume").attr 'uid'

                model.setVolumeIops volume_uid, value

                #renderPropertyPanel( volume_uid )

            model.once 'REFRESH_PANEL', ()->

                view.render()

    loadAppModule = ( uid ) ->
        require [ './module/design/property/volume/app_view',
                  './module/design/property/volume/app_model'
        ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.init uid
            view.render()
            ide_event.trigger ide_event.PROPERTY_TITLE_CHANGE, model.attributes.name

    unLoadModule = () ->
        if !current_view then return
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
