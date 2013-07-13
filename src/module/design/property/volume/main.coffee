####################################
#  Controller for design/property/volume module
####################################

define [ 'jquery',
         'text!/module/design/property/volume/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-volume-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template
        console.log 'volume loaded'

        #
        require [ './module/design/property/volume/view', './module/design/property/volume/model' ], ( view, model ) ->

            #view
            view.model    = model

            renderPropertyPanel = ( uid ) ->

                view.model.getVolume uid
                #render
                view.render( view.model.attributes )

            renderPropertyPanel( uid )

            view.on "DEVICE_NAME_CHANGED", ( name )->

                volume_uid = $("#property-panel-volume").attr 'uid'

                view.model.setDeviceName volume_uid, name

                renderPropertyPanel( volume_uid )

            view.on 'VOLUME_SIZE_CHANGED', ( value ) ->

                volume_uid = $("#property-panel-volume").attr 'uid'

                view.model.setVolumeSize volume_uid, value

                #renderPropertyPanel( volume_uid )

            view.on 'VOLUME_TYPE_STANDARD', ()->

                volume_uid = $("#property-panel-volume").attr 'uid'

                view.model.setVolumeTypeStandard volume_uid

            view.on 'VOLUME_TYPE_IOPS', ( value )->

                volume_uid = $("#property-panel-volume").attr 'uid'

                view.model.setVolumeTypeIops volume_uid, value

            view.on 'IOPS_CHANGED' , ( value ) ->

                volume_uid = $("#property-panel-volume").attr 'uid'

                view.model.setVolumeIops volume_uid, value

                #renderPropertyPanel( volume_uid )

            model.once 'REFRESH_PANEL', ()->

                view.render( view.model.attributes )


    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule