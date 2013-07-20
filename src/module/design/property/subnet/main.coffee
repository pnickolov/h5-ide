####################################
#  Controller for design/property/subnet module
####################################

define [ 'jquery',
         'text!/module/design/property/subnet/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view = null

    #private
    loadModule = ( uid, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-subnet-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/subnet/view', './module/design/property/subnet/model' ], ( view, model ) ->

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