####################################
#  Controller for design/property module
####################################

define [ 'jquery',
         'text!/module/design/property/template.html',
         'text!/module/design/property/template_data.html',
         'event',
         'MC.ide.template'
], ( $, template, template_data, ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="property-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#property-panel'

        #compile partial template
        MC.IDEcompile 'design-property', template_data, { '.accordion-item-data' : 'accordion-item-tmpl' }

        #
        require [ './module/design/property/view',
                  './module/design/property/model',
                  './module/design/property/instance/main',
                  './module/design/property/advanced_details/main'
        ], ( View, model, instance_main, advanced_main ) ->

            #view
            property_view  = new View { 'model' : model }
            property_view.render template

            #listen OPEN_PROPERTY
            ide_event.onLongListen ide_event.OPEN_PROPERTY, () ->
                console.log 'OPEN_PROPERTY'

                instance_main.loadModule ( view ) ->
                    console.log 'instace main'
                    model.addItem view.model.attributes.head, view.template
                    #
                    advanced_main.loadModule ( view ) ->
                        console.log 'advanced instace main'
                        model.addItem view.model.attributes.head, view.template
                        #
                        property_view.refresh()

                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule