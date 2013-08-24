#############################
#  View Mode for design/resource
#############################

define [ 'ec2_service', 'ebs_model', 'aws_model', 'ami_model', 'favorite_model', 'MC', 'constant', 'event',
         'backbone', 'jquery', 'underscore'
], ( ec2_service, ebs_model, aws_model, ami_model, favorite_model, MC, constant, ide_event ) ->

    #private
    ami_instance_type = null
    community_ami = {}

    ResourcePanelModel = Backbone.Model.extend {

        defaults :
            'availability_zone'  : null
            'resoruce_snapshot'  : null
            'quickstart_ami'     : null
            'my_ami'             : null
            'favorite_ami'       : null
            'community_ami'      : null
            'check_required_service_count' : null

        service_count : 0

        initialize : ->

            me = this

            ######listen EC2_EBS_DESC_SSS_RETURN
            me.on 'EC2_EBS_DESC_SSS_RETURN', ( result ) ->
                console.log 'EC2_EBS_DESC_SSS_RETURN'

                if !result.is_error

                    me.set 'resoruce_snapshot', result.resolved_data
                    #
                    me._checkRequireServiceCount( 'EC2_EBS_DESC_SSS_RETURN' )

                null

            ######listen AWS_QUICKSTART_RETURN
            me.on 'AWS_QUICKSTART_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'AWS_QUICKSTART_RETURN: ' + region_name

                if !result.is_error

                    ami_list = []
                    ami_instance_type = result.resolved_data.ami_instance_type
                    if MC.data.instance_type
                        MC.data.instance_type[result.param[3]] = ami_instance_type
                    else
                        MC.data.instance_type = {}
                        MC.data.instance_type[result.param[3]] = ami_instance_type

                    _.map result.resolved_data.ami, ( value, key ) ->

                        value.imageId = key

                        _.map value, ( val, key ) ->
                            if val == ''
                                value[key] = 'None'
                            null

                        if value.kernelId == undefined or value.kernelId == ''
                            value.kernelId = "None"

                        #cache quickstart ami item to MC.data.dict_ami
                        value.instance_type = me._getInstanceType value
                        MC.data.dict_ami[key] = value

                        ami_list.push value
                        null

                    console.log 'get quistart ami: -> data region: ' + region_name + ', stack region: ' + MC.canvas.data.get('region')
                    if region_name == MC.canvas.data.get('region')
                        me.set 'quickstart_ami', ami_list

                    #cache config data for current region
                    MC.data.config[region_name].ami                 = result.resolved_data.ami
                    MC.data.config[region_name].ami_instance_type   = result.resolved_data.ami_instance_type
                    MC.data.config[region_name].instance_type       = result.resolved_data.instance_type
                    MC.data.config[region_name].price               = result.resolved_data.price
                    MC.data.config[region_name].vpc_limit           = result.resolved_data.vpc_limit
                    # reset az
                    MC.data.config[region_name].zone = {'item':[]}
                    MC.data.config[region_name].zone.item.push {'regionName':region_name, 'zoneName':i, 'zoneState':'available'} for i in result.resolved_data.zone
                    #MC.data.config[region_name].zone                = result.resolved_data.zone
                    #MC.data.config[region_name].zone                = null

                    MC.data.config[region_name].ami_list = ami_list

                    MC.data.config[region_name].favorite_ami = null
                    MC.data.config[region_name].my_ami = null

                    #get my AMI
                    me.myAmiService region_name

                    #get favorite AMI
                    me.favoriteAmiService region_name

                    #describe ami in stack
                    me.describeStackAmiService region_name

                    ide_event.trigger ide_event.RESOURCE_QUICKSTART_READY, region_name
                    #
                    me._checkRequireServiceCount( 'AWS_QUICKSTART_RETURN' )

                else
                    # to do

                #
                null

            ######listen EC2_AMI_DESC_IMAGES_RETURN
            me.on 'EC2_AMI_DESC_IMAGES_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'EC2_AMI_DESC_IMAGES_RETURN: ' + region_name

                if !result.is_error and result.param[5] and result.param[5][0] and result.param[5][0] == 'self'
                #####my ami

                    console.log 'EC2_AMI_DESC_IMAGES_RETURN: My AMI'

                    my_ami_list = {}

                    #cache my ami to my_ami
                    MC.data.config[region_name].my_ami = {}

                    if result.resolved_data

                        _.map result.resolved_data.item, (value)->
                            #cache my ami item to MC.data.dict_ami
                            value.instanceType = me._getInstanceType value
                            value.osType = me._getOSType value
                            MC.data.dict_ami[value.imageId] = value
                            null

                        my_ami_list = result.resolved_data

                        MC.data.config[region_name].my_ami = result.resolved_data


                    console.log 'get my ami: -> data region: ' + region_name + ', stack region: ' + MC.canvas.data.get('region')
                    if region_name == MC.canvas.data.get('region')
                        me.set 'my_ami', my_ami_list

                else
                #####

                    console.log 'EC2_AMI_DESC_IMAGES_RETURN:'

                    if result.resolved_data
                        _.map result.resolved_data.item, (value)->

                            #cache ami item in stack to MC.data.dict_ami
                            value.instanceType = me._getInstanceType value
                            MC.data.dict_ami[value.imageId] = value

                            null


                null

            ######listen AWS__PUBLIC_RETURN
            me.on 'AWS__PUBLIC_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'AWS__PUBLIC_RETURN: ' + region_name

                community_ami_list = {}

                if !result.is_error and  result.resolved_data
                    community_ami_list = _.extend result.resolved_data.ami, {timestamp: ( new Date() ).getTime()}
                    favorite_ami_ids = _.pluck ( me.get 'favorite_ami' ), 'resource_id'

                    for key, value of community_ami_list.result
                        if _.contains favorite_ami_ids, key
                            value.favorite = true


                    console.log 'get community ami: -> data region: ' + region_name + ', stack region: ' + MC.canvas.data.get('region')
                    if region_name == MC.canvas.data.get('region')
                        me.set 'community_ami', community_ami_list

                else

                    notification 'warning', 'Get Community AMIs failed'


                null

            ######listen FAVORITE_INFO_RETURN
            me.on 'FAVORITE_INFO_RETURN', ( result ) ->

                region_name = result.param[3]
                console.log 'FAVORITE_INFO_RETURN: ' + region_name


                legalData = _.filter result.resolved_data, (value, key) ->
                    return value.resource_info

                _.map legalData, ( value, key ) ->

                    value.resource_info = JSON.parse value.resource_info

                    _.map value.resource_info, ( val, key ) ->
                        if val == ''
                            value.resource_info[key] = 'None'

                        null

                    #cache favorite ami item to MC.data.dict_ami


                    value.resource_info.instanceType = me._getInstanceType value.resource_info
                    MC.data.dict_ami[value.resource_info.imageId] = value.resource_info

                    null


                console.log 'get favorite ami: -> data region: ' + region_name + ', stack region: ' + MC.canvas.data.get('region')
                if region_name == MC.canvas.data.get('region')
                    me.set 'favorite_ami', legalData

                #cache favorite_ami
                MC.data.config[region_name].favorite_ami = {}
                MC.data.config[region_name].favorite_ami = legalData

                null

            #####listen FAVORITE_ADD_RETURN
            me.on 'FAVORITE_ADD_RETURN', ( result ) =>

                region_name = result.param[3]
                console.log 'FAVORITE_ADD_RETURN: ' + region_name

                if !result.is_error
                    delete MC.data.config[region_name].favorite_ami
                    me.favoriteAmiService region_name
                    notification 'info', 'Add AMI to favorite succeed'
                else
                    notification 'error', 'Add AMI to favorite failed'
                null

            #listen FAVORITE_REMOVE_RETURN
            me.on 'FAVORITE_REMOVE_RETURN', ( result ) =>

                region_name = result.param[3]
                console.log 'FAVORITE_REMOVE_RETURN: ' + region_name
                if !result.is_error
                    delete MC.data.config[region_name].favorite_ami
                    me.favoriteAmiService region_name
                    notification 'info', 'Remove AMI to favorite succeed'
                else
                    notification 'error', 'Remove AMI to favorite succeed'


                null

        #call service
        describeAvailableZonesService : ( region_name, type ) ->

            me = this

            #init
            me.set 'availability_zone', null

            if  MC.data.config[region_name] and MC.data.config[region_name].zone

                res = $.extend true, {}, MC.data.config[region_name].zone

                #if type != 'NEW_STACK'

                $.each res.item, ( idx, value ) ->

                    $.each MC.canvas_data.layout.component.group, ( i, zone ) ->

                        if zone.name == value.zoneName

                            res.item[idx].isUsed = true

                            null
                #
                me._checkRequireServiceCount( 'describeAvailableZonesService' )
                #
                me.set 'availability_zone', res

            else

                #get service(model)
                ec2_service.DescribeAvailabilityZones { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, null, ( result ) ->

                    if !result.is_error
                    #DescribeAvailabilityZones succeed

                        region_name = result.param[3]
                        console.log 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN: ' + region_name

                        _.map result.resolved_data.item, (value)->
                            value.zoneShortName = value.zoneName.slice(-1).toUpperCase()
                            null

                        res = $.extend true, {}, result.resolved_data

                        if type != 'NEW_STACK'

                            $.each res.item, ( idx, value ) ->

                                $.each MC.canvas_data.layout.component.group, ( i, zone ) ->

                                    if zone.name == value.zoneName

                                        res.item[idx].isUsed = true

                                        null

                        console.log 'get az: -> data region: ' + region_name + ', stack region: ' + MC.canvas.data.get('region')
                        if region_name == MC.canvas.data.get('region')
                            me.set 'availability_zone', res

                        #cache az to MC.data.config[region_name].zone
                        MC.data.config[region_name].zone = result.resolved_data
                        #
                        me._checkRequireServiceCount( 'describeAvailableZonesService' )
                        #
                        null
                    else
                        #DescribeAvailabilityZones failed
                        console.log 'ec2.DescribeAvailabilityZones failed, error is ' + result.error_message

        #call service
        describeSnapshotsService : ( region_name ) ->

            me = this

            #init
            me.set 'resoruce_snapshot', null

            #get service(model)
            ebs_model.DescribeSnapshots { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null,  ["self"], null, null

        #call service
        quickstartService : ( region_name ) ->

            me = this

            #init
            me.set 'quickstart_ami', null

            #check cached data
            if (MC.data.config[region_name] and MC.data.config[region_name].ami_list )

                me.set 'quickstart_ami', MC.data.config[region_name].ami_list

                #get my AMI
                me.myAmiService region_name

                #get favorite AMI
                me.favoriteAmiService region_name

                #describe ami in stack
                me.describeStackAmiService region_name

                me._checkRequireServiceCount( 'AWS_QUICKSTART_RETURN' )

                ide_event.trigger ide_event.RESOURCE_QUICKSTART_READY, region_name

            else
                #get service(model)
                aws_model.quickstart { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name

            null

        #call service
        myAmiService : ( region_name ) ->

            me = this

            #init
            me.set 'my_ami', null

            #check cached data
            if MC.data.config[region_name] and MC.data.config[region_name].my_ami

                me.set 'my_ami', MC.data.config[region_name].my_ami

            else
                #get service(model)
                ami_model.DescribeImages { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, ["self"], null, null

            null

        describeStackAmiService : ( region_name )->

            me = this

            stack_ami_list = []

            _.map MC.canvas_data.component, (value)->

                if value.type == constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance

                    if MC.data.dict_ami

                        if not MC.data.dict_ami[value.resource.ImageId]

                            if value.resource.ImageId not in stack_ami_list

                                stack_ami_list.push value.resource.ImageId


            if stack_ami_list.length !=0
                ami_model.DescribeImages { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, stack_ami_list

        describeCommunityAmiService : ( region_name, name, platform, architecture, rootDeviceType, perPageNum, returnPage ) ->

            me = this

            if perPageNum == undefined or perPageNum == null

                perPageNum = 50

            if returnPage == undefined or returnPage == null or returnPage == 0 or returnPage == "0"

                returnPage = 1

            filters = {
                ami : {
                    name            :   name
                    platform        :   platform
                    architecture    :   architecture
                    rootDeviceType  :   rootDeviceType
                    perPageNum      :   parseInt(perPageNum, 10)
                    returnPage      :   parseInt(returnPage, 10)

                }

            }


            ami_list = []
            if community_ami[region_name] == undefined
                #get service(model)
                aws_model.Public { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, filters


            null
            #        _.map result.resolved_data.ami, ( value, key ) ->
            #             if value.isPublic == 'true' then value.isPublic = 'public' else value.isPublic = 'private'
            #             if value.architecture == 'x86_64' then value.architecture = '64-bit' else value.architecture = '32-bit'
            #             if value.rootDeviceType == 'ebs' then value.rootDeviceType = 'ebs' else value.rootDeviceType = 'instancestore'

            #             if value.name == undefined or value.name == null
            #                 value.name = 'None'
            #             low_case_name = value.name.toLowerCase()
            #             if 'ubuntu' in low_case_name
            #                 value.platform = 'ubuntu'
            #             else if 'centos' in low_case_name
            #                 value.platform = 'centos'
            #             else if 'redhat' in low_case_name
            #                 value.platform = 'redhat'
            #             else if 'windows' in low_case_name
            #                 value.platform = 'windows'
            #             else if 'suse' in low_case_name
            #                 value.platform = 'suse'
            #             else if 'amazonlinux' in low_case_name
            #                 value.platform = 'amazonlinux'
            #             else if 'fedora' in low_case_name
            #                 value.platform = 'fedora'
            #             else if 'gentoo' in low_case_name
            #                 value.platform = 'gentoo'
            #             else if 'debian' in low_case_name
            #                 value.platform = 'debian'
            #             else
            #                 value.platform = 'otherlinux'

            #             value.id = key
            #             value.instance_type = me._getInstanceType value

            #             _.map value, ( val, k ) ->

            #                 if val == ''
            #                     value[k] = 'None'

            #                 null

            #             ami_list.push value

            #         community_ami[region_name] = ami_list
            #         me.set 'community_ami', ami_list
            #         null

            # else
            #     me.set 'community_ami', community_ami[region_name]

        #call service
        favoriteAmiService : ( region_name ) ->

            me = this

            #init
            me.set 'favorite_ami', null

            #check cached data
            if MC.data.config[region_name] and MC.data.config[region_name].favorite_ami

                me.set 'favorite_ami', MC.data.config[region_name].favorite_ami

            else

                #get service(model)
                favorite_model.info { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name

            null

        addFav: ( region_name, amiId ) ->
            # temp hack
            amiVO = JSON.stringify @get( 'community_ami' ).result[ amiId ]
            amiId = { id: amiId, provider: 'AWS', 'resource': 'AMI', service: 'EC2' }

            me =  this

            favorite_model.add { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, amiId

        removeFav: ( region_name, amiId ) ->

            amiId = [ amiId ]

            me = this

            favorite_model.remove { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, amiId

            # remove favorite action is not very important and for instant reason I omit return value validation and change data directly.

            delete MC.data.config[region_name].favorite_ami
            @resetFavData 'remove', amiId[ 0 ]

        resetFavData: ( action, data ) ->
            if action is 'add'

            else if action is 'remove'
                favorite_ami = @get 'favorite_ami'
                new_favorite_ami = _.reject favorite_ami, ( ami ) ->
                    return ami.resource_id is data

                @set 'favorite_ami', new_favorite_ami

        getIgwStatus : ->

            isUsed = false

            $.each MC.canvas_data.component, ( key, comp ) ->

                if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_InternetGateway

                    isUsed = true

                    return false

            isUsed

        getVgwStatus : ->

            isUsed = false

            $.each MC.canvas_data.component, ( key, comp ) ->

                if comp.type == constant.AWS_RESOURCE_TYPE.AWS_VPC_VPNGateway

                    isUsed = true

                    return false

            isUsed

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

        _getOSType : ( ami ) ->

            #return osType by ami.name | ami.description | ami.imageLocation

            osTypeList = ['centos', 'redhat', 'redhat', 'ubuntu', 'debian', 'fedora', 'gentoo', 'opensus', 'suse','amazon', 'amazon']

            osType = 'linux-other'

            if  ami.platform and ami.platform == 'windows'

                osType = 'win'

            else

                #check ami.name
                found = osTypeList.filter (word) -> ~ami.name.toLowerCase().indexOf word

                #check ami.description
                if found.length == 0
                    found = osTypeList.filter (word) -> ~ami.description.toLowerCase().indexOf word

                #check ami.imageLocation
                if found.length == 0
                    found = osTypeList.filter (word) -> ~ami.imageLocation.toLowerCase().indexOf word

            if found.length == 0
                osType = 'unknown'
            else
                osType = found[0]

            osType

        _checkRequireServiceCount : ( name ) ->
            console.log '_checkRequireServiceCount, name = ' + name
            #
            @service_count = @service_count + 1
            #
            @set 'check_required_service_count', @service_count
            #
            null

    }

    model = new ResourcePanelModel()

    return model
