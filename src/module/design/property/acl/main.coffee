####################################
#  Controller for design/property/acl module
####################################

define [ 'jquery',
         'text!/module/design/property/acl/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view = null

    #private
    loadModule = ( uid, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-acl-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/acl/view', './module/design/property/acl/model' ], ( view, model ) ->

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