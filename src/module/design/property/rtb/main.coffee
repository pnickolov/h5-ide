####################################
#  Controller for design/property/rtb module
####################################

define [ 'jquery',
         'text!/module/design/property/rtb/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view = null

    #private
    loadModule = ( uid, type, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-rtb-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/rtb/view', './module/design/property/rtb/model' ], ( view, model ) ->

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