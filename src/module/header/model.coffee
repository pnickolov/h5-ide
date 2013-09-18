#############################
#  View Mode for header module
#############################

define [ 'backbone', 'jquery', 'underscore',
         'session_model', 'constant', 'event', 'forge_handle' ], ( Backbone, $, _, session_model, constant, ide_event, forge_handle ) ->

    #ws = MC.data.websocket

    HeaderModel = Backbone.Model.extend {

        defaults:
            'info_list'     : null      # [{id, rid, name, operation, error, time, is_readed(true|false), is_error, is_request, is_process, is_complete, is_terminated}]
            'unread_num'    : null
            'is_unread'     : null
            'in_dashboard'  : true
            'has_cred'      : true      # default has credential
            'user_name'     : null
            'user_email'    : null

        initialize : ->

            me = this

            #logout return handler (dispatch from service/session/session_model)
            me.on 'SESSION_LOGOUT_RETURN', ( forge_result ) ->

                if !forge_result.is_error
                    #logout succeed

                    result = forge_result.resolved_data

                forge_handle.cookie.deleteCookie()

                #SSO
                $.cookie 'madeiracloud_ide_session_id', null, { expires: 0 }

                #redirect to page login.html
                window.location.href = 'login.html'

                return false

        getUserName : ->
            console.log 'getUserName'
            this.set 'user_name', MC.base64Decode $.cookie( 'usercode' )

        getUserEmail : ->
            this.set 'user_email', MC.base64Decode $.cookie( 'email' )

            null

        getInfoList : () ->
            me = this

            info_list = me.get 'info_list'
            unread_num = me.get 'unread_num'

            if not info_list
                #get from ws
                info_list = me.queryRequest()

            if not unread_num
                unread_num = 0

            me.set 'info_list', info_list

            is_unread = false
            if unread_num>0
                is_unread = true
            me.set 'is_unread', is_unread
            me.set 'unread_num', unread_num

            # listen
            #me.updateRequest()

            null

        updateHeader : (req) ->
            me = this

            item = me.parseInfo req

            if item
                info_list = me.get 'info_list'
                unread_num = me.get 'unread_num'
                in_dashboard = me.get 'in_dashboard'

                # check whether same operation
                same_req = 0
                same_req++ for i in info_list when i.id == item.id

                # check whether on current tab
                if in_dashboard or item.rid != MC.canvas_data.id
                    item.is_readed = false
                    if same_req == 0 or unread_num == 0
                        unread_num += 1

                        me.set 'unread_num', unread_num
                        me.set 'is_unread', true

                # remove the old request and new to the header
                info_list.splice(info_list.indexOf(i), 1) for i in info_list when i and i.id == item.id

                info_list.splice 0, 0, item

                # filter done and terminated app
                terminated_list = []
                terminated_list.push i.rid for i in info_list when i.is_complete and i.operation is 'terminate'
                info_list[info_list.indexOf i].is_terminated = true for i in info_list when i.rid in terminated_list

                me.set 'info_list', info_list


        parseInfo : (req) ->
            if not req.brief
                return

            lst = req.brief.split ' '
            item_def =
                is_readed     : true
                is_error      : req.state is constant.OPS_STATE.OPS_STATE_FAILED
                is_request    : req.state is constant.OPS_STATE.OPS_STATE_PENDING
                is_process    : req.state is constant.OPS_STATE.OPS_STATE_INPROCESS
                is_complete   : req.state is constant.OPS_STATE.OPS_STATE_DONE
                is_terminated : false
                operation     : lst[0].toLowerCase()
                name          : lst[lst.length-1]
                region_label  : constant.REGION_SHORT_LABEL[req.region]
                time          : req.time_end

            # req.time_begin | req.time_end

            item = $.extend {}, req, item_def

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

            item

        queryRequest : () ->
            me = this

            info_list = []

            # [{id, rid, name, operation, error, time, is_readed(true|false), is_error, is_request, is_process, is_complete}]
            for req in MC.data.websocket.collection.request.find().fetch()
                item = me.parseInfo req

                if item
                    info_list.push item

            # filter done and terminated app
            terminated_list = []
            terminated_list.push i.rid for i in info_list when i.is_complete and i.operation is 'terminate'
            info_list[info_list.indexOf i].is_terminated = true for i in info_list when i.rid in terminated_list

            info_list.sort (a, b) ->
                return if a.time <= b.time then 1 else -1

            info_list

        # updateRequest : () ->
        #     me = this

        #     if ws
        #         query = ws.collection.request.find()
        #         handle = query.observeChanges {
        #             changed : (id, dag) ->

        #                 req_list = MC.data.websocket.collection.request.find({'_id' : id}).fetch()

        #                 if req_list

        #                     req = req_list[0]

        #                     console.log 'request ' + req.data + "," + req.state

        #                     item = me.parseInfo req

        #                     if item
        #                         info_list = me.get 'info_list'
        #                         unread_num = me.get 'unread_num'
        #                         in_dashboard = me.get 'in_dashboard'

        #                         # check whether same operation
        #                         the_req = []
        #                         the_req.push i for i in info_list when i.id == item.id and i.operation == item.operation
        #                         if the_req.length <= 0
        #                             if in_dashboard or item.rid != MC.canvas_data.id
        #                                 item.is_readed = false

        #                                 unread_num += 1
        #                                 me.set 'unread_num', unread_num
        #                                 me.set 'is_unread', true

        #                             # remove the old request and new to the header
        #                             info_list.splice(info_list.indexOf(i), 1) for i in info_list when i and i.id == item.id

        #                             info_list.splice 0, 0, item

        #                             me.set 'info_list', info_list

        #                             me.trigger 'HEADER_UPDATE'

        #                         null
        #         }

        #         null

        setFlag : (flag) ->
            me = this

            me.set 'in_dashboard', flag

            unread_num = me.get 'unread_num'
            info_list = me.get 'info_list'

            if not flag and unread_num > 0 # in tab and update unread number when on the updating tab
                for info in info_list
                    if info.rid == MC.canvas_data.id and not info.is_readed
                        info_list[info_list.indexOf(info)].is_readed = true
                        unread_num = unread_num - 1

                        me.set 'unread_num', unread_num
                        if unread_num>0
                            me.set 'is_unread', true
                        else
                            me.set 'is_unread', false

                        me.set 'info_list', info_list

                        #me.trigger 'HEADER_UPDATE'

                        break
            null

        resetInfoList : () ->
            me = this

            info_list = me.get 'info_list'

            $.each info_list, (id, req) ->
                if not req.is_readed
                    info_list[id].is_readed = true

                null

            me.set 'info_list', info_list
            me.set 'unread_num', 0
            me.set 'is_unread', false

            #me.trigger 'HEADER_UPDATE'

            null

        openApp : (req_id) ->
            me = this

            info_list = me.get 'info_list'

            req = i for i in info_list when i.id == req_id

            if req

                ide_event.trigger ide_event.OPEN_APP_TAB, req.name, req.region, req.rid

            null

        logout : () ->

            #invoke session.logout api
            session_model.logout {sender: this}, $.cookie( 'usercode' ), $.cookie( 'session_id' )


    }

    model = new HeaderModel()

    return model
