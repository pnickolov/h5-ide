####################################
#  Controller for design/property module
####################################

define [ 'jquery',
         'text!/module/design/property/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="property-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#property-panel'

        #compile partial template
        #MC.IDEcompile 'design-property', template_data, { '.accordion-item-data' : 'accordion-item-tmpl' }

        #
        require [ './module/design/property/view',
                  './module/design/property/model',
                  './module/design/property/instance/main',
                  './module/design/property/sg/main'
        ], ( View, model, instance_main, sg_main ) ->

            uid  = null
            type = null

            #view
            view  = new View { 'model' : model }
            view.render template

            #listen OPEN_PROPERTY
            ide_event.onLongListen ide_event.OPEN_PROPERTY, ( uid ) ->
                console.log 'OPEN_PROPERTY'

                uid  = uid
                type = type

                instance_main.loadModule uid, type
                #temp
                setTimeout () ->
                   view.refresh()
                , 2000
 
                null

            #listen OPEN_SG
            ide_event.onLongListen ide_event.OPEN_SG, () ->
                console.log 'OPEN_SG'
                sg_main.loadModule()
                #temp
                setTimeout () ->
                   view.refresh()
                , 2000
 
                null

            #listen OPEN_SG
            ide_event.onLongListen ide_event.OPEN_INSTANCE, () ->
                console.log 'OPEN_INSTANCE'
                #
                instance_main.loadModule uid, type
                #temp
                setTimeout () ->
                   view.refresh()
                , 2000

                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule