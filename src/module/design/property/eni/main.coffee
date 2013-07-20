####################################
#  Controller for design/property/eni module
####################################

define [ 'jquery',
         'text!/module/design/property/eni/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-eni-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/eni/view', './module/design/property/eni/model' ], ( view, model ) ->

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
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule