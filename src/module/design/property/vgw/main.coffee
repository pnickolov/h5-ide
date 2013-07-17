####################################
#  Controller for design/property/vgw module
####################################

define [ 'jquery',
         'text!/module/design/property/vgw/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-vgw-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/vgw/view', './module/design/property/vgw/model' ], ( view, model ) ->

            #view
            view.model    = model
            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule