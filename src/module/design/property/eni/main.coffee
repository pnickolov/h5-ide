####################################
#  Controller for design/property/eni module
####################################

define [ 'jquery',
         'text!/module/design/property/eni/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

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
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model

            model.getENIDisplay uid
            #render
            view.render()

            view.on 'SET_ENI_DESC', ( uid, value ) ->

                model.setEniDesc uid, value

            view.on 'SET_ENI_SOURCE_DEST_CHECK', ( uid, check ) ->

                model.setSourceDestCheck uid, check

            view.on 'ADD_NEW_IP', ( uid ) ->

                model.addNewIP uid

            view.on 'ATTACH_EIP', ( uid, index, attach ) ->

                model.attachEIP uid, index, attach

            view.on 'REMOVE_IP', ( uid, index ) ->

                model.removeIP uid, index



    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule