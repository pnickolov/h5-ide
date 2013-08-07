#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars', 'UI.toggleicon' ], ( ide_event, MC ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-asg-tmpl' ).html()

        #events   :

        render     : ( attributes ) ->
            console.log 'property:asg render'
            $( '.property-details' ).html this.template this.model.attributes
    }

    view = new InstanceView()

    return view
