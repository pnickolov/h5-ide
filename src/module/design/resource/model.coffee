#############################
#  View Mode for design/resource
#############################

define [ 'ec2_model',
         'backbone', 'jquery', 'underscore'
], ( ec2_model ) ->

    #private
    ResourcePanelModel = Backbone.Model.extend {

        defaults :
            'vailability_zone'  : null

        #app list
        describeAvailableZonesService : ( region_name ) ->

            me = this

            #get service(model)
            ec2_model.DescribeAvailabilityZones { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, null
            ec2_model.once 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN', ( result ) ->
                console.log 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN'
                console.log result
                me.set 'vailability_zone', result.resolved_data
                null

    }

    model = new ResourcePanelModel()

    return model