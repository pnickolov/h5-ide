#############################
#  View(UI logic) for design/property/eni
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

   ENIView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-eni-tmpl' ).html()

        #events   :

        render     : () ->
            console.log 'property:eni render'

            attributes =
                name     : "ENI-1"
                attached : true

                eni_display :
                    description : "My Network interface description"
                    sourceCheck : true


            $('.property-details').html this.template attributes

    }

    view = new ENIView()

    return view
