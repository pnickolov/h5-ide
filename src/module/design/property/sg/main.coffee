####################################
#  Controller for design/property/sg module
####################################

define [ 'jquery',
         'text!/module/design/property/sg/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #add handlebars script
    template = '<script type="text/x-handlebars-template" id="property-sg-tmpl">' + template + '</script>'
    #load remote html template
    $( 'head' ).append template

    #private
    loadModule = ( sg_uid, parent_main, current_main ) ->

        #
        # MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/sg/view', './module/design/property/sg/model' ], ( view, model ) ->

            #
            
            # if current_view view.delegateEvents view.events

            #
            current_view  = view
            current_model = model
            parent_main.sg_main = current_main

            #view
            view.model    = model

            if sg_uid
                view.model.getSG sg_uid
            else
                view.model.addSG()

            if view.hasOwnProperty('events')
                return

            #render
            view.render()
            
            view.on 'SET_SG_NAME', ( sg_uid, value ) ->

                model.setSGName sg_uid, value

            view.on 'REMOVE_SG_RULE', ( sg_uid, rule )->

                model.removeSGRule sg_uid, rule

            view.on 'SET_SG_RULE', ( sg_uid, rule ) ->

                model.setSGRule sg_uid, rule

            view.on 'SET_SG_DESC', ( sg_uid, value ) ->

                model.setSGDescription sg_uid, value


    unLoadModule = () ->

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
