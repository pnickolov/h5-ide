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
            'change #property-instance-ebs-optimized' : 'ebsOptimizedSelect'
            'change #property-instance-enable-cloudwatch' : 'cloudwatchSelect'
            'change #property-instance-user-data' : 'userdataChange'
            
            'click #sg-info-list li' : 'openSgPanel'
            'OPTION_CHANGE #instance-type-select' : "instanceTypeSelect"
            'OPTION_CHANGE #tenancy-select' : "tenancySelect"
            

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
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setInstanceType cid, value

        ebsOptimizedSelect : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setEbsOptimized cid, event.target.checked

        tenancySelect : ( event, value ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setTenancy cid, value

        cloudwatchSelect : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setCloudWatch cid, event.target.checked

        userdataChange : ( event ) ->
            cid = $( '#instance-property-detail' ).attr 'component'
            this.model.setUserData cid, event.target.value
            #console.log event.target.value
    }

    view = new InstanceView()

    return view