#############################
#  View Mode for design
#############################

define [ 'Design', 'MC', 'event', 'constant', 'app_model', 'stack_model', 'instance_service', 'ami_service', 'i18n!nls/lang.js', 'underscore', 'backbone' ], ( Design, MC, ide_event, constant, app_model, stack_model, instance_service, ami_service, lang, _) ->

    #private
    DesignModel = Backbone.Model.extend {

        defaults :
            snapshot : null

        initialize : ->

            me = this

            #listen APP_RESOURCE_RETURN
            me.on 'APP_RESOURCE_RETURN', ( result ) ->
                app_id = result.param[4]
                console.log 'APP_RESOURCE_RETURN', app_id

                if !result.is_error

                    try

                        if app_id is MC.data.current_tab_id
                            @setCurrentResource result
                        else
                            @setOriginResource result, app_id

                    catch error

                        app_name = MC.forge.app.getNameById app_id
                        notification 'error', sprintf lang.ide.TOOL_MSG_INFO_APP_REFRESH_FAILED, if app_name then app_name else app_id + '(closed)'

                        console.error '[error]APP_RESOURCE_RETURN' + error

                else
                    #TO-DO

                #

                # old design flow
                #ide_event.trigger ide_event.SWITCH_MAIN if app_id == MC.canvas_data.id

                # new design flow
                ide_event.trigger ide_event.SWITCH_MAIN if app_id == MC.forge.other.canvasData().get( 'id' )

                null

            #listen APP_INFO_RETURN
            me.on 'APP_INFO_RETURN', ( result ) ->
                console.log 'APP_INFO_RETURN'

                app_id = result.param[4][0]

                # update canvas_data when on current tab

                # old design flow
                #if app_id == MC.canvas_data.id

                # new design flow
                if app_id == MC.forge.other.canvasData().get( 'id' )
                    @setCanvasData result.resolved_data[ 0 ]
                    @setOriginData result.resolved_data[ 0 ]

                # update MC.Tab[app_id]
                else
                    @updateAppTabDate       result.resolved_data[ 0 ], app_id
                    @updateAppTabOriginDate result.resolved_data[ 0 ], app_id

                # get app.resource
                @getAppResourcesService result.param[3], app_id

                null

            #listen GET_NOT_EXIST_AMI_RETURN
            me.on 'GET_NOT_EXIST_AMI_RETURN', ( result ) ->

                if $.type(result.resolved_data) == 'array'
                    _.each result.resolved_data, ( ami ) ->
                        ami.osType = MC.aws.ami.getOSType ami
                        if not ami.osFamily
                            ami.osFamily = MC.aws.aws.getOSFamily(ami.osType)
                        ami.instanceType = MC.aws.ami.getInstanceType(ami).join(', ')
                        MC.data.dict_ami[ami.imageId] = ami
                        null
                ide_event.trigger ide_event.SWITCH_MAIN
                null

        #############################
        #  tab
        #############################

        addTab : ( tab_id, snapshot, data, property_panel, origin_data, origin_ta_valid, design_model ) ->
            console.log 'addTab'

            MC.tab[ tab_id ] =
                'snapshot'        : snapshot
                'data'            : data
                'property_panel'  : property_panel
                'origin_data'     : origin_data
                'origin_ta_valid' : origin_ta_valid
                'design_model'    : design_model

            null

        deleteTab    : ( tab_id ) ->
            console.log 'deleteTab'

            # delete MC.tab
            delete MC.tab[ tab_id ]
            console.log MC.tab

            # delete MC.process and MC.data.process
            MC.forge.other.deleteProcess tab_id if MC.process[ tab_id ] and tab_id.split('-')[0] is 'process'
            console.log MC.process

            # delete appview
            obj = MC.forge.other.getCacheMap tab_id
            if obj and obj.state is 'ERROR' or tab_id.split('-')[0] is 'appview'
                MC.forge.other.delCacheMap tab_id

            null

        getTab : ( type, tab_id ) ->
            console.log 'getTab'
            #set random number
            @set 'snapshot', Math.round(+new Date())
            #
            ide_event.trigger ide_event.SWITCH_WAITING_BAR
            #
            @set 'snapshot',      MC.tab[ tab_id ].snapshot
            @setCanvasData        MC.tab[ tab_id ].data
            @setOriginData        MC.tab[ tab_id ].origin_data
            @setCurrentResource   MC.tab[ tab_id ].origin_resource if MC.tab[ tab_id ].origin_resource
            @setTAValidation      MC.tab[ tab_id ].origin_ta_valid
            @setPropertyPanel     MC.tab[ tab_id ].property_panel
            @setDesignModel       $.extend true, {}, MC.tab[ tab_id ].design_model
            #
            null

        updateAppTabDate : ( data, tab_id ) ->
            console.log 'updateAppTabDate'
            MC.tab[ tab_id ].data = $.extend( true, {}, data ) if MC.tab[ tab_id ]
            null

        updateAppTabOriginDate : ( data, tab_id ) ->
            console.log 'updateAppTabOriginDate'
            MC.tab[ tab_id ].origin_data = $.extend( true, {}, data ) if MC.tab[ tab_id ]
            null

        setCanvasData : ( data ) ->
            console.log 'setCanvasData'

            # old design flow
            #MC.canvas_data = $.extend true, {}, data

            # new design flow
            MC.forge.other.canvasData().save data

            null

        getCanvasData : () ->
            console.log 'getCanvasData'
            #MC.canvas_data

            # old design flow
            #$.extend true, {}, MC.canvas_data

            # new design flow
            MC.forge.other.canvasData().data()

        setPropertyPanel : ( property_panel ) ->
            console.log 'setPropertyPanel'
            @trigger "SET_PROPERTY_PANEL", property_panel
            null

        setOriginData : ( data ) ->
            console.log 'setOriginData'

            # old design flow
            #MC.data.origin_canvas_data = $.extend true, {}, data

            # new design flow
            MC.forge.other.canvasData().origin data

            null

        getOriginData :  ->
            console.log 'getOriginData'

            # old design flow
            #$.extend true, {}, MC.data.origin_canvas_data

            # new design flow
            MC.forge.other.canvasData().origin()

        setTAValidation : ( data ) ->
            console.log 'setTAValidation'
            MC.ta.list = $.extend true, [], data
            null

        getTAValidation : () ->
            console.log 'getTAValidation'
            #MC.ta.list
            $.extend true, [], MC.ta.list

        setOriginResource : ( data, tab_id ) ->
            console.log 'setOriginResource', data, tab_id
            MC.tab[ tab_id ].origin_resource = $.extend true, {}, data if MC.tab[ tab_id ]
            null

        setDesignModel : ( design ) ->
            console.log 'setDesignModel'
            design.use()
            null

        getDesignModel : () ->
            console.log 'getDesignModel'
            Design.instance()

        #saveProcessTab : ( tab_id ) ->
        #    console.log 'saveProcessTab'
        #    if !MC.tab[ tab_id ] then MC.tab[ tab_id ] = $.extend true, {}, MC.process[ tab_id ]
        #    null

        #############################
        #  api
        #############################

        describeInstancesOfASG : (region) ->
            console.log 'describeInstancesOfASG', region

            comp_layout   = MC.canvas.data.get('layout.component.group')
            comp_data     = MC.canvas.data.get('component')
            instance_ids = []


            try
                #find ASG in comp_layout
                _.map comp_layout, ( value, id ) ->

                    if value.type == constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group

                        asg_arn         = if comp_data[id] then comp_data[id].resource.AutoScalingGroupARN else null
                        asg_res          = if asg_arn then MC.data.resource_list[region][asg_arn] else null
                        instance_memeber = if asg_res and asg_res.Instances then asg_res.Instances.member else null

                        #find instance in ASG
                        if instance_memeber
                            _.map instance_memeber, (ins, i) ->
                                instance_ids.push ins.InstanceId
                                null
                    null

                ######
                src = {}
                src.sender = this
                src.model  = null

                if instance_ids.length > 0
                    instance_service.DescribeInstances src, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, instance_ids, null, ( aws_result ) ->

                        if !aws_result.is_error
                            #DescribeInstances succeed
                            if aws_result.resolved_data
                                 _.map aws_result.resolved_data, (ins, i) ->
                                    MC.data.resource_list[region][ins.instanceId] = ins
                                    null
                            null
                        else
                            #DescribeInstances failed
                            console.log 'instance.DescribeInstances failed, error is ' + aws_result.error_message

                else

            catch error

                console.error '[error]describeInstancesOfASG'

            null

        appInfoService : ( region_name, app_id ) ->
            console.log 'appInfoService', region_name, app_id
            app_model.info { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, [ app_id ]

        getAppResourcesService : ( region, app_id )->
            console.log 'getAppResourcesService', region, app_id
            app_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, app_id

        getAllNotExistAmiInStack : ( region, tab_id )->

            ide_event.trigger ide_event.SWITCH_WAITING_BAR, null, true

            me = this

            ami_list = []

            # old design flow
            #_.each MC.canvas_data.component, (compObj) ->

            # new design flow
            _.each MC.forge.other.canvasData().get( 'component' ), (compObj) ->

                if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance  or compObj.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
                    imageId = compObj.resource.ImageId
                    if imageId and !MC.data.dict_ami[imageId]
                        ami_list.push imageId

                null
            if ami_list.length
                stack_model.get_not_exist_ami { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, ami_list

        returnAppState : ( type, state ) ->
            console.log 'returnAppState', type, state

            if state
                temp = state
            else
                switch type
                    when 'START_APP'     then temp = constant.APP_STATE.APP_STATE_STARTING
                    when 'STOP_APP'      then temp = constant.APP_STATE.APP_STATE_STOPPING
                    when 'TERMINATE_APP' then temp = constant.APP_STATE.APP_STATE_TERMINATING
                    else
                        console.log 'current type = ' + type + ', state is =' + state
                        console.log MC.data.process[ MC.data.current_tab_id ]
            temp

        setCurrentResource : ( data ) ->
            console.log 'setCurrentResource', data
            result          = $.extend true, {}, data
            app_id          = result.param[4]
            region          = result.param[3]
            resource_source = result.resolved_data

            if resource_source

                #clear old app data in MC.data.resource_list

                # old design flow
                #MC.forge.app.clearResourceInCache MC.canvas_data

                # new design flow
                MC.forge.app.clearResourceInCache MC.forge.other.canvasData().data()

                #cache new app data
                MC.aws.aws.cacheResource resource_source, region, false
                #
                @describeInstancesOfASG region

            # old design flow
            #update instance icon of app
            MC.aws.instance.updateStateIcon app_id
            MC.aws.asg.updateASGCount app_id
            MC.aws.eni.updateServerGroupState app_id
            #update deleted resource style
            MC.forge.app.updateDeletedResourceState MC.canvas_data
            # old design flow

            # new design flow
            #Design.instance().trigger Design.EVENT.AwsResourceUpdated

            #re-draw connection
            MC.canvas_data.layout.connection = {}
            #MC.canvas.initLine()
            #MC.canvas.reDrawSgLine()

            #update property panel
            uid = $canvas.selected_node()[0]
            if uid
                MC.canvas.select uid

            # re-set origin_data

            # old design flow
            #@setOriginData MC.canvas_data

            # new design flow
            @setOriginData MC.forge.other.canvasData().data()

            # delete current origin_resource
            MC.tab[ app_id ].origin_resource = null if MC.tab and MC.tab[ app_id ] and MC.tab[ app_id ].origin_resource
            #
            console.log 'set app.resource end'

    }

    model = new DesignModel()

    return model
