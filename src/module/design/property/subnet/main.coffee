####################################
#  Controller for design/property/subnet module
####################################

define [ 'jquery',
         'text!/module/design/property/subnet/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-subnet-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/subnet/view', './module/design/property/subnet/model' ], ( view, model ) ->

            #view
            view.model    = model
            #render
            view.render model.getRenderData uid

            view.on "CHANGE_NAME", ( uid, change ) ->
                # TODO : Validate Name
                model.setName uid, change.value
                change.accept()

                # Sync the name to canvas
                MC.canvas.update uid, "text", "name", change.value
                null

            view.on "CHANGE_ACL", ( uid, change ) ->
                model.setACL uid, change.value
                change.accept()
                null

            view.on "CHANGE_CIDR", ( uid, change ) ->
                # TODO : Validate CIDR
                model.setCIDR uid, change.value
                change.accept()
                null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
