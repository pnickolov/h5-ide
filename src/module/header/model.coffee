#############################
#  View Mode for header module
#############################

define [ 'backbone', 'jquery', 'underscore',
         'session_model', 'constant', 'event', 'forge_handle' ], ( Backbone, $, _, session_model, constant, ide_event, forge_handle ) ->

    #ws = MC.data.websocket

    HeaderModel = Backbone.Model.extend {

        defaults:
            'info_list'     : []      # [{id, rid, name, operation, error, time, is_readed(true|false), is_request, is_process, is_complete, is_terminated}]
            'unread_num'    : null
            'in_dashboard'  : true
            'has_cred'      : true      # default has credential
            'user_name'     : null
            'user_email'    : null

        initialize : ->

            #logout return handler (dispatch from service/session/session_model)
            @on 'SESSION_LOGOUT_RETURN', ( forge_result ) ->

                if !forge_result.is_error
                    #logout succeed

                    result = forge_result.resolved_data

                forge_handle.cookie.deleteCookie()

                #SSO
                $.cookie 'madeiracloud_ide_session_id', null, { expires: 0 }

                window.location.href = "login.html"

                return false

        init : ()->
            @set {
                'user_name'  : MC.base64Decode $.cookie( 'usercode' )
                'user_email' : MC.base64Decode $.cookie( 'email' )
            }
            null

        updateHeader : (req) ->

            item = @parseInfo req
            if not item
                return

            info_list    = @attributes.info_list
            unread_num   = @attributes.unread_num
            in_dashboard = @attributes.in_dashboard

            # check whether same operation
            same_req = 0
            same_req++ for i in info_list when i.id == item.id

            # check whether on current tab
            if in_dashboard or item.rid != MC.canvas_data.id
                item.is_readed = false
                if same_req == 0 or unread_num == 0
                    @set 'unread_num', unread_num + 1

            # remove the old request and new to the header
            for i, idx in info_list
                if i.id is item.id
                    info_list.splice idx, 1
                    break

            info_list.splice 0, 0, item
            null

        parseInfo : (req) ->
            if not req.brief
                return

            lst = req.brief.split ' '
            item =
                is_readed     : true
                is_request    : req.state is constant.OPS_STATE.OPS_STATE_PENDING
                is_process    : req.state is constant.OPS_STATE.OPS_STATE_INPROCESS
                is_complete   : req.state is constant.OPS_STATE.OPS_STATE_DONE
                operation     : lst[0].toLowerCase()
                name          : lst[lst.length-1]
                region_label  : constant.REGION_SHORT_LABEL[req.region]
                time          : req.time_end

            item = $.extend {}, req, item


            if req.state is constant.OPS_STATE.OPS_STATE_FAILED
                item.error = req.data
            else if req.state is constant.OPS_STATE.OPS_STATE_INPROCESS
                item.time = req.time_begin

            # Only format time when the request is not pending
            if req.state isnt constant.OPS_STATE.OPS_STATE_PENDING
                item.time_str = MC.dateFormat( new Date( item.time * 1000 ) , "hh:mm yyyy-MM-dd")

                if req.state isnt constant.OPS_STATE.OPS_STATE_INPROCESS

                    time_begin = parseInt req.time_begin, 10
                    time_end   = parseInt req.time_end, 10
                    if not isNaN( time_begin ) and not isNaN( time_end ) and time_end >= time_begin
                        duration = time_end - time_begin
                        if duration < 60
                            item.duration = "Took #{duration} sec."
                        else
                            item.duration = "Took #{Math.round(duration/60)} min."

            # rid
            if item.rid.search('stack') == 0    # run stack
                item.name = lst[2]

                if item.is_complete     # run stack success
                    item.rid = req.data.split(' ')[lst.length-1]

            item.is_terminated = item.is_complete and item.operation is 'terminate'

            item

        # queryRequest : () ->
        #     me = this

        #     info_list = []

        #     # [{id, rid, name, operation, error, time, is_readed(true|false), is_error, is_request, is_process, is_complete}]
        #     for req in MC.data.websocket.collection.request.find().fetch()
        #         item = me.parseInfo req

        #         if item
        #             info_list.push item

        #     # filter done and terminated app
        #     terminated_list = []
        #     terminated_list.push i.rid for i in info_list when i.is_complete and i.operation is 'terminate'
        #     info_list[info_list.indexOf i].is_terminated = true for i in info_list when i.rid in terminated_list

        #     info_list.sort (a, b) ->
        #         return if a.time <= b.time then 1 else -1

        #     info_list

        setFlag : (flag) ->
            @set 'in_dashboard', flag

            unread_num = @attributes.unread_num
            info_list  = @attributes.info_list

            if not flag and unread_num > 0 # in tab and update unread number when on the updating tab
                for info in info_list
                    if info.rid == MC.canvas_data.id and not info.is_readed
                        info.is_readed = true

                        @set 'unread_num', unread_num - 1
                        break

            null

        resetInfoList : () ->
            for i in @attributes.info_list
                i.is_readed = true

            @set 'unread_num', 0
            null

        openApp : (req_id) ->
            info_list = @attributes.info_list

            req = i for i in info_list when i.id == req_id

            if req

                ide_event.trigger ide_event.OPEN_APP_TAB, req.name, req.region, req.rid

            null

        logout : () ->

            #invoke session.logout api
            session_model.logout {sender: this}, $.cookie( 'usercode' ), $.cookie( 'session_id' )


    }

    return new HeaderModel()
