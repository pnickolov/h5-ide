#############################
#  View(UI logic) for design/property/rtb
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars', 'UI.multiinputbox' ], ( ide_event ) ->

    RTBView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-rtb-tmpl' ).html()

        events   :

            'change .ipt-wrapper' : 'addIp'

        render     : () ->
            console.log 'property:rtb render'
            $( '.property-details' ).html this.template this.model.attributes

        addIp : ( event ) ->

            console.log event

    }

    view = new RTBView()

    return view