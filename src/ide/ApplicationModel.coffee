
###
----------------------------
  The Model for application
----------------------------

  This model holds all the data of the user in our database. For example, stack list / app list / notification things and extra.

###

define [ "./submodels/OpsCollection", "./submodels/OpsModel", "ApiRequest", "backbone",  "event", "constant" ], ( OpsCollection, OpsModel, ApiRequest, Backbone, ide_event, constant )->

  Backbone.Model.extend {

    defaults : ()->
      __websocketReady : false
      notification     : [] # An array holding the notification data
      stackList        : new OpsCollection()
      appList          : new OpsCollection()

    markNotificationRead : ()->
      for i in @attributes.notification
        i.is_readed = true
      return

    # Convenient method to get the stackList and appList
    stackList : ()-> @attributes.stackList
    appList   : ()-> @attributes.appList

    # This method creates a new stack in IDE, and returns that model.
    # The stack is not automatically stored in server.
    # You need to call save() after that.
    createStack : ( region )->
      m = new OpsModel({
        name   : @attributes.stackList.getNewName()
        region : region
      }, {
        initJsonData : true
      })
      @attributes.stackList.add m
      m


    ###
      Internal methods
    ###
    initialize : ()->
      @__initializeNotification()
      return

    # Fetches user's stacks and apps from the server, returns a promise
    fetch : ()->
      self = this
      sp = ApiRequest("stack_list").then (res)-> self.get("stackList").set self.__parseListRes( res )
      ap = ApiRequest("app_list").then   (res)-> self.get("appList").set   self.__parseListRes( res )

      Q.all [ sp, ap ]

    __parseListRes : ( res )->
      r = []
      stateMap =
        "Running" : OpsModel.State.Running
        "Stopped" : OpsModel.State.Stopped

      for ops in res
        r.push {
          id         : ops.id
          updateTime : ops.time_update
          region     : ops.region
          usage      : ops.usage
          name       : ops.name
          state      : stateMap[ ops.state ] || OpsModel.State.UnRun
        }
      r

    # In the previous version, Websocket emits changes of request things (AKA, the notification). Websocket actually holds a copy of the request things. And the request things is process by module/design/toolbar ( ridiculous, but whatever ). There's no place to actually store the notification ( Well, it's stored in module/header, But I think the notification is a data source of the Application ). So now, we store the notification here.
    __initializeNotification : ()->
      # LEGACY Code. When switching between tabs, we automatically mark notification of that tab as read.
      # Temporary removed right now. Because I think this kind of trigger is too buggy.
      ###
      ide_event.onLongListen ide_event.SWITCH_DASHBOARD, () -> return
      ide_event.onLongListen ide_event.SWITCH_TAB, () -> return
      ide_event.onListen ide_event.OPEN_DESIGN, () -> return
      ###

      # It seems like the toolbar doesn't even process the request_item, in which we can just directly listen to WS that the request item event.
      self = this
      ide_event.onLongListen ide_event.UPDATE_REQUEST_ITEM, (idx) -> self.__processSingleNotification idx

    __processSingleNotification : ( idx )->

      req = App.WS.collection.request.findOne({'_id':idx})
      if not req then return

      item = @__parseRequestInfo req
      if not item then return

      info_list = @attributes.notification

      # check whether same operation
      for i, idx in info_list
        if i.id is item.id
          same_req = i
          break

      # not update when the same state
      if same_req and same_req.is_request is item.is_request and same_req.is_process is item.is_process and same_req.is_complete is item.is_complete
          return

      # TODO : Mark the item as read if the current tab is the item's tab.
      # Currently, the item is mark as readed if the WS is not ready.
      item.is_readed = not App.WS.isReady()

      # Prepend the item to the list.
      info_list.splice idx, 1
      info_list.splice 0, 0, item

      # Notify the others that notification has changed.
      if not @__notifyDebounce
        @__notifyDebounce = setTimeout ()=>
          @trigger "change:notification"
          @__notifyDebounce = null
          return
        , 300
      null

    __parseRequestInfo : (req) ->
      if not req.brief then return

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
      if item.rid.search('stack') == 0 # run stack
        item.name = lst[2]

      item.is_terminated = item.is_complete and item.operation is 'terminate'

      item
  }
