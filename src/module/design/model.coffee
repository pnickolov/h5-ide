#############################
#  View Mode for design
#############################

define [ 'Design', 'MC', 'event', 'constant', 'app_model', 'stack_model', 'state_model', 'instance_service', 'ami_service', 'i18n!nls/lang.js', 'underscore', 'backbone' ], ( Design, MC, ide_event, constant, app_model, stack_model, state_model, instance_service, ami_service, lang, _) ->

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

                            # set current resource
                            @setCurrentResource result

                            #close all list popup(ServerGroup,ASG)
                            MC.canvas.event.clearList()
                            #select app property
                            $canvas.trigger("CANVAS_NODE_SELECTED", "")

                        else
                            @setOriginResource result, app_id

                    catch error

                        app_name = MC.forge.app.getNameById app_id
                        notification 'error', sprintf lang.ide.TOOL_MSG_INFO_APP_REFRESH_FAILED, if app_name then app_name else app_id + '(closed)'

                        console.error '[error]APP_RESOURCE_RETURN' + error

                else
                    #TO-DO

                # SWITCH_MAIN → GET_STATE_MODULE
                ide_event.trigger ide_event.GET_STATE_MODULE if app_id == MC.data.current_tab_id

                null

            #listen APP_INFO_RETURN
            me.on 'APP_INFO_RETURN', ( result ) ->
                console.log 'APP_INFO_RETURN'

                app_id = result.param[4][0]

                # update canvas_data when on current tab
                #if app_id == MC.common.other.canvasData.get( 'id' )
                if app_id is MC.data.current_tab_id

                    # set data
                    @setCanvasData result.resolved_data[ 0 ]
                    @setOriginData result.resolved_data[ 0 ]

                    if MC.data.running_app_list and MC.data.running_app_list[ app_id ] and MC.data.running_app_list[ app_id ].state is 'stopped'

                        # save design_model
                        MC.common.other.canvasData.save MC.common.other.canvasData.data(true)

                # update MC.Tab[app_id]
                else
                    @updateAppTabDate       result.resolved_data[ 0 ], app_id
                    @updateAppTabOriginDate result.resolved_data[ 0 ], app_id

                # get app.resource
                @getAppResourcesService result.param[3], app_id

                null

        #############################
        #  tab
        #############################

        addTab : ( tab_id, snapshot, design_model, data, origin_data, property_panel, origin_ta_valid ) ->
            console.log 'addTab'

            MC.tab[ tab_id ] =
                'snapshot'        : snapshot
                'design_model'    : design_model
                'data'            : data
                'origin_data'     : origin_data
                'property_panel'  : property_panel
                'origin_ta_valid' : origin_ta_valid

            null

        deleteTab    : ( tab_id ) ->
            console.log 'deleteTab'

            # delete MC.tab
            delete MC.tab[ tab_id ]
            console.log MC.tab

            # delete MC.process and MC.data.process
            MC.common.other.deleteProcess tab_id if MC.process[ tab_id ] and tab_id.split('-')[0] is 'process'
            console.log MC.process

            # delete appview
            obj = MC.common.other.getCacheMap tab_id
            if obj and obj.state is 'ERROR' or tab_id.split('-')[0] is 'appview'
                MC.common.other.delCacheMap tab_id

            null

        getTab : ( type, tab_id ) ->
            console.log 'getTab'
            #set random number
            @set 'snapshot', Math.round(+new Date())
            #
            ide_event.trigger ide_event.SWITCH_WAITING_BAR
            #
            @set 'snapshot',      MC.tab[ tab_id ].snapshot
            @setDesignModel       MC.tab[ tab_id ].design_model
            @setCanvasData        MC.tab[ tab_id ].data
            @setOriginData        MC.tab[ tab_id ].origin_data
            @setCurrentResource   MC.tab[ tab_id ].origin_resource if MC.tab[ tab_id ].origin_resource
            @setPropertyPanel     MC.tab[ tab_id ].property_panel
            @setTAValidation      MC.tab[ tab_id ].origin_ta_valid
            #
            null

        updateAppTabDate : ( data, tab_id ) ->
            console.log 'updateAppTabDate'

            if MC.tab[ tab_id ]

                # set data
                MC.tab[ tab_id ].data = $.extend( true, {}, data )

                # set Design
                MC.tab[ tab_id ].design_model.save data

            null

        updateAppTabOriginDate : ( data, tab_id ) ->
            console.log 'updateAppTabOriginDate'
            MC.tab[ tab_id ].origin_data = $.extend( true, {}, data ) if MC.tab[ tab_id ]
            null

        updateTab : ( new_tab_id, old_tab_id ) ->
            console.log 'updateTab', new_tab_id, old_tab_id

            # get old tab
            old_tab = $.extend true, {}, MC.tab[ old_tab_id ]

            if old_tab

                # set new tab id with Design, data and origin_data
                old_tab.data.id        = new_tab_id
                old_tab.origin_data.id = new_tab_id
                old_tab.design_model.set 'id', new_tab_id

                # set new tab
                MC.tab[ new_tab_id ] = $.extend true, {}, old_tab

                # delete old tab
                delete MC.tab[ old_tab_id ]

        setCanvasData : ( data ) ->
            console.log 'setCanvasData'

            # old design flow
            #MC.canvas_data = $.extend true, {}, data

            # new design flow
            MC.common.other.canvasData.init data

            null

        getCanvasData : () ->
            console.log 'getCanvasData'
            #MC.canvas_data

            # old design flow
            #$.extend true, {}, MC.canvas_data

            # new design flow
            MC.common.other.canvasData.data()

        setPropertyPanel : ( property_panel ) ->
            console.log 'setPropertyPanel'
            @trigger "SET_PROPERTY_PANEL", property_panel
            null

        setOriginData : ( data ) ->
            console.log 'setOriginData'

            # old design flow
            #MC.data.origin_canvas_data = $.extend true, {}, data

            # new design flow
            MC.common.other.canvasData.origin data

            null

        getOriginData :  ->
            console.log 'getOriginData'

            # old design flow
            #$.extend true, {}, MC.data.origin_canvas_data

            # new design flow
            MC.common.other.canvasData.origin()

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

            instance_ids = []

            try

                asg_list = Design.modelClassForType( constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group ).allObjects()

                for asg in asg_list

                    asg_arn = asg.get( "appId" )
                    asg_res = MC.data.resource_list[region][asg_arn]

                    instance_memeber = if asg_res and asg_res.Instances then asg_res.Instances.member else null

                    #find instance in ASG
                    for ins in instance_memeber || []
                        instance_ids.push ins.InstanceId

                ######
                src = {}
                src.sender = this
                src.model  = null

                if instance_ids.length > 0
                    instance_service.DescribeInstances src, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, instance_ids, null, ( aws_result ) ->

                        if !aws_result.is_error
                            console.log 'instance_service.DescribeInstances'
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

            if MC.data.running_app_list and MC.data.running_app_list[ app_id ] and MC.data.running_app_list[ app_id ].state is 'running'

                console.log 'when OPEN_APP or stop → start app use it'

                # clear svg
                $('#vpc_layer, #az_layer, #subnet_layer, #asg_layer, #line_layer, #node_layer').empty()

                # re-new Design
                options =
                    mode : 'app'
                new Design MC.common.other.canvasData.origin(), options

            # delete current app_id
            delete MC.data.running_app_list[ app_id ]

            if resource_source

                #clear old app data in MC.data.resource_list
                Design.instance().clearResourceInCache()

                #cache new app data
                MC.aws.aws.cacheResource resource_source, region, false
                #
                @describeInstancesOfASG region

            # new design flow
            MC.common.other.canvasData.set 'layout', 'connection' : {}

            #update property panel
            uid = $canvas.selected_node()[0]
            if uid
                MC.canvas.select uid

            # update resource
            Design.instance().trigger Design.EVENT.AwsResourceUpdated

            # set origin data
            @setOriginData MC.common.other.canvasData.data()

            # delete current origin_resource
            MC.tab[ app_id ].origin_resource = null if MC.tab and MC.tab[ app_id ] and MC.tab[ app_id ].origin_resource

            #
            console.log 'set app.resource end'

        getStateModule: () ->
            console.log 'getStateModule'

            me = this

            me.off('STATE_MODULE_RETURN')

            agentData = MC.common.other.canvasData.get('agent')

            modRepo = agentData.module.repo
            modTag = agentData.module.tag

            mod_version = modRepo + ':' + modTag

            if not MC.data.state.module then MC.data.state.module = {}

            if not MC.data.state.module[mod_version]

                state_model.module {

                    sender : me,
                    mod_version: mod_version

                }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), modRepo, modTag

                me.on 'STATE_MODULE_RETURN', ( result, src ) ->

                    console.log 'STATE_MODULE_RETURN'

                    if !result.is_error

                        # cache result
                        MC.data.state.module[src.mod_version] = result.resolved_data

                        console.log '----------- design:SWITCH_MAIN -----------'
                        ide_event.trigger ide_event.SWITCH_MAIN

                    null

            else

                console.log '----------- design:SWITCH_MAIN -----------'
                ide_event.trigger ide_event.SWITCH_MAIN

    }

    model = new DesignModel()

    return model
