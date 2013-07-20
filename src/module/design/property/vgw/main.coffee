####################################
#  Controller for design/property/vgw module
####################################

define [ 'jquery',
         'text!/module/design/property/vgw/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-vgw-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( uid, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/vgw/view', './module/design/property/vgw/model' ], ( view, model ) ->

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