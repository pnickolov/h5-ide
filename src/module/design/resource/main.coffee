####################################
#  Controller for design/resource module
####################################

define [ 'jquery', 'text!/module/design/resource/template.html', 'event' ], ( $, template, ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="resource-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#resource-panel'

        #load remote module1.js
        require [ './module/design/resource/view', './module/design/resource/model' ], ( View, model ) ->

            #view
            view       = new View()
            view.render template
            view.listen model

            #listen SWITCH_TAB
            ide_event.onLongListen ide_event.SWITCH_TAB, ( type, target, region_name ) ->
                console.log 'resource:SWITCH_TAB, type = ' + type + ', target = ' + target + ', region_name = ' + region_name
                if type is 'NEW_STACK'
                    model.describeAvailableZonesService region_name
                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule