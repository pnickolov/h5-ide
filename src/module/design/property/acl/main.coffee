####################################
#  Controller for design/property/acl module
####################################

define [ 'jquery',
         'text!/module/design/property/acl/template.html',
         'event'
], ( $, template, ide_event ) ->

    #
    current_view  = null
    current_model = null

    #private
    loadModule = ( uid_parent, expended_accordion_id, aclUID ) ->

        #
        MC.data.current_sub_main = this

        #
        require [ './module/design/property/acl/view', './module/design/property/acl/model' ], ( view, model ) ->

            #
            if current_view then view.delegateEvents view.events

            #
            current_view  = view
            current_model = model

            #model
            model.init aclUID

            #view
            view.model    = model
            #render
            view.render expended_accordion_id, template, model.attributes

    unLoadModule = () ->
        current_view.off()
        current_model.off()
        current_view.undelegateEvents()
        #ide_event.offListen ide_event.<EVENT_TYPE>
        #ide_event.offListen ide_event.<EVENT_TYPE>, <function name>

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule