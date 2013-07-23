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
    loadModule = ( uid_parent, expended_accordion_id, aclUID ) ->

        #
        MC.data.current_sub_main = this

        #
        require [ './module/design/property/acl/view', './module/design/property/acl/model' ], ( view, model ) ->

            #
            current_view  = view

            #model
            model.init aclUID

            #view
            view.model    = model
            #render
            view.render expended_accordion_id, template, model.attributes

    unLoadModule = () ->
        current_view.off()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule