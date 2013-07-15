####################################
#  Controller for design/property/subnet module
####################################

define [ 'jquery',
         'text!/module/design/property/subnet/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-subnet-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/subnet/view', './module/design/property/subnet/model' ], ( view, model ) ->

            #view
            view.model    = model
            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule