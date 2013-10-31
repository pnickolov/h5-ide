#############################
#  View Mode for design
#############################

define [ 'MC', 'event', 'constant', 'app_model', 'stack_model', 'instance_service', 'ami_service', 'i18n!nls/lang.js', 'underscore', 'backbone' ], ( MC, ide_event, constant, app_model, stack_model, instance_service, ami_service, lang, _) ->

    #private
    DesignModel = Backbone.Model.extend {

        defaults :
            snapshot : null

        initialize : ->

            me = this

            #listen APP_RESOURCE_RETURN
            me.on 'APP_RESOURCE_RETURN', ( result ) ->

                app_id = result.param[4]
                console.log 'APP_RESOURCE_RETURN:' + app_id

                if !result.is_error

                    try

                        region = result.param[3]
                        resource_source = result.resolved_data

                        if resource_source
                            MC.aws.aws.cacheResource resource_source, region
                            me.describeInstancesOfASG region

                        #update instance icon of app
                        MC.aws.instance.updateStateIcon app_id

                        MC.aws.asg.updateASGCount app_id

                        #update canvas when get instance info
                        ide_event.trigger ide_event.CANVAS_UPDATE_APP_RESOURCE

                        #update property panel
                        uid = MC.canvas_property.selected_node[0]
                        if uid
                            MC.canvas.select uid


                        #app_name = MC.forge.app.getNameById app_id
                        #notification 'info', sprintf lang.ide.TOOL_MSG_INFO_APP_REFRESH_FINISH, if app_name then app_name else app_id + '(closed)'

                    catch error

                        app_name = MC.forge.app.getNameById app_id
                        notification 'info', sprintf lang.ide.TOOL_MSG_INFO_APP_REFRESH_FAILED, if app_name then app_name else app_id + '(closed)'

                        console.error '[error]APP_RESOURCE_RETURN'

                else
                    #TO-DO
                #
                ide_event.trigger ide_event.SWITCH_MAIN

                null

            #listen APP_INFO_RETURN
            me.on 'APP_INFO_RETURN', ( result ) ->
                console.log 'APP_INFO_RETURN'
                #
                app_id = result.param[4][0]
                # update canvas_data when on current tab
                if app_id == MC.canvas_data.id
                    #MC.canvas_data =  $.extend(true, {}, result.resolved_data[0])
                    @setCanvasData result.resolved_data[ 0 ]
                    @setOriginData result.resolved_data[ 0 ]
                # update MC.Tab[app_id]
                else
                    #MC.tab[app_id].data = $.extend(true, {}, result.resolved_data[0]) if MC.tab[ app_id ]
                    @updateAppTabDate       result.resolved_data[ 0 ], app_id
                    @updateAppTabOriginDate result.resolved_data[ 0 ], app_id
                null

            me.on 'GET_NOT_EXIST_AMI_RETURN', ( result ) ->

                if $.type(result.resolved_data) == 'array'
                    _.map result.resolved_data, ( ami ) ->
                        ami.instanceType = MC.aws.ami.getInstanceType(ami).join(', ')
                        ami.osType = MC.aws.ami.getOSType ami
                        MC.data.dict_ami[ami.imageId] = ami
                        ide_event.trigger ide_event.SWITCH_MAIN
                        null
                null

        saveTab : ( tab_id, snapshot, data, property, property_panel, origin_data ) ->
            console.log 'saveTab'
            MC.tab[ tab_id ] = { 'snapshot' : snapshot, 'data' : data, 'property' : property, 'property_panel' : property_panel, 'origin_data' : origin_data }
            null

        saveProcessTab : ( tab_id ) ->
            console.log 'saveProcessTab'
            if !MC.tab[ tab_id ]     then MC.tab[ tab_id ] = MC.process[ tab_id ]
            #if MC.process[ tab_id ] then delete MC.process[ tab_id ]
            null

        readTab : ( type, tab_id ) ->
            console.log 'readTab'
            #set random number
            this.set 'snapshot', Math.round(+new Date())
            #
            ide_event.trigger ide_event.SWITCH_WAITING_BAR
            #
            this.set 'snapshot',      MC.tab[ tab_id ].snapshot
            #
            this.setCanvasData        MC.tab[ tab_id ].data
            #
            this.setOriginData        MC.tab[ tab_id ].origin_data
            #
            this.setCanvasProperty    MC.tab[ tab_id ].property
            #
            this.setPropertyPanel     MC.tab[ tab_id ].property_panel
            #
            null

        updateTab : ( old_tab_id, tab_id ) ->
            console.log 'updateTab'
            if MC.tab[ old_tab_id ] is undefined then return
            #
            MC.tab[ tab_id ] = { 'snapshot' : MC.tab[ old_tab_id ].snapshot, 'data' : MC.tab[ old_tab_id ].data, 'property' : MC.tab[ old_tab_id ].property, 'origin_data' : MC.tab[ old_tab_id ].origin_data }
            #
            this.deleteTab old_tab_id

        updateAppTab : ( region_name, app_id ) ->
            console.log 'updateAppTab'
            app_model.info { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region_name, [ app_id ]

        updateAppTabDate : ( data, tab_id ) ->
            console.log 'updateAppTabDate'
            MC.tab[ tab_id ].data = $.extend( true, {}, data ) if MC.tab[ tab_id ]
            null

        updateAppTabOriginDate : ( data, tab_id ) ->
            console.log 'updateAppTabOriginDate'
            MC.tab[ tab_id ].origin_canvas_data = $.extend( true, {}, data ) if MC.tab[ tab_id ]
            null

        deleteTab    : ( tab_id ) ->
            console.log 'deleteTab'
            delete MC.tab[ tab_id ]
            #intercom
            #if tab_id.split( '-' )[0] is 'stack'
            #    window.intercomSettings.stack_total = window.intercomSettings.stack_total - 1
            #
            console.log MC.tab
            #
            if MC.process[ tab_id ] then delete MC.process[ tab_id ]
            null

        setCanvasData : ( data ) ->
            console.log 'setCanvasData'
            MC.canvas_data = $.extend true, {}, data
            null

        getCanvasData : () ->
            console.log 'getCanvasData'
            #MC.canvas_data
            $.extend true, {}, MC.canvas_data

        setCanvasProperty : ( property ) ->
            console.log 'setCanvasProperty'
            MC.canvas_property = property
            null

        getCanvasProperty : () ->
            console.log 'getCanvasProperty'
            MC.canvas_property

        setPropertyPanel : ( property_panel ) ->
            console.log 'setPropertyPanel'
            this.trigger "SET_PROPERTY_PANEL", property_panel
            null

        setOriginData : ( data ) ->
            console.log 'setOriginData'
            MC.data.origin_canvas_data = $.extend true, {}, data
            null

        getOriginData :  ->
            console.log 'getOriginData'
            $.extend true, {}, MC.data.origin_canvas_data

        describeInstancesOfASG : (region) ->

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

        getAppResourcesService : ( region, app_id, is_manual )->
            console.log 'getAppResourcesService, is_manual = ' + is_manual
            me = this
            current_tab = ''

            if is_manual
                app_name = MC.forge.app.getNameById app_id
                #notification 'info', sprintf lang.ide.TOOL_MSG_INFO_APP_REFRESH_START, app_name
                ide_event.trigger ide_event.SWITCH_LOADING_BAR, null, true

            app_model.resource { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region,  app_id

        getAllNotExistAmiInStack : ( region, tab_id )->

            ide_event.trigger ide_event.SWITCH_WAITING_BAR, null, true

            me = this

            ami_list = []

            _.each MC.canvas_data.component, (compObj) ->

                if compObj.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance  or compObj.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration
                    imageId = compObj.resource.ImageId
                    if imageId and !MC.data.dict_ami[imageId]
                        ami_list.push imageId

                null
            if ami_list.length
                stack_model.get_not_exist_ami { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, ami_list
    }

    model = new DesignModel()

    return model
