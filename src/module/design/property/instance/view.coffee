#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'backbone', 'jquery', 'handlebars' ], () ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-instance-tmpl' ).html()

        events   :
            'change .instance-name' : 'instanceNameChange'

        render     : () ->
            console.log 'property:instance render'
            $( '.property-details' ).html this.template this.model.attributes

        instanceNameChange : ( event ) ->
            console.log 'instanceNameChange'
            $( '.instance-name' ).attr 'value', event.target.value
            this.model.set 'get_host', event.target.value

    }

    view = new InstanceView()

    return view