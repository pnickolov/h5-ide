####################################
#  Controller for design/property/dhcp module
####################################

define [ 'jquery',
         'text!/module/design/property/dhcp/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view = null

    #private
    loadModule = ( uid, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-dhcp-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/dhcp/view', './module/design/property/dhcp/model' ], ( view, model ) ->

            #
            current_view  = view

            #view
            view.model    = model
            #render
            view.render()

    unLoadModule = () ->
        current_view.off()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule