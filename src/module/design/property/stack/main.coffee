####################################
#  Controller for design/property/stack module
####################################

define [ 'jquery',
         'text!/module/design/property/stack/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-stack-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/stack/view', './module/design/property/stack/model' ], ( view, model ) ->

            #view
            view.model    = model
            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule