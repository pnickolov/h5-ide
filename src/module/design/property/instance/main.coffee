####################################
#  Controller for design/property/instance module
####################################

define [ 'jquery',
         'text!/module/design/property/instance/template.html',
         'text!/module/design/property/instance/template_data.html',
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
        #MC.IDEcompile 'design-property-instance', template_data, { '.accordion-item-data' : 'accordion-item-tmpl' }

        #
        require [ './module/design/property/instance/view', './module/design/property/instance/model' ], ( view, model ) ->

            #view
            view.model    = model
            view.render template

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule