####################################
#  Controller for design/resource module
####################################

define [ 'jquery',
         'text!/module/design/resource/template.html',
         'text!/module/design/resource/template_data.html',
         'event',
         'MC.ide.template'
], ( $, template, template_data, ide_event ) ->

    #private
    loadModule = () ->

        #compile partial template
        MC.IDEcompile 'design-resource', template_data, { '.availability-zone-data' : 'availability-zone-tmpl', '.resoruce-snapshot-data' : 'resoruce-snapshot-tmpl' }

        #load remote module1.js
        require [ './module/design/resource/view', './module/design/resource/model' ], ( View, model ) ->

            #view
            view       = new View()
            view.render template
            view.listen model

            #listen SWITCH_TAB
            #ide_event.onLongListen ide_event.SWITCH_TAB, ( type, target, region_name ) ->
            #    console.log 'resource:SWITCH_TAB, type = ' + type + ', target = ' + target + ', region_name = ' + region_name
            #    if type is 'NEW_STACK'
            #        model.describeAvailableZonesService region_name
            #    null

            #listen RELOAD_RESOURCE
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name ) ->
                console.log 'resource:RELOAD_RESOURCE'
                model.describeAvailableZonesService region_name
                #model.describeSnapshotsService region_name
                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule