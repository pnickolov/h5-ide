#############################
#  View Mode for header module
#############################

define [ 'backbone', 'jquery', 'underscore', 'constant' ], (constant) ->

    ws = MC.data.websocket

    HeaderModel = Backbone.Model.extend {

        defaults:
            'info_list'     : null    # [{id, rid, name, operation, error, time, is_readed(true|false), is_error, is_request, is_process, is_complete}]
            'unread_num'    : null

        getInfoList : () ->
            me = this

            info_list = me.get 'info_list'
            unread_num = me.get 'unread_num'

            #if not info_list
                ## get from ws
                #info_list = me.queryRequest()

            if not unread_num
                unread_num = 0

            #me.set 'info_list', info_list
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
            item.time_str = req.time_str
            item.region = req.region
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
            else
                return

            item

        queryRequest : () ->
            info_list = []

            # [{id, rid, name, operation, error, time, is_readed(true|false), is_error, is_request, is_process, is_complete}]
            for req in MC.data.websocket.collection.request.find().fetch()
                item = me.parseInfo req

                if item
                    info_list.push item

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

            null

    }

    model = new HeaderModel()

    return model