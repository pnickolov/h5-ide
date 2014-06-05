#############################
#  View Mode for header module
#############################

define [ 'i18n!nls/lang.js', 'aws_model', 'ami_model'
         'event', 'constant', 'forge_handle', 'ApiRequest'
         'UI.notification',
         'backbone', 'jquery', 'underscore'
], ( lang, aws_model, ami_model, ide_event, constant, forge_handle, ApiRequest ) ->

    ProcessModel = Backbone.Model.extend {

        defaults:

            #flag_list = {'is_pending':true|false, 'is_inprocess':true|false, 'is_done':true|false, 'is_failed':true|false, 'steps':0, 'dones':0, 'rate':0}
            'flag_list'         : null

            # when aws_model.vpc_resource current tab id
            'current_tab_id'    : null

            # when timeout, set timeout_obj
            # id : { id : null, timeout : false, overtime : false }
            'timeout_obj'       : {}

        initialize  : ->
            me = this

            # set init flag_list
            me.set 'flag_list', { 'is_pending' : true }

            @on 'AWS_RESOURCE_RETURN', ( result ) ->
                console.log 'AWS_RESOURCE_RETURN', result

                # test exception flow
                #result.resolved_data = {}
                #result.is_error = true
                #result.error_message = 'sdfasdfasdfsadfasdf'

                if result and not result.is_error and result.resolved_data and result.resolved_data.length > 0

                    # get vpc_id
                    vpc_id = result.param[4][ constant.RESTYPE.VPC ].id[0]

                    # set cacheMap data
                    obj = MC.common.other.setCacheMap vpc_id, result, null, null

                    # set ami_ids
                    ami_ids = MC.forge.app.getAmis result.resolved_data[0]

                    if _.isEmpty ami_ids

                        # set FINISH by cacheMap
                        @setCacheMapDataFlg obj

                    else

                        # set current tab id
                        @set 'current_tab_id', obj.id

                        # call api
                        @getDescribeImages result.param[3], ami_ids

                    null

                else if result

                    # get vpc_id
                    vpc_id = result.param[4][ constant.RESTYPE.VPC ].id[0]

                    # set cacheMap state 'ERROR'
                    obj = MC.common.other.setCacheMap vpc_id, null, 'ERROR', null, null

                    if not result.is_error and _.isEmpty result.resolved_data

                        # delete this vpc by delUnmanaged
                        MC.common.other.delUnmanaged vpc_id

                        # set error message
                        error_message = lang.ide.NOTIFY_MSG_WARN_VPC_DOES_NOT_EXIST

                    else if result.is_error

                        # set error message
                        error_message = result.error_message

                    # get this tab id and close this tab
                    obj = MC.common.other.searchCacheMap { key : 'origin_id', value : vpc_id }
                    if obj and obj.id
                        ide_event.trigger ide_event.CLOSE_DESIGN_TAB, obj.id

                    # notification
                    notification 'error', error_message, false

                    null

            @on 'EC2_AMI_DESC_IMAGES_RETURN', ( result ) ->
                console.log 'EC2_AMI_DESC_IMAGES_RETURN', result

                if result and not result.is_error

                    if result.resolved_data and result.resolved_data.length > 0

                        # set amis and cache resource
                        amis =
                            "DescribeImages" : []
                        for ami in result.resolved_data
                            amis.DescribeImages.push ami
                        MC.aws.aws.cacheResource amis, result.param[3], false

                    # get call service current tab id
                    current_tab_id = result.param[0].src.sender.get 'current_tab_id'
                    console.log 'EC2_AMI_DESC_IMAGES_RETURN, current_tab_id', current_tab_id

                    # get origin_id
                    origin_obj = MC.common.other.getCacheMap current_tab_id

                    # set FINISH by cacheMap
                    @setCacheMapDataFlg origin_obj

                    null

            # loop time 1's
            setInterval ( ->

                # when current tab not appview return
                if MC.common.other.processType( MC.data.current_tab_id ) isnt 'appview'
                    return

                # get obj
                obj = MC.common.other.getCacheMap MC.data.current_tab_id

                # return obj when undefined
                if not obj
                    return

                # when create_time is 'overtime' or state is 'FINISH' return
                if obj.create_time is 'overtime' or obj.state is 'FINISH'
                    return

                # set T1 and T2
                t1 = obj.origin_time
                t2 = new Date()

                # timestamp
                if MC.timestamp( t1, t2, 's' ) > 10

                    # set create_time is 'timeout'
                    MC.common.other.setCacheMap obj.origin_id, null, null, null, 'timeout'

                    # set timeout
                    me.set 'timeout_obj', { 'id' : obj.id, 'timeout' : true, 'overtime' : false }

                # time out
                if MC.timestamp( t1, t2, 'm' ) > 10

                    # set create_time is 'overtime'
                    MC.common.other.setCacheMap obj.origin_id, null, null, null, 'overtime'

                    # set timeout
                    me.set 'timeout_obj', { 'id' : obj.id, 'timeout' : true, 'overtime' : true }

            ), 1000

        getProcess  : (tab_name) ->
            me = this

            if MC.process[tab_name]

                # get the data
                flag_list = MC.process[tab_name].flag_list

                console.log 'tab name:' + tab_name
                console.log 'flag_list:' + flag_list

                last_flag = me.get 'flag_list'

                me.set 'flag_list', flag_list

                if 'is_done' of flag_list and flag_list.is_done     # completed

                    # complete the progress
                    $('#progress_bar').css('width', "100%" )
                    $('#progress_num').text last_flag.steps
                    $('#progress_total').text last_flag.steps

                    ide_event.trigger ide_event.SWITCH_WAITING_BAR

                    # hold on 1 second
                    setTimeout () ->

                        app_id = flag_list.app_id
                        region = MC.process[tab_name].region

                        # save png
                        app_name = MC.process[tab_name].name

                        # not current tab return
                        if MC.data.current_tab_id isnt 'process-' + region + '-' + app_name
                            return

                        # hold on two seconds
                        setTimeout () ->

                            # update tab
                            ide_event.trigger ide_event.UPDATE_DESIGN_TAB, app_id, app_name + ' - app'

                            # reload app
                            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'RELOAD_APP', app_name, region, app_id

                            # update navgation
                            ide_event.trigger ide_event.UPDATE_APP_LIST, 'RUN_STACK', [ app_id ]

                            #ide_event.trigger ide_event.PROCESS_RUN_SUCCESS, app_id, region
                            #ide_event.trigger ide_event.DELETE_TAB_DATA, tab_name
                            #ide_event.trigger ide_event.UPDATE_APP_LIST, null

                        , 800

                    , 1000

                else if 'is_inprocess' of flag_list and flag_list.is_inprocess # in progress

                    if flag_list.dones > 0 and 'steps' of flag_list and flag_list.steps > 0
                        $('#progress_bar').css('width', Math.round( flag_list.dones/flag_list.steps*100 ) + "%" )
                        $('#progress_num').text flag_list.dones

                    else
                        $('#progress_bar').css('width', "0" )
                        $('#progress_num').text '0'

                    $('#progress_total').text flag_list.steps

                else

                    me.set 'flag_list', flag_list

            null

        getTimestamp : ( state, tab_id ) ->
            console.log 'getTimestamp', state, tab_id

            if state is 'OPEN_PROCESS'
                @set 'timeout_obj', { 'id' : tab_id, 'timeout' : false, 'overtime' : false }

            else if state is 'OLD_PROCESS'

                # get obj
                obj = MC.common.other.getCacheMap tab_id

                # when create_time is 'timeout' show tip
                if obj and obj.create_time is 'timeout'
                    @set 'timeout_obj', { 'id' : tab_id, 'timeout' : true, 'overtime' : false }

                # when create_time is 'overtime' show tip
                if obj and obj.create_time is 'overtime'
                    @set 'timeout_obj', { 'id' : tab_id, 'timeout' : true, 'overtime' : true }

                # when create_time isnt 'timeout' or 'overtime' hide tip
                else if obj and obj.create_time isnt [ 'timeout', 'overtime' ]
                    @set 'timeout_obj', { 'id' : tab_id, 'timeout' : false, 'overtime' : false }

            null

        getVpcResourceService : ( region, vpc_id, state )  ->
            console.log 'getVpcResourceService', region, vpc_id, state

            if state is 'OPEN_PROCESS'

                # get resources
                resources = MC.common.other.getUnmanagedVpc vpc_id

                # delete resource.origin
                if resources and resources.origin
                    delete resources.origin

                # delete session
                MC.session.remove 'aws_resource_' + region

                #cache original app json
                MC.data.app_info = {}
                ApiRequest("app_get_info", {
                    username   : $.cookie( 'usercode' )
                    session_id : $.cookie( 'session_id' )
                    vpc_ids    : [vpc_id]
                }).then ( result )=>
                    console.info result
                    if result.length is 0
                        console.warn "can not get app by vpc_id [" + vpc_id + "]"
                    else if result.length is 1
                        if result[0] and result[0].id
                            MC.data.app_info[ vpc_id ] = result[0]
                        else
                            console.warn "can not get app info by vpc_id [" + vpc_id + "]"
                    else
                        console.warn "can not get more than one app by one vpc_id [" + vpc_id + "]"

                    # call api
                    aws_model.resource { sender : this }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, resources, 'vpc', 1


                , ( err )->
                    if err.error < 0
                      # Network Error, Try reloading
                      window.location.reload()
                    else
                      # If there's service error. I think we need to logout, because I guess it's because the session is not right.
                      App.logout()

                    throw err


                # set state 'OLD'
                MC.common.other.setCacheMap vpc_id, null, 'OLD', null

            else if state is 'OLD_PROCESS'
                # get obj
                obj = MC.common.other.searchCacheMap { key : 'origin_id', value : vpc_id }

                if obj and obj.data and obj.state is 'FINISH'

                    # reload app view
                    @reloadAppView obj

                else if obj and obj.id

                    # update tab icon
                    ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, 'visualization', obj.id

                else
                    console.log 'not found process'

            null

        getDescribeImages : ( region, ami_ids ) ->
            console.log 'getDescribeImages', region, ami_ids

            # deep copy
            me = $.extend true, {}, this

            ami_model.DescribeImages { sender : me }, $.cookie( 'usercode' ), $.cookie( 'session_id' ), region, ami_ids

            null

        setCacheMapDataFlg : ( data ) ->
            console.log 'setCacheMapDataFlg', data

            # set 'FINISH' and 'appview' flag by vpc( origin_id )
            obj = MC.common.other.setCacheMap data.origin_id, null, 'FINISH', null

            # when current tab reload app view
            if MC.common.other.isCurrentTab obj.id
                @reloadAppView obj

            null

        reloadAppView : ( obj ) ->
            console.log 'reloadAppView', obj

            # set 'appview' flag by vpc( origin_id )
            MC.common.other.setCacheMap obj.origin_id, null, null, 'appview'

            # set appview id
            appview_id = 'appview-' + obj.uid

            # update tab
            ide_event.trigger ide_event.UPDATE_DESIGN_TAB, appview_id, obj.origin_id + ' - visualization'

            # reload app
            ide_event.trigger ide_event.OPEN_DESIGN_TAB, 'RELOAD_APPVIEW', obj.origin_id, obj.region, appview_id

            null

    }

    model = new ProcessModel()
    return model
