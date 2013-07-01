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
        MC.IDEcompile 'design-resource', template_data, { '.availability-zone-data' : 'availability-zone-tmpl', '.resoruce-snapshot-data' : 'resoruce-snapshot-tmpl', '.quickstart-ami-data' : 'quickstart-ami-tmpl', '.my-ami-data' : 'my-ami-tmpl', '.favorite-ami-data' : 'favorite-ami-tmpl' }

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

            #view.on 'RESOURCE_SELECET', ( id ) ->
            #    console.log 'RESOURCE_SELECET = ' + id
            #    if id is 'my-ami'       then model.myamiService model.get 'region_name'
            #    #if id is 'favorite-ami' then

            #listen RELOAD_RESOURCE
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name ) ->
                console.log 'resource:RELOAD_RESOURCE'
                model.describeAvailableZonesService region_name
                model.describeSnapshotsService      region_name
                model.quickstartService             region_name
                model.myAmiService                  region_name
                model.favoriteAmiService            region_name
                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule