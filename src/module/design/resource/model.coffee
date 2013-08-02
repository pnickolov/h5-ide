#############################
#  View Mode for design/resource
#############################

define [ 'ec2_model', 'ebs_model', 'aws_model', 'ami_model', 'favorite_model', 'MC', 'constant', 'event',
         'backbone', 'jquery', 'underscore'
], ( ec2_model, ebs_model, aws_model, ami_model, favorite_model, MC, constant, ide_event ) ->

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


        #call service
        describeAvailableZonesService : ( region_name, type ) ->

            me = this

            #init
            me.set 'availability_zone', null

            if  MC.data.config[region_name] and MC.data.config[region_name].zone

                res = $.extend true, {}, MC.data.config[region_name].zone

                if type != 'NEW_STACK'

                    $.each res.item, ( idx, value ) ->

                        $.each MC.canvas_data.layout.component.group, ( i, zone ) ->

                            if zone.name == value.zoneName

                                res.item[idx].isUsed = true

                                null

                me.set 'availability_zone', res

            else

                #get service(model)
                ec2_model.DescribeAvailabilityZones { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, null
                ec2_model.once 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN', ( result ) ->
                    console.log 'EC2_EC2_DESC_AVAILABILITY_ZONES_RETURN'
                    console.log result
                    _.map result.resolved_data.item, (value)->
                        value.zoneShortName = value.zoneName.slice(-2)
                        null

                    res = $.extend true, {}, result.resolved_data

                    if type != 'NEW_STACK'

                        $.each res.item, ( idx, value ) ->

                            $.each MC.canvas_data.layout.component.group, ( i, zone ) ->

                                if zone.name == value.zoneName

                                    res.item[idx].isUsed = true

                                    null


                    me.set 'availability_zone', res

                    #cache az to MC.data.config[region_name].zone
                    MC.data.config[region_name].zone = result.resolved_data

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

            #check cached data
            if (MC.data.config[region_name] and MC.data.config[region_name].ami_list )

                me.set 'quickstart_ami', MC.data.config[region_name].ami_list

                #get my AMI
                me.myAmiService region_name

                #get favorite AMI
                me.favoriteAmiService region_name

                #describe ami in stack
                me.describeStackAmiService region_name

                ide_event.trigger ide_event.RESOURCE_QUICKSTART_READY

            else
                #get service(model)
                aws_model.quickstart { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name
                aws_model.once 'AWS_QUICKSTART_RETURN', ( result ) ->
                    console.log 'AWS_QUICKSTART_RETURN'
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


                    me.set 'quickstart_ami', ami_list

                    #cache config data for current region
                    MC.data.config[region_name]                     = {}
                    MC.data.config[region_name].ami                 = result.resolved_data.ami
                    MC.data.config[region_name].ami_instance_type   = result.resolved_data.ami_instance_type
                    MC.data.config[region_name].instance_type       = result.resolved_data.instance_type
                    MC.data.config[region_name].price               = result.resolved_data.price
                    MC.data.config[region_name].vpc_limit           = result.resolved_data.vpc_limit
                    #MC.data.config[region_name].zone                = result.resolved_data.zone
                    MC.data.config[region_name].zone                = null

                    MC.data.config[region_name].ami_list = ami_list

                    MC.data.config[region_name].favorite_ami = null
                    MC.data.config[region_name].my_ami = null

                    #get my AMI
                    me.myAmiService region_name

                    #get favorite AMI
                    me.favoriteAmiService region_name

                    #describe ami in stack
                    me.describeStackAmiService region_name

                    ide_event.trigger ide_event.RESOURCE_QUICKSTART_READY

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
                ami_model.DescribeImages { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, null, ["self"], null, null
                ami_model.once 'EC2_AMI_DESC_IMAGES_RETURN', ( result ) ->

                    console.log 'EC2_AMI_DESC_IMAGES_RETURN'

                    #cache my ami to my_ami
                    MC.data.config[region_name].my_ami = {}

                    if result.resolved_data

                        _.map result.resolved_data.item, (value)->
                            #cache my ami item to MC.data.dict_ami
                            value.instanceType = me._getInstanceType value
                            value.osType = me._getOSType value
                            MC.data.dict_ami[value.imageId] = value
                            null

                        me.set 'my_ami', result.resolved_data

                        MC.data.config[region_name].my_ami = result.resolved_data

                    null
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
                ami_model.DescribeImages { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, stack_ami_list
                ami_model.once 'EC2_AMI_DESC_IMAGES_RETURN', ( result ) ->
                    console.log 'EC2_AMI_DESC_IMAGES_RETURN'

                    _.map result.resolved_data.item, (value)->

                        #cache ami item in stack to MC.data.dict_ami
                        value.instanceType = me._getInstanceType value
                        MC.data.dict_ami[value.imageId] = value

                        null
                    null


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
                aws_model.Public { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, filters
                aws_model.once 'AWS__PUBLIC_RETURN', ( result ) ->
                    console.log 'AWS__PUBLIC_RETURN'
                    if result.resolved_data
                        me.set 'community_ami', _.extend result.resolved_data.ami, {timestamp: ( new Date() ).getTime()}
                    else
                        me.set 'community_ami', null

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
                favorite_model.info { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name
                favorite_model.once 'FAVORITE_INFO_RETURN', ( result ) ->
                    console.log 'FAVORITE_INFO_RETURN'
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

                    me.set 'favorite_ami', legalData

                    #cache favorite_ami
                    MC.data.config[region_name].favorite_ami = {}
                    MC.data.config[region_name].favorite_ami = legalData

                    null
            null

        addFav: ( region_name, amiId ) ->
            # temp hack
            amiVO = JSON.stringify @get( 'community_ami' ).result[ amiId ]
            amiId = { amiVO: amiVO, id: amiId, provider: 'AWS', 'resource': 'AMI', service: 'EC2' }

            favorite_model.once 'FAVORITE_ADD_RETURN', ( result ) =>
                if result.return_code is 0
                    delete MC.data.config[region_name].favorite_ami
                    @favoriteAmiService region_name

            favorite_model.add { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, amiId

        removeFav: ( region_name, amiId ) ->
            favorite_model.once 'FAVORITE_REMOVE_RETURN', ( result ) =>
                if result.return_code is 0
                    delete MC.data.config[region_name].favorite_ami
                    @favoriteAmiService region_name

            amiId = [ amiId ]

            favorite_model.remove { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, amiId

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

    }

    model = new ResourcePanelModel()

    return model
