####################################
#  Controller for design/property/cgw module
####################################

define [ 'jquery',
         'text!/module/design/property/cgw/template.html',
         'event'
], ( $, template, ide_event ) ->

    #private
    loadModule = ( uid, type ) ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="property-cgw-tmpl">' + template + '</script>'
        #load remote html template
        $( 'head' ).append template

        #
        require [ './module/design/property/cgw/view', './module/design/property/cgw/model' ], ( view, model ) ->

            #view
            view.model = model
            #render
            view.render( model.getRenderData uid )

            view.on "CHANGE_NAME", ( uid, change ) ->
                # TODO : Validate Name
                model.setName uid, change.value
                change.accept()

                # Sync the name to canvas
                MC.canvas.update uid, "text", "cgw_name", change.value
                null

            view.on "CHANGE_IP", ( uid, change ) ->
                # TODO : Validate IP
                model.setIP uid, change.value
                change.accept()
                null

            view.on "CHANGE_BGP", ( uid, change ) ->

                if !change.value
                    model.setBGP uid, bgp
                    change.accept()
                    return

                if !change.value.match( /^\d+$/ )
                    change.reject "ASN must be a number"
                    return

                bgp = parseInt change.value, 10

                if bgp > 65534 || bgp < 1
                    change.reject "Must be between 1 and 65534"
                    return

                area = MC.canvas_data.region

                if bgp == 7224 && area == "us-east-1"
                    change.reject "ASN number 7224 is reserved in Virginia"
                    return

                if bgp == 9095 && area == "eu-west-1"
                    change.reject "ASN number 9059 is reserved in Ireland"
                    return

                model.setBGP uid, bgp
                change.accept()
                null
            null


    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
