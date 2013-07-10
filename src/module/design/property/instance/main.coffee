####################################
#  Controller for design/property/instance module
####################################

define [ 'jquery',
         'text!/module/design/property/instance/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-instance-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/instance/view',
                  './module/design/property/instance/model',
                  'UI.secondarypanel',
                  'UI.selectbox',
                  'UI.tooltip',
                  'UI.notification',
                  'UI.toggleicon',
                  'UI.fixedaccordion'
        ], ( view, model ) ->

            #view
            view.model    = model
            #model
            #model.setHost uid
            attributes = {
                instance_type : model.getInstanceType uid
                component : MC.canvas_data.component[uid]
                keypair : model.getKerPair uid
            }
            #render
            view.render( attributes )

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule