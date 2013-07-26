#############################
#  View Mode for header module
#############################

define [ 'backbone', 'jquery', 'underscore', 'session_model', 'constant' ], (Backbone, $, _, session_model, constant) ->

    ws = MC.data.websocket

    HeaderModel = Backbone.Model.extend {

        defaults:
            'info_list'     : null    # [{id, rid, name, operation, error, time, is_readed(true|false), is_error, is_request, is_process, is_complete}]
            'unread_num'    : null

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
            me.set 'unread_num', unread_num

            # listen
            me.updateRequest()

            null

        parseInfo : (req) ->
            me = this

            item = {}
            item.id = req.id
            item.rid = req.rid
            item.time = req.time_end
            item.time_str = MC.dateFormat(new Date(item.time*1000), "hh:mm yyyy-MM-dd")
            item.region = constant.REGION_LABEL[req.region]
            item.is_readed = true
            item.is_error = false
            item.is_request = false
            item.is_process = false
            item.is_complete = false

            if req.brief
                lst = req.brief.split ' '
                item.operation = lst[0]
                item.name = lst[lst.length-1]

                if req.state is 'Failed'
                    item.is_error = true
                    item.error = req.data
                else if req.state is 'Pending'
                    item.is_request = true
                else if req.state is 'InPorcess'
                    item.is_process = true
                else if req.state is 'Done'
                    item.is_complete = true
                else
                    return

                if item.rid.search('stack') == 0 and not item.is_error
                    lst = req.data.split ' '
                    item.rid = lst[lst.length-1]
                    item.name = item.rid
            else
                return

            item

        queryRequest : () ->
            me = this

            info_list = []

            # [{id, rid, name, operation, error, time, is_readed(true|false), is_error, is_request, is_process, is_complete}]
            for req in MC.data.websocket.collection.request.find().fetch()
                item = me.parseInfo req

                if item
                    info_list.push item


            info_list.sort (a, b) ->
                return if a.time <= b.time then 1 else -1

            info_list

        updateRequest : () ->
            me = this

            if ws
                query = ws.collection.request.find()
                handle = query.observeChanges {
                    changed : (id, req) ->

                        item = me.parseInfo req

                        if item
                            info_list = me.get 'info_list'
                            unread_num = me.get 'unread_num'

                            if item.rid != MC.canvas_data.id
                                item.is_readed = false

                                unread_num += 1
                                me.set 'unread_num', unread_num

                            # remove the old request and new to the header
                            info_list.splice info_list.indexOf i for i in info_list when i.id == item.id

                            info_list.splice 0, 1, item

                            me.set 'info_list', info_list
                }

        logout : () ->

            #invoke session.logout api
            session_model.logout {sender: this}, $.cookie( 'usercode' ), $.cookie( 'session_id' )

            #logout return handler (dispatch from service/session/session_model)
            session_model.once 'SESSION_LOGOUT_RETURN', ( forge_result ) ->

                if !forge_result.is_error
                    #logout succeed

                    result = forge_result.resolved_data

                #delete cookies
                $.cookie 'userid',      null, { expires: 0 }
                $.cookie 'usercode',    null, { expires: 0 }
                $.cookie 'session_id',  null, { expires: 0 }
                $.cookie 'region_name', null, { expires: 0 }
                $.cookie 'email',       null, { expires: 0 }
                $.cookie 'has_cred',    null, { expires: 0 }

                #redirect to page login.html
                window.location.href = 'login.html'

                return false

            null

    }

    model = new HeaderModel()

    return model