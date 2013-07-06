####################################
#  Controller for design/property/advanced_details module
####################################

define [ 'jquery',
         'text!/module/design/property/advanced_details/template.html',
         'text!/module/design/property/advanced_details/template_data.html',
         'event',
         'MC.ide.template'
], ( $, template, template_data, ide_event ) ->

    #private
    loadModule = ( callback ) ->

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="property-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#property-panel'

        #compile partial template
        #MC.IDEcompile 'design-property-instance', template_data, { '.accordion-item-data' : 'accordion-item-tmpl' }

        #
        require [ './module/design/property/advanced_details/view', './module/design/property/advanced_details/model' ], ( view, model ) ->

            #view
            #view       = new View { 'model' : model }
            view.model    = model
            view.template = template
            #view.render template
            #callback
            callback view

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule