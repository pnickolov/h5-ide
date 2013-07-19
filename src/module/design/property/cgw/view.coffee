#############################
#  View(UI logic) for design/property/cgw
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   CGWView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-cgw-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:cgw render'

            attributes =
                name : "custom-gateway-1"
                ip   : "1.2.3.4"
                staticRouting : false
                BGPASN : ""
                default : true # According to dan's design, if default is true, Name input is autofocus


            $( '.property-details' ).html this.template attributes

    }

    view = new CGWView()

    return view
