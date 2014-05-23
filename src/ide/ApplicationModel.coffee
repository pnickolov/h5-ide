
###
----------------------------
  The Model for application
----------------------------

  This model holds all the data of the user in our database. For example, stack list / app list / notification things and extra.

###

define [ "./submodels/OpsCollection", "./submodels/OpsModel", "ApiRequest", "backbone",  "event", "constant", "component/exporter/Thumbnail" ], ( OpsCollection, OpsModel, ApiRequest, Backbone, ide_event, constant, ThumbUtil )->

  Backbone.Model.extend {

    defaults : ()->
      __websocketReady : false
      notification     : [] # An array holding the notification data
      stackList        : new OpsCollection()
      appList          : new OpsCollection()

    markNotificationRead : ()->
      for i in @attributes.notification
        i.readed = true
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

      # When app/stack list is fetched, we first cleanup unused thumbnail. Then
      # Tell others that we are ready.
      Q.all([ sp, ap ]).then ()->
        try
          ThumbUtil.cleanup self.appList().pluck("id").concat( self.stackList().pluck("id") )
        catch e

        return

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
      App.WS.on "requestChange", (idx, dag)-> self.__processSingleNotification idx, dag

    __triggerNotification : _.debounce ()->
      @trigger "change:notification"
    , 300

    __processSingleNotification : ( idx, dag )->

      req = App.WS.collection.request.findOne({'_id':idx})
      if not req then return

      item = @__parseRequestInfo req, dag
      if not item then return

      info_list = @attributes.notification

      # check whether same operation
      for i, idx in info_list
        if i.id is item.id
          same_req = i
          break

      # Don't update the list if the request's state is not changed.
      if same_req and _.isEqual( same_req.state, item.state )
          return

      # TODO : Mark the item as read if the current tab is the item's tab.
      # Currently, the item is mark as readed if the WS is not ready.
      item.readed = not App.WS.isReady()

      # Prepend the item to the list.
      info_list.splice idx, 1
      info_list.splice 0, 0, item

      # Notify the others that notification has changed.
      @__triggerNotification()
      null

    __parseRequestInfo : (req, dag)->
      if not req.brief then return

      request =
        id         : req.id
        region     : constant.REGION_SHORT_LABEL[ req.region ]
        time       : req.time_end
        operation  : constant.OPS_CODE_NAME[ req.code ]
        targetId   : if dag.spec then dag.spec.id else req.rid
        targetName : if req.code is "Forge.Stack.Run" then req.brief.split(" ")[2] else ""
        state      : {}
        readed     : true

      switch req.state
        when constant.OPS_STATE.OPS_STATE_FAILED
          request.error = req.data
          request.state = { failed : true }
        when constant.OPS_STATE.OPS_STATE_INPROCESS
          request.time  = req.time_begin
          request.state = { processing : true }
        when constant.OPS_STATE.OPS_STATE_DONE
          request.state = {
            completed  : true
            terminated : req.code is 'Forge.App.Terminate'
          }
        when constant.OPS_STATE.OPS_STATE_PENDING
          # Only format time when the request is not pending
          request.state = { pending : true }
          request.time  = ""

      if request.time
        request.time = MC.dateFormat( new Date( request.time * 1000 ) , "hh:mm yyyy-MM-dd")

        if req.state isnt constant.OPS_STATE.OPS_STATE_INPROCESS

          time_begin = parseInt req.time_begin, 10
          time_end   = parseInt req.time_end, 10
          if not isNaN( time_begin ) and not isNaN( time_end ) and time_end >= time_begin
            duration = time_end - time_begin
            if duration < 60
              request.duration = "Took #{duration} sec."
            else
              request.duration = "Took #{Math.round(duration/60)} min."

      request

  }
