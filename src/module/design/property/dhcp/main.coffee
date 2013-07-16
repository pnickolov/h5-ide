####################################
#  Controller for design/property/dhcp module
####################################

define [ 'jquery',
         'text!/module/design/property/dhcp/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-dhcp-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/dhcp/view', './module/design/property/dhcp/model' ], ( view, model ) ->

            #view
            view.model    = model
            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule