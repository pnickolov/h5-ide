#############################
#  View Mode for design/resource
#############################

define [ 'ec2_model', 'ebs_model'
         'backbone', 'jquery', 'underscore'
], ( ec2_model, ebs_model ) ->

    #private
    ResourcePanelModel = Backbone.Model.extend {

        defaults :
            'availability_zone'  : null
            'resoruce_snapshot'  : null

        #call service
        describeAvailableZonesService : ( region_name ) ->

            me = this

            #init
            me.set 'availability_zone', null

            #get service(model)
            ec2_model.DescribeAvailabilityZones { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, null
            ec2_model.once 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN', ( result ) ->
                console.log 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN'
                console.log result
                me.set 'availability_zone', result.resolved_data
                null

        #call service
        describeSnapshotsService : ( region_name ) ->

            me = this

            #init
            me.set 'resoruce_snapshot', null

            #get service(model)
            ebs_model.DescribeSnapshots { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, null, null, null
            ebs_model.once 'EC2_EBS_DESC_SSS_RETURN', ( result ) ->
                console.log 'EC2_EBS_DESC_SSS_RETURN'
                console.log result
                me.set 'resoruce_snapshot', result.resolved_data
                null

    }

    model = new ResourcePanelModel()

    return model