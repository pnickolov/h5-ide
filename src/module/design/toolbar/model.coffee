#############################
#  View Mode for design/toolbar module
#############################

define [ "component/exporter/Thumbnail", 'MC', 'backbone', 'jquery', 'underscore', 'event', 'stack_service', 'stack_model', 'app_model', 'constant', 'account_model' ], (ThumbUtil, MC, Backbone, $, _, ide_event, stack_service, stack_model, app_model, constant, account_model) ->

    AWSRes = constant.RESTYPE
    AwsTypeConvertMap = {}

    AwsTypeConvertMap[ AWSRes.ACL ]             = "Network ACL"
    AwsTypeConvertMap[ AWSRes.ASG ]             = "Auto Scaling Group"
    AwsTypeConvertMap[ AWSRes.CGW ]             = "Customer Gateway"
    AwsTypeConvertMap[ AWSRes.ELB ]             = "Load Balancer"
    AwsTypeConvertMap[ AWSRes.ENI ]             = "Network Interface"
    AwsTypeConvertMap[ AWSRes.IGW ]             = "Internet Gateway"
    AwsTypeConvertMap[ AWSRes.INSTANCE ]        = "Instance"
    AwsTypeConvertMap[ AWSRes.LC ]              = "Launch Configuration"
    AwsTypeConvertMap[ AWSRes.RT ]              = "Route Table"
    AwsTypeConvertMap[ AWSRes.SG ]              = "Security Group"
    AwsTypeConvertMap[ AWSRes.SUBSCRIPTION ]    = "SNS Subscription"
    AwsTypeConvertMap[ AWSRes.VGW ]             = "VPN Gateway"
    AwsTypeConvertMap[ AWSRes.VPC ]             = "VPC"
    AwsTypeConvertMap[ AWSRes.VPN ]             = "VPN"

    #item state map
    # {app_id:{'name':name, 'state':state, 'is_running':true|false, 'is_pending':true|false, 'is_use_ami':true|false},
    #  stack_id:{'name':name, 'is_run':true|false, 'is_duplicate':true|false, 'is_delete':true|false, 'is_enable:true'}}
    item_state_map   = {}

    # save data for thumbnail
    process_data_map = {}  # {<'process-' + region + '-' + name'->:<data>}}

    # mapping request id with tab id
    req_map          = {}  # {req_id : {'flag':flag, 'id':id, 'name':name}}
    if MC.storage.get 'req_map'
        req_map      = $.extend true, {}, MC.storage.get 'req_map'

    # flag of on tab or dashboard
    is_tab = true

    #private
    ToolbarModel = Backbone.Model.extend {

        defaults :
            'item_flags'    : null
            # {<stack_name>:<data>}
            'cf_data'       : null

        initialize : ->

            me = this

            #####listen STACK_SAVE_RETURN
            me.on 'STACK_SAVE_RETURN', (result) ->
                console.log 'STACK_SAVE_RETURN'

                region  = result.param[3]
                data    = result.param[4]
                id      = data.id
                name    = data.name

                if !result.is_error
                    console.log 'save stack successfully'

                    # call saveStackCallback
                    me.saveStackCallback id, name, region

                    # trigger TOOLBAR_HANDLE_SUCCESS
                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'SAVE_STACK', name

                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'SAVE_STACK', name

                    null

            #####listen STACK_CREATE_RETURN
            me.on 'STACK_CREATE_RETURN', (result) ->
                console.log 'STACK_CREATE_RETURN'

                region  = result.param[3]
                data    = result.param[4]
                old_id  = data.id
                name    = data.name

                if !result.is_error
                    console.log 'create stack successfully'

                    # call createStackCallback
                    me.createStackCallback result, old_id, name, region

                    # push TOOLBAR_HANDLE_SUCCESS
                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'CREATE_STACK', name

                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'CREATE_STACK', name

                    null

            #####listen STACK_SAVE__AS_RETURN
            me.on 'STACK_SAVE__AS_RETURN', (result) ->
                console.log 'STACK_SAVE__AS_RETURN'

                region      = result.param[3]
                id          = result.param[4]
                new_name    = result.param[5]
                name        = result.param[6]

                if !result.is_error
                    console.log 'save as stack successfully'

                    #update stack name list
                    new_id = result.resolved_data
                    MC.data.stack_list[region].push {'id':new_id, 'name':new_name}

                    # old save png
                    #key = result.resolved_data.key
                    #ide_event.trigger ide_event.UPDATE_REGION_THUMBNAIL, key, new_id

                    # local thumbnail
                    # SAVE_AS
                    me.savePNG new_id, 'new', id

                    #trigger event
                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'DUPLICATE_STACK', name
                    ide_event.trigger ide_event.UPDATE_STACK_LIST, 'DUPLICATE_STACK', [new_id]

                    # open the duplicated stack when using toolbar
                    # if is_tab
                    #     ide_event.trigger ide_event.OPEN_STACK_TAB, new_name, region, new_id

                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'DUPLICATE_STACK', name

            #####listen STACK_REMOVE_RETURN
            me.on 'STACK_REMOVE_RETURN', (result) ->
                console.log 'STACK_REMOVE_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                if !result.is_error
                    console.log 'send delete stack successful message'

                    #update stack name list
                    if MC.aws.aws.checkStackName(id, name)
                        for item in MC.data.stack_list[region]
                            if item.id is id and item.name is name
                                MC.data.stack_list[region].splice MC.data.stack_list[region].indexOf(item), 1
                                break

                    #trigger event
                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'REMOVE_STACK', name
                    ide_event.trigger ide_event.UPDATE_STACK_LIST, 'REMOVE_STACK', [id]
                    ide_event.trigger ide_event.CLOSE_DESIGN_TAB, id

                    me.setFlag id, 'DELETE_STACK'

                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'REMOVE_STACK', name

            #####listen STACK_RUN_RETURN
            me.on 'STACK_RUN_RETURN', (result) ->
                console.log 'STACK_RUN_RETURN'

                region      = result.param[3]
                id          = result.param[4]
                app_name    = result.param[5]

                #ide_event.trigger ide_event.OPEN_APP_PROCESS_TAB, id, app_name, region, result
                ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'NEW_PROCESS', app_name, region, id

                # handle request
                me.handleRequest result, 'RUN_STACK', region, id, app_name

                # track
                # analytics.track "Launched Stack",
                #     stack_id: id,
                #     stack_region: region,
                #     stack_app_name: app_name

            #####listen STACK_EXPORT__CLOUDFORMATION_RETURN
            me.on 'STACK_EXPORT__CLOUDFORMATION_RETURN', (result) ->
                console.log 'STACK_EXPORT__CLOUDFORMATION_RETURN'

                region  = result.param[3]
                id      = result.param[4]

                # old design flow
                #name    = MC.canvas_data.name

                # new design flow
                name    = MC.common.other.canvasData.get 'name'

                cf_data = me.get 'cf_data'
                if not cf_data
                    cf_data = {}

                flag = false
                if !result.is_error
                    console.log 'export cloudformation successfully'

                    cf_data[name] = result.resolved_data
                    flag = true

                else
                    console.log 'export cloudformation failed'

                    if name of cf_data
                        delete cf_data[name]

                me.set 'cf_data', cf_data
                if flag is true
                    me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'EXPORT_CLOUDFORMATION', name
                else
                    me.trigger 'TOOLBAR_HANDLE_FAILED', 'EXPORT_CLOUDFORMATION', name

            #####listen APP_START_RETURN
            me.on 'APP_START_RETURN', (result) ->
                console.log 'APP_START_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                me.handleRequest result, 'START_APP', region, id, name

                # track
                # analytics.track "Started App",
                #     app_id: id,
                #     app_region: region,
                #     app_name: name

            #####listen APP_STOP_RETURN
            me.on 'APP_STOP_RETURN', (result) ->
                console.log 'APP_STOP_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]

                me.handleRequest result, 'STOP_APP', region, id, name

                # track
                # analytics.track "Stopped App",
                #     app_id: id,
                #     app_region: region,
                #     app_name: name

            #####listen APP_TERMINATE_RETURN
            me.on 'APP_TERMINATE_RETURN', (result) ->
                console.log 'APP_TERMINATE_RETURN'

                region  = result.param[3]
                id      = result.param[4]
                name    = result.param[5]
                flag    = result.param[6]

                if not flag or flag == 0    # send request to terminate the app
                    me.handleRequest result, 'TERMINATE_APP', region, id, name

                else    # force terminating the app
                    if !result.is_error      # success
                        me.setFlag id, 'TERMINATED_APP', region
                        #ide_event.trigger ide_event.TERMINATED_APP, name, id
                        ide_event.trigger ide_event.CLOSE_DESIGN_TAB, id

                        # remove the app name from app_list
                        if name in MC.data.app_list[region]
                            MC.data.app_list[region].splice MC.data.app_list[region].indexOf(name), 1

                    else            # failed
                        me.setFlag id, 'STOPPED_APP', region

                    # update resource
                    ide_event.trigger ide_event.UPDATE_REGION_RESOURCE, region

                # track
                # analytics.track "Terminated App",
                #     app_id: id,
                #     app_region: region,
                #     app_name: name

            #####listen APP_UPDATE_RETURN
            me.on 'APP_UPDATE_RETURN', (result) ->
                console.log 'APP_UPDATE_RETURN'

                region  = result.param[3]
                id      = result.param[5]

                name    = item_state_map[id].name

                me.handleRequest result, 'UPDATE_APP', region, id, name

                #
                #MC.canvas_data             = $.extend true, {}, result.param[4]
                #MC.data.origin_canvas_data = $.extend true, {}, result.param[4]
                null

        createStackCallback : ( result, old_id, name, region ) ->
            console.log 'createStackCallback', result, old_id, name, region

            # get new id
            new_id = result.resolved_data

            # local thumbnail
            # NEW_STACK
            @savePNG new_id, 'new', old_id

            # add stack_list and change toolbar model
            MC.data.stack_list[ region ].push { 'id' : new_id, 'name' : name }

            # update other module
            ide_event.trigger ide_event.UPDATE_STACK_LIST, 'NEW_STACK', [new_id]

            # check return id is current id
            if MC.common.other.isCurrentTab old_id

                # set new id and key
                MC.common.other.canvasData.set 'id',  new_id

                # get new data
                data = MC.common.other.canvasData.data()

                # refresh toolbar
                @setFlag old_id, 'CREATE_STACK', data

                # set origin
                MC.common.other.canvasData.origin data

                ide_event.trigger ide_event.UPDATE_DESIGN_TAB, new_id, name + ' - stack', old_id
                ide_event.trigger ide_event.UPDATE_STATUS_BAR_SAVE_TIME

            else

                # update item_state_map
                if item_state_map and item_state_map[ old_id ]

                    # set new item_state_map
                    item_state_map[ new_id ] =  $.extend true, {}, item_state_map[ old_id ]

                    #set property true
                    item_state_map[ new_id ].is_enable    = true
                    item_state_map[ new_id ].is_duplicate = true
                    item_state_map[ new_id ].is_delete    = true

                    # delete old item_state_map
                    delete item_state_map[ old_id ]

                # update new id
                # update data
                # update origin data
                # update Design
                ide_event.trigger ide_event.OPEN_DESIGN_TAB, "OPEN_STACK", name , region, result.resolved_data

        saveStackCallback : ( id, name,region ) ->
            console.log 'saveStackCallback', id, name, region

            # local thumbnail
            # OPEN_STACK
            @savePNG id

            #update initial data
            ide_event.trigger ide_event.UPDATE_STACK_LIST, 'SAVE_STACK', [id]

            # check return id is current id
            if MC.common.other.isCurrentTab id

                #set toolbar flag
                @setFlag id, 'SAVE_STACK', name

                # push event
                ide_event.trigger ide_event.UPDATE_STATUS_BAR_SAVE_TIME

            else
                ide_event.trigger ide_event.OPEN_DESIGN_TAB, "OPEN_STACK", name , region, id
                # update item_state_map
                if item_state_map and item_state_map[ id ]

                    #set property true
                    item_state_map[ id ].is_enable    = true
                    item_state_map[ id ].is_duplicate = true
                    item_state_map[ id ].is_delete    = true

            null

        setFlag : (id, flag, value) ->
            me = this

            # new design flow
            name  = MC.common.other.canvasData.get 'name'
            state = MC.common.other.canvasData.get 'state'

            # reset id
            if id and _.isObject( id ) and flag is 'OPEN_STACK'
                id = id.resolved_data[0].id

            # reset flag( e.g. import JSON )
            if id and id.split and id.split( '-' )[0] is 'new' and flag is 'OPEN_STACK'
                flag = 'NEW_STACK'

            if flag is 'NEW_STACK'

                # old design flow
                #item_state_map[id] = {'name':MC.canvas_data.name, 'is_run':true, 'is_duplicate':false, 'is_delete':false, 'is_zoomin':false, 'is_zoomout':true}

                # new design flow
                item_state_map[id] = {'name': name, 'is_run':true, 'is_duplicate':false, 'is_delete':false, 'is_zoomin':false, 'is_zoomout':true, 'is_enable':true}

                is_tab = true

            else if flag is 'OPEN_STACK'


                # old design flow
                #item_state_map[id] = {'name':MC.canvas_data.name, 'is_run':true, 'is_duplicate':true, 'is_delete':true, 'is_zoomin':false, 'is_zoomout':true}

                # new design flow
                item_state_map[id] = {'name':name, 'is_run':true, 'is_duplicate':true, 'is_delete':true, 'is_zoomin':false, 'is_zoomout':true, 'is_enable':true}

                is_tab = true

            else if flag is 'SAVE_STACK'
                item_state_map[id].name         = value
                item_state_map[id].is_run       = true
                item_state_map[id].is_duplicate = true
                item_state_map[id].is_delete    = true
                item_state_map[id].is_enable    = true

            else if flag is 'CREATE_STACK'
                item_state_map[value.id] = {'name':value.name, 'is_run':true, 'is_duplicate':true, 'is_delete':true, 'is_zoomin':item_state_map[id].is_zoomin, 'is_zoomout':item_state_map[id].is_zoomout, 'is_enable':true}

                delete item_state_map[id]

                id = value.id

            else if flag is 'DELETE_STACK'
                delete item_state_map[id]
                return

            else if flag is 'ZOOMIN_STACK'
                item_state_map[id].is_zoomin    = value
                item_state_map[id].is_zoomout   = true

            else if flag is 'ZOOMOUT_STACK'
                item_state_map[id].is_zoomout   = value
                item_state_map[id].is_zoomin    = true

            else if flag is 'OPEN_APP'
                is_running = false
                is_pending = false

                # old design flow
                #if MC.canvas_data.state == constant.APP_STATE.APP_STATE_STOPPED
                #    is_running = false
                #else if MC.canvas_data.state == constant.APP_STATE.APP_STATE_RUNNING
                #    is_running = true

                # new design flow
                if state == constant.APP_STATE.APP_STATE_STOPPED
                    is_running = false
                else if state == constant.APP_STATE.APP_STATE_RUNNING
                    is_running = true
                else
                    is_running = false
                    is_pending = true

                id = id.resolved_data[0].id

                item_state_map[id] = {

                    # old design flow
                    #'name'                  : MC.canvas_data.name,
                    #'state'                 : MC.canvas_data.state,

                    # new design flow
                    'name'                  : name,
                    'state'                 : state,

                    'is_running'            : is_running,
                    'is_pending'            : is_pending,
                    'is_zoomin'             : false,
                    'is_zoomout'            : true,
                    'is_app_updating'       : false,

                    # old design flow
                    #'has_instance_store_ami': me.isInstanceStore(MC.canvas_data),
                    #'is_asg'                : me.isAutoScaling(MC.canvas_data),
                    #'is_production'         : if MC.canvas_data.usage isnt 'production' then false else true

                    # new design flow
                    'has_instance_store_ami': me.isInstanceStore(),
                    'is_asg'                : me.isAutoScaling(),
                    'is_production'         : if MC.common.other.canvasData.get( 'usage' ) isnt 'production' then false else true
                }

                is_tab = true

            else if flag is 'RUNNING_APP'
                if id of item_state_map
                    item_state_map[id].state = constant.APP_STATE.APP_STATE_RUNNING
                    item_state_map[id].is_running = true
                    item_state_map[id].is_pending = false

                region = value
                ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, 'running', id

                # stop => start
                if item_state_map and item_state_map[id] and item_state_map[id].is_app_updating is false and item_state_map[id].is_running is true

                    # temp
                    MC.data.running_app_list[ id ] = { app_id : id, state : 'running' }

                    # update app resource
                    ide_event.trigger ide_event.UPDATE_APP_INFO, region, id

                # app updating
                else
                    # TO DO

            else if flag is 'STOPPED_APP'
                if id of item_state_map
                    item_state_map[id].state = constant.APP_STATE.APP_STATE_STOPPED
                    item_state_map[id].is_running = false
                    item_state_map[id].is_pending = false

                region = value
                ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, 'stopped', id

                if item_state_map and item_state_map[id] and item_state_map[id].is_app_updating is false

                    # temp
                    MC.data.running_app_list[ id ] = { app_id : id, state : 'stopped' }

                    # update app resource
                    ide_event.trigger ide_event.UPDATE_APP_INFO, region, id

            else if flag is 'TERMINATED_APP'
                (delete item_state_map[id]) if id of item_state_map

                # update app resource
                region = value
                #ide_event.trigger ide_event.UPDATE_APP_INFO, region, id

                return

            else if flag is 'PENDING_APP'
                if id of item_state_map
                    item_state_map[id].is_pending = true

                region = value
                ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, 'pending', id

            else if flag is 'UPDATE_APP'
                if id of item_state_map
                    item_state_map[id].is_app_updating = value

            else if flag is 'ENABLE_SAVE'

                 item_state_map[ id ]?.is_enable = value
            # refresh toolbar
            if id == MC.common.other.canvasData.get( 'id' ) and is_tab

                me.set 'item_flags', $.extend true, {}, item_state_map[id]

                if id.indexOf('app-') == 0
                    me.trigger 'UPDATE_TOOLBAR', 'app'
                else
                    me.trigger 'UPDATE_TOOLBAR', 'stack'

        setTabFlag : (flag) ->
            me = this

            is_tab = flag

            if flag

                # get id
                id  = MC.data.current_tab_id

                rid = k for k,v of item_state_map when id == k

                if rid

                    # set item_flags
                    me.set 'item_flags', $.extend true, {}, item_state_map[id]

                    if id and id.split( '-' ) and id.split( '-' )[0] is 'app'
                        me.trigger 'UPDATE_TOOLBAR', 'app'
                    else
                        me.trigger 'UPDATE_TOOLBAR', 'stack'

            null

        #save stack
        saveStack : (data) ->
            me = this

            region  = data.region
            id      = data.id
            name    = data.name

            # OPEN_STACK
            if id.indexOf('stack-', 0) == 0
                stack_model.save_stack { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, data

            # NEW_STACK
            else

                # add current canvas and svg to cacheThumb
                MC.common.other.addCacheThumb id, $("#canvas_body").html(), $("#svg_canvas")[0].getBBox()

                # call api
                stack_model.create { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, data

            # set item_state_map.is_enable = false
            @setFlag id, 'ENABLE_SAVE', false

        syncSaveStack : ( region, data ) ->
            console.log 'syncSaveStack', region, data

            me         = this
            src        = {}
            src.sender = this
            src.model  = null
            id         = MC.common.other.canvasData.get( 'id' )

            if id and _.isArray id.split( '-' )

                # save api
                if id.split( '-' )[0] is 'stack'

                    func = stack_service.save

                # create api
                else if id.split( '-' )[0] is 'new'

                    # add current canvas and svg to cacheThumb
                    MC.common.other.addCacheThumb id, $("#canvas_body").html(), $("#svg_canvas")[0].getBBox()

                    func = stack_service.create

                if _.isFunction func

                    func src, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, data, ( aws_result ) ->

                        if !aws_result.is_error
                            console.log 'stack_service api'

                            region  = aws_result.param[3]
                            data    = aws_result.param[4]
                            id      = data.id
                            name    = data.name

                            # save api
                            if id.split( '-' )[0] is 'stack'

                                # call saveStackCallback
                                me.saveStackCallback id, name, region

                                # trigger TOOLBAR_HANDLE_SUCCESS
                                me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'SAVE_STACK_BY_RUN', name

                            # create api
                            else if id.split( '-' )[0] is 'new'

                                # call createStackCallback
                                me.createStackCallback aws_result, id, name, region

                                # trigger TOOLBAR_HANDLE_SUCCESS
                                me.trigger 'TOOLBAR_HANDLE_SUCCESS', 'SAVE_STACK_BY_RUN', name

                        else
                            console.log 'stack_service.save_stack, error is ' + aws_result.error_message

        #duplicate
        duplicateStack : (region, id, new_name, name) ->
            console.log 'duplicateStack', region, id, new_name, name
            me = this

            # add current canvas and svg to cacheThumb
            MC.common.other.addCacheThumb id, $("#canvas_body").html(), $("#svg_canvas")[0].getBBox()
            stack_model.save_as { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, new_name, name

        #delete
        deleteStack : (region, id, name) ->
            me = this

            stack_model.remove { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

            ThumbUtil.remove( id )
            null

        #run
        runStack : (data) ->

            # Quick code for VisualOps statistics. Might improve later
            for id, comp of data
                if comp.type is "AWS.EC2.Instance" and comp.state and comp.state.length
                    MC.Analytics.increase "use_visualops"
                    break

            console.log 'runStack', data
            me = this

            id          = data.id
            region      = data.region
            app_name    = data.name
            usage       = data.usage

            stack_model.run { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, app_name, null, null, null, null, null, usage

            # save stack data for generating png
            idx = 'process-' + region + '-' + app_name
            process_data_map[idx] = data

            # local thumbnail
            MC.common.other.addCacheThumb idx, $("#canvas_body").html(), $("#svg_canvas")[0].getBBox()

            null

        updateApp : ( is_update )->

            # old design flow
            #@setFlag MC.canvas_data.id, 'UPDATE_APP', is_update

            # new design flow
            @setFlag MC.common.other.canvasData.get( 'id' ), 'UPDATE_APP', is_update

            null

        #zoomin
        zoomIn : () ->
            me = this

            if $canvas.scale() > 1
                MC.canvas.zoomIn()

            flag = true
            if $canvas.scale() <= 1
                flag = false

            # old design flow
            #me.setFlag MC.canvas_data.id, 'ZOOMIN_STACK', flag

            # new design flow
            me.setFlag MC.common.other.canvasData.get( 'id' ), 'ZOOMIN_STACK', flag

        #zoomout
        zoomOut : () ->
            me = this

            if $canvas.scale() < 1.6
                MC.canvas.zoomOut()

            flag = true
            if $canvas.scale() >= 1.6
                flag = false

            # old design flow
            #me.setFlag MC.canvas_data.id, 'ZOOMOUT_STACK', flag

            # new design flow
            me.setFlag MC.common.other.canvasData.get( 'id' ), 'ZOOMOUT_STACK', flag

        # when type is 'new' include 'NEW_STACK' 'RUN_STACK' 'APP_UPDATE'
        # when type is 'new' old_id is 'new-xxxx'
        # when type isnt 'new' include 'OPEN_STACK'
        savePNG : ( id, type, old_id ) ->
            console.log 'savePNG', id, type, old_id

            if type is 'new'

                # get cache thumb
                obj = MC.common.other.getCacheThumb old_id

                # call ThumbUtil.save
                if obj and obj.canvas and obj.svg
                    ThumbUtil.save id, obj.canvas, obj.svg

            # OPEN_STACK
            else
                ThumbUtil.save id, $("#svg_canvas")

            null

        generatePNG : () ->
            ThumbUtil.exportPNG $("#svg_canvas"), {
                isExport   : true
                createBlob : true
                name       : Design.instance().get("name")
                id         : Design.instance().get("id")

                onFinish : ( data ) =>
                    if ( data.id is Design.instance().get("id") )
                        @trigger 'EXPORT_PNG', data.image, data.id, data.blob
            }
            null

        isChanged : (data) ->
            # Original version of isChanged() is a pointer comparation
            # Meaning that most of the time, it's consider to be changed.
            return true

        startApp : (region, id, name) ->
            me = this

            app_model.start { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

            item = {'region':region, 'name':name, 'id':id, 'flag_list':{'is_pending':true}}
            me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, "START_APP", item)

        stopApp : (region, id, name) ->
            me = this

            app_model.stop { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name

            item = {'region':region, 'name':name, 'id':id, 'flag_list':{'is_pending':true}}
            me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, "STOP_APP", item)

        terminateApp : (region, id, name, flag) ->
            me = this

            app_model.terminate { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, id, name, flag

            item = {'region':region, 'name':name, 'id':id, 'flag_list':{'is_pending':true}}
            me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, "TERMINATE_APP", item)

            ThumbUtil.remove(id)
            null

        saveApp : (data) ->
            me = this

            region  = data.region
            id      = data.id
            name    = data.name

            # loacl thumbnail
            MC.common.other.addCacheThumb id, $("#canvas_body").html(), $("#svg_canvas")[0].getBBox()

            app_model.update { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, data, id

            # save app data for generating png
            idx = 'process-' + region + '-' + name
            process_data_map[idx] = data

            item = {'region':region, 'name':name, 'id':id, 'flag_list':{'is_pending':true}}
            me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, "UPDATE_APP", item)

        handleRequest : (result, flag, region, id, name) ->
            me = this

            if flag isnt 'RUN_STACK'
            #    me.setFlag id, 'PENDING_APP', region
                ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, 'pending', id

            if !result.is_error

                #me.trigger 'TOOLBAR_REQUEST_SUCCESS', flag, name

                req_id = result.resolved_data.id
                console.log 'request id:' + req_id

                req_map[req_id] =
                    flag    : flag
                    id      : id
                    name    : name
                MC.storage.set 'req_map', $.extend true, {}, req_map

                # item = {'region':region, 'name':name, 'id':id, 'time_update':result.resolved_data.time_submit, 'flag_list':{'is_pending':true}}
                # me.updateAppState(constant.OPS_STATE.OPS_STATE_INPROCESS, flag, item)

                null

            else

                #me.trigger 'TOOLBAR_REQUEST_FAILED', flag, name

                if flag is 'RUN_STACK'
                #    me.setFlag id, 'STOPPED_APP', region
                #
                #else
                    # remove the app name from app_list
                    if name in MC.data.app_list[region]
                        MC.data.app_list[region].splice MC.data.app_list[region].indexOf(name), 1

                # push UPDATE_APP_STATE
                if item_state_map[id].is_running is true
                    state = constant.APP_STATE.APP_STATE_RUNNING
                    icon  = 'running'
                else
                    state = constant.APP_STATE.APP_STATE_STOPPED
                    icon  = 'stopped'
                ide_event.trigger ide_event.UPDATE_APP_STATE, state, id

                ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, icon, id

                # push UPDATE_APP_LIST
                ide_event.trigger ide_event.UPDATE_APP_LIST, null, [ id ]

        #reqHandle : (flag, id, name, req, dag) ->
        reqHandle : (idx, dag) ->
            me = this

            # fetch request
            req_list = App.WS.collection.request.find({'_id' : idx}).fetch()

            if req_list.length > 0
                req = req_list[0]
                req_id = req.id
                time_update = if 'time_end' of req and req.time_end then req.time_end else req.time_begin

                # filter request
                if req_id of req_map

                    flag    = req_map[req_id].flag
                    id      = req_map[req_id].id
                    name    = req_map[req_id].name
                    region  = req.region

                    # check
                    if not flag or not region or not id or not name
                        return
                    if not time_update
                        time_update = Date.now()/1000

                    # for app update
                    item = {'region':region, 'id':id, 'name':name, 'time_update':time_update}
                    flag_list = {}

                    switch req.state
                        when constant.OPS_STATE.OPS_STATE_INPROCESS
                            flag_list.is_inprocess = true

                            dones = 0
                            steps = 0

                            if 'dag' of dag # changed request

                                steps = dag.dag.step.length
                                # check rollback
                                dones++ for step in dag.dag.step when step[1].toLowerCase() is 'done'
                                console.log 'done steps:' + dones

                            # rollback
                            tab_name = 'process-' + region + '-' + name
                            if tab_name of MC.process and dones>0
                                dones = if !('dones' of MC.process[tab_name].flag_list) or (MC.process[tab_name].flag_list.dones < dones) then dones else MC.process[tab_name].flag_list.dones

                            flag_list.dones = dones
                            flag_list.steps = steps

                            if dones > 0 and steps > 0
                                flag_list.rate = Math.round(flag_list.dones*100/flag_list.steps)
                            else
                                flag_list.rate = 0

                        when constant.OPS_STATE.OPS_STATE_FAILED

                            flag_list.is_failed = true
                            flag_list.err_detail = req.data.replace(/\\n/g, '<br />')

                            if req and req.suggestion and _.isArray( req.suggestion ) and req.suggestion.length > 0

                                _.each req.suggestion, ( item ) ->
                                    flag_list.err_detail += '<br/>' + item
                                    null

                            if flag is 'RUN_STACK'
                                # remove the app name from app_list
                                if name in MC.data.app_list[region]
                                    MC.data.app_list[region].splice MC.data.app_list[region].indexOf(name), 1

                            else if flag is 'TERMINATE_APP'

                                appId = id
                                appName = name

                                mainContent = 'The app ' + appName + ' failed to terminate. Do you want to force deleting it?'
                                descContent = ''
                                template = MC.template.modalForceDeleteApp {
                                    title : 'Force to delete app',
                                    main_content : mainContent,
                                    desc_content : descContent
                                }
                                modal template, false, () ->
                                    $('#modal-confirm-delete').click () ->
                                        # force to delete app
                                        me.terminateApp(region, appId, appName, 1)
                                        modal.close()
                                    $('#modal-cancel').click () ->
                                        me.setFlag id, 'STOPPED_APP', region

                            #else
                            #    me.setFlag id, 'STOPPED_APP', region

                        when constant.OPS_STATE.OPS_STATE_DONE

                            lst = req.data.split(' ')
                            app_id = lst[lst.length-1]

                            flag_list.app_id = app_id
                            flag_list.is_done = true

                            item.id = app_id

                            switch flag
                                when 'RUN_STACK'
                                    me.setFlag app_id, 'RUNNING_APP', region

                                    item.id = app_id
                                    #item.has_instance_store_ami = me.isInstanceStore(process_data_map[region][name])

                                when 'START_APP'
                                    me.setFlag id, 'RUNNING_APP', region

                                when 'STOP_APP'
                                    me.setFlag id, 'STOPPED_APP', region

                                when 'TERMINATE_APP'
                                    me.setFlag id, 'TERMINATED_APP', region

                                    # remove the app name from app_list
                                    if name in MC.data.app_list[region]
                                        MC.data.app_list[region].splice MC.data.app_list[region].indexOf(name), 1

                                when 'UPDATE_APP'
                                    flag_list.is_updated = true
                                    if id of item_state_map
                                        if item_state_map[id].is_running
                                            me.setFlag id, 'RUNNING_APP', region
                                        else
                                            me.setFlag id, 'STOPPED_APP', region

                                else
                                    console.log 'not support toolbar operation:' + flag
                                    return

                        else
                            console.log 'not support request state:' + req.state

                    # update process state
                    if flag_list
                        item.flag_list = flag_list
                        me.updateAppState(req.state, flag, item)

                    # update app list, region aws resource and notification
                    if req.state is constant.OPS_STATE.OPS_STATE_DONE or req.state is constant.OPS_STATE.OPS_STATE_FAILED

                        # save png
                        if req.state is constant.OPS_STATE.OPS_STATE_DONE
                            if flag is 'UPDATE_APP'

                                # new local thumbnail
                                # APP_UPDATE
                                me.savePNG item.id, 'new', item.id

                                # old thumbnail
                                #me.saveAppThumbnail flag, region, name, item.id

                        # update app list
                        app_list = []
                        if item.id.indexOf('app-') == 0
                            app_list.push item.id

                        if app_list
                            if flag isnt 'RUN_STACK'
                                ide_event.trigger ide_event.UPDATE_APP_LIST, flag, app_list
                        else
                            ide_event.trigger ide_event.UPDATE_APP_LIST

                        # update region resource
                        ide_event.trigger ide_event.UPDATE_REGION_RESOURCE, region

                        # update notification
                        if req.state is constant.OPS_STATE.OPS_STATE_DONE
                            me.trigger 'TOOLBAR_HANDLE_SUCCESS', flag, name
                        else if req.state is constant.OPS_STATE.OPS_STATE_FAILED
                            me.trigger 'TOOLBAR_HANDLE_FAILED', flag, name

                        # remove request from req_map
                        delete req_map[req_id]
                        MC.storage.set 'req_map', $.extend true, {}, req_map

            # update header
            ide_event.trigger ide_event.UPDATE_HEADER, req

        updateAppState : (req_state, flag, data) ->
            me = this

            state = null

            switch req_state
                when constant.OPS_STATE.OPS_STATE_DONE
                    if flag is 'RUN_STACK'
                        state = constant.APP_STATE.APP_STATE_RUNNING

                    else if flag is 'START_APP'
                        state = constant.APP_STATE.APP_STATE_RUNNING

                    else if flag is 'STOP_APP'
                        state = constant.APP_STATE.APP_STATE_STOPPED

                    else if flag is 'TERMINATE_APP'
                        state = constant.APP_STATE.APP_STATE_TERMINATED

                    else if flag is 'UPDATE_APP'
                        state = constant.APP_STATE.APP_STATE_RUNNING

                when constant.OPS_STATE.OPS_STATE_FAILED
                    state = constant.APP_STATE.APP_STATE_STOPPED

                when constant.OPS_STATE.OPS_STATE_INPROCESS
                    if flag is 'RUN_STACK'
                        state = constant.APP_STATE.APP_STATE_INITIALIZING

                    else if flag is 'START_APP'
                        state = constant.APP_STATE.APP_STATE_STARTING

                    else if flag is 'STOP_APP'
                        state = constant.APP_STATE.APP_STATE_STOPPING

                    else if flag is 'TERMINATE_APP'
                        state = constant.APP_STATE.APP_STATE_TERMINATING

                    else if flag is 'UPDATE_APP'
                        state = constant.APP_STATE.APP_STATE_UPDATING

                else
                    console.log 'not support request state:' + req_state

            if state
                console.log 'toolbar:UPDATE_APP_STATE', state, data

                # set flag
                data.flag_list.flag = flag

                # update MC.process[id]
                tab_name = data.id
                if flag is 'RUN_STACK'
                    tab_name = 'process-' + data.region + '-' + data.name
                MC.process[tab_name] = data

                # push event
                if flag is 'RUN_STACK'

                    # local thumbnail
                    # RUN_STACK
                    if data and data.flag_list and data.flag_list.is_done in [ true, 'true' ] and data.flag_list.app_id

                        me.savePNG data.flag_list.app_id, 'new', tab_name

                    # update process
                    ide_event.trigger ide_event.UPDATE_PROCESS, tab_name

                else

                    #test open_fail
                    #if state in [ constant.APP_STATE.APP_STATE_STOPPED, constant.APP_STATE.APP_STATE_RUNNING ]
                    #    console.log 'sdfdffffffffffffffffffffffffffffffffff'
                    #    ide_event.trigger ide_event.OPEN_APP_TAB, 'untitled-1', 'us-east-1', 'app-df3be529'
                    #    setTimeout () ->
                    #        ide_event.trigger ide_event.UPDATE_APP_STATE, state, tab_name
                    #    , 1000 * 0.5
                    #else
                    #    ide_event.trigger ide_event.UPDATE_APP_STATE, state, tab_name

                    ide_event.trigger ide_event.UPDATE_APP_STATE, state, tab_name

                    if flag is 'UPDATE_APP'
                        if req_state is constant.OPS_STATE.OPS_STATE_DONE
                            #ide_event.trigger ide_event.APPEDIT_2_APP, tab_name, data.region
                            console.log 'app update success'

                        else if req_state is constant.OPS_STATE.OPS_STATE_FAILED
                            #ide_event.trigger ide_event.APPEDIT_2_APP, tab_name
                            console.log 'app update failed'

        isInstanceStore : () -> !Design.instance().isStoppable()

        convertCloudformation : () ->
            me = this

            # get region
            region = MC.common.other.canvasData.get( 'region' )

            # api
            stack_model.export_cloudformation { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, MC.common.other.canvasData.data()

            null

        isAutoScaling : () ->
            !!Design.modelClassForType( "AWS.AutoScaling.Group" ).allObjects().length

        diff : ()->
            dedupResult = []
            dedupMap    = {}

            diffResult  = Design.instance().diff()
            for obj in diffResult.result
                if AwsTypeConvertMap[ obj.type ]
                    obj.type = AwsTypeConvertMap[ obj.type ]
                # Remove duplicate
                exist = dedupMap[ obj.id ]
                if not exist
                    exist = dedupMap[ obj.id ] = obj
                    dedupResult.push obj
                else if obj.change and obj.change isnt "Update"
                    exist.change = obj.change

                if obj.changes
                    exist.changes = obj.changes
                    for c in obj.changes
                        c.info = c.name
                        if c.count < 0
                            c.info = c.name + " " + c.count
                        else if c.count > 0
                            c.info = c.name + " +" + c.count

                if exist.change is "Delete"
                    exist.info = exist.info or "Deletion cannot be rolled back"
                else if exist.change is "Terminate"
                    exist.info = exist.info or "Termination cannot be rolled back"

            diffResult.result = dedupResult
            diffResult

        isAllInstanceNotHaveUserData : () ->

          result = true

          # find all instance userdata
          InstanceModel = Design.modelClassForType(constant.RESTYPE.INSTANCE)
          instanceModels = InstanceModel.allObjects()
          _.each instanceModels, (instanceModel) ->
            userData = instanceModel.get('userData')
            if userData then result = false
            null

          # find all lc userdata
          LCModel = Design.modelClassForType(constant.RESTYPE.LC)
          lcModels = LCModel.allObjects()
          _.each lcModels, (lcModel) ->
            userData = lcModel.get('userData')
            if userData then result = false
            null

          return result

        setAgentEnable : (isEnable) ->

          if isEnable is true

            # clear all instance userdata
            InstanceModel = Design.modelClassForType(constant.RESTYPE.INSTANCE)
            instanceModels = InstanceModel.allObjects()
            _.each instanceModels, (instanceModel) ->
              instanceModel.set('userData', '')
              null

            # clear all lc userdata
            LCModel = Design.modelClassForType(constant.RESTYPE.LC)
            lcModels = LCModel.allObjects()
            _.each lcModels, (lcModel) ->
              lcModel.set('userData', '')
              null

          MC.aws.aws.enableStackAgent(isEnable)
    }

    model = new ToolbarModel()

    return model
