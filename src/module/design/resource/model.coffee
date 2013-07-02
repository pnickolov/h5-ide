#############################
#  View Mode for design/resource
#############################

define [ 'ec2_model', 'ebs_model', 'aws_model', 'ami_model', 'favorite_model'
         'backbone', 'jquery', 'underscore'
], ( ec2_model, ebs_model, aws_model, ami_model, favorite_model ) ->

    #private
    ResourcePanelModel = Backbone.Model.extend {

        defaults :
            'availability_zone'  : null
            'resoruce_snapshot'  : null
            'quickstart_ami'     : null
            'my_ami'             : null
            'favorite_ami'       : null

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
            ebs_model.DescribeSnapshots { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null,  ["self"], null, null
            ebs_model.once 'EC2_EBS_DESC_SSS_RETURN', ( result ) ->
                console.log 'EC2_EBS_DESC_SSS_RETURN'
                console.log result
                me.set 'resoruce_snapshot', result.resolved_data
                null

        #call service
        quickstartService : ( region_name ) ->

            me = this

            #init
            me.set 'quickstart_ami', null

            #get service(model)
            aws_model.quickstart { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name
            aws_model.once 'AWS_QUICKSTART_RETURN', ( result ) ->
                console.log 'AWS_QUICKSTART_RETURN'
                console.log result
                ami_list = []
                _.map result.resolved_data.ami, ( value, key ) ->
                    value.id = key
                    ami_list.push value
                    
                me.set 'quickstart_ami', ami_list
                null

        #call service
        myAmiService : ( region_name ) ->

            me = this

            #init
            me.set 'my_ami', null

            #get service(model)
            ami_model.DescribeImages { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, ["self"], null, null
            ami_model.once 'EC2_AMI_DESC_IMAGES_RETURN', ( result ) ->
                console.log 'EC2_AMI_DESC_IMAGES_RETURN'
                console.log result
                me.set 'my_ami', result.resolved_data
                null

        #call service
        favoriteAmiService : ( region_name ) ->

            me = this

            #init
            me.set 'favorite_ami', null

            #get service(model)
            favorite_model.info { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name
            favorite_model.once 'FAVORITE_INFO_RETURN', ( result ) ->
                console.log 'FAVORITE_INFO_RETURN'
                console.log result
                _.map result.resolved_data, ( value ) ->
                    value.resource_info = $.parseJSON value.resource_info
                    _.map value.resource_info, ( val, key ) ->
                        if val == ''
                            value.resource_info[key] = 'None'

                        null
                    null
                me.set 'favorite_ami', result.resolved_data
                null

    }

    model = new ResourcePanelModel()

    return model