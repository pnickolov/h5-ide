####################################
#  Controller for design/property/sgrule module
####################################

define [ 'jquery',
         'text!/module/design/property/sgrule/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-sgrule-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/sgrule/view', './module/design/property/sgrule/model' ], ( view, model ) ->

            #view
            view.model    = model
            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule