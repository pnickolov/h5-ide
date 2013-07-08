#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-instance-tmpl' ).html()

        events   :
            'change .instance-name' : 'instanceNameChange'
            'click #sg-info-list li' : 'openSgPanel'

        render     : () ->
            console.log 'property:instance render'
            $( '.property-details' ).html this.template this.model.attributes

        instanceNameChange : ( event ) ->
            console.log 'instanceNameChange'
            $( '.instance-name' ).attr 'value', event.target.value
            this.model.set 'get_host', event.target.value

        openSgPanel : ->
            console.log 'openSgPanel'
            ide_event.trigger 'OPEN_SG'

    }

    view = new InstanceView()

    return view