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
    loadModule = ( uid_parent, expended_accordion_id, current_main ) ->

        #
        MC.data.current_sub_main = current_main

        #
        require [ './module/design/property/sg/view', './module/design/property/sg/model' ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #view
            view.model    = model

            if uid_parent
                if uid_parent.uid

                    view.model.getSG uid_parent.uid, uid_parent.parent

                else

                    view.model.addSG uid_parent.parent
            else

                view.model.addSG()

            #render
            view.render( expended_accordion_id )
            
            view.on 'SET_SG_NAME', ( uid, value ) ->

                model.setSGName uid, value

                view.render()

            view.on 'REMOVE_SG_RULE', ( uid, rule )->

                model.removeSGRule uid, rule

            view.on 'SET_SG_RULE', ( uid, rule ) ->

                model.setSGRule uid, rule

            view.on 'SET_SG_DESC', ( uid, value ) ->

                model.setSGDescription uid, value


    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule