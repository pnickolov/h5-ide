#############################
#  View(UI logic) for design/property/instacne
#############################

define [ 'event', 'MC', 'backbone', 'jquery', 'handlebars' ], ( ide_event, MC ) ->

    InstanceView = Backbone.View.extend {

        el       : $ document
        tagName  : $ '.property-details'

        template : Handlebars.compile $( '#property-instance-tmpl' ).html()

        events   :
            'change .instance-name' : 'instanceNameChange'
            'change .instance-type-select' : 'instanceTypeSelect'
            'click #sg-info-list li' : 'openSgPanel'
            'OPTION_CHANGE #instance-type-select' : "instanceTypeSelect"

        render     : ( attributes ) ->
            console.log 'property:instance render'
            $( '.property-details' ).html this.template attributes

        instanceNameChange : ( event ) ->
            console.log 'instanceNameChange'
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setHost cid, event.target.value

        openSgPanel : ->
            console.log 'openSgPanel'
            ide_event.trigger 'OPEN_SG'

        instanceTypeSelect : ( event, value )->
            console.log event
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setInstanceType cid, value
            
    }

    view = new InstanceView()

    return view