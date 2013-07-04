#############################
#  View Mode for design/resource
#############################

define [ 'ec2_model', 'ebs_model', 'aws_model', 'ami_model', 'favorite_model'
         'backbone', 'jquery', 'underscore'
], ( ec2_model, ebs_model, aws_model, ami_model, favorite_model ) ->

    #private
    ami_instance_type = null
    community_ami = null

    ResourcePanelModel = Backbone.Model.extend {

        defaults :
            'availability_zone'  : null
            'resoruce_snapshot'  : null
            'quickstart_ami'     : null
            'my_ami'             : null
            'favorite_ami'       : null
            'community_ami'      : null

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
                ami_list = []
                ami_instance_type = result.resolved_data.ami_instance_type
                _.map result.resolved_data.ami, ( value, key ) ->
                    value.id = key
                    if value.kernelId == undefined or value.kernelId == ''
                        value.kernelId = "None"
                    
                    value.instance_type = me._getInstanceType value
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
                me.set 'my_ami', result.resolved_data
                null

        describeCommunityAmiService : ( region_name ) ->

            me = this

            me.set 'community_ami', null

            if not community_ami
                #get service(model)
                aws_model.Public { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name
                aws_model.once 'AWS__PUBLIC_RETURN', ( result ) ->
                    console.log 'AWS__PUBLIC_RETURN'
                    ami_list = []
                    
                        
                    
                    null

            me.set 'community_ami', community_ami

        #call service
        favoriteAmiService : ( region_name ) ->

            me = this

            #init
            me.set 'favorite_ami', null

            #get service(model)
            favorite_model.info { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name
            favorite_model.once 'FAVORITE_INFO_RETURN', ( result ) ->
                console.log 'FAVORITE_INFO_RETURN'
                _.map result.resolved_data, ( value ) ->
                    value.resource_info = $.parseJSON value.resource_info
                    _.map value.resource_info, ( val, key ) ->
                        if val == ''
                            value.resource_info[key] = 'None'

                        null
                    null
                me.set 'favorite_ami', result.resolved_data
                null

        _getInstanceType : ( ami ) ->
            instance_type = ami_instance_type
            if ami.virtualizationType == 'hvm'
                instance_type = instance_type.windows
            else
                instance_type = instance_type.linux
            if ami.rootDeviceType == 'ebs'
                instance_type = instance_type.ebs
            else
                instance_type = instance_type['instance store']
            if ami.architecture == 'x86_64'
                instance_type = instance_type["64"]
            else
                instance_type = instance_type["32"]
            instance_type = instance_type[ami.virtualizationType]

            instance_type.join ', '
    }

    model = new ResourcePanelModel()

    return model