####################################
#  Controller for design/property/eni module
####################################

define [ 'jquery',
         'text!/module/design/property/eni/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-eni-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( uid, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/eni/view', './module/design/property/eni/model' ], ( view, model ) ->

            #
            current_view  = view

            #view
            view.model    = model

            model.getENIDisplay uid
            #render
            view.render()

            view.on 'SET_ENI_DESC', ( uid, value ) ->

                model.setEniDesc uid, value

            view.on 'SET_ENI_SOURCE_DEST_CHECK', ( uid, check ) ->

                model.setSourceDestCheck uid, check

    unLoadModule = () ->
        current_view.off()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule