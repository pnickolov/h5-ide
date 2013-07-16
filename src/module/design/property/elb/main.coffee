####################################
#  Controller for design/property/elb module
####################################

define [ 'jquery',
         'text!/module/design/property/elb/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-elb-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/elb/view',
                  './module/design/property/elb/model'
        ], ( view, model ) ->

            #view
            view.model    = model
            #model
            #model.setHost uid
            attributes = {
                component : MC.canvas_data.component[uid]
            }
            #render
            view.render( attributes )

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule