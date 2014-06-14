
###
----------------------------
  The Model for application
----------------------------

  This model holds all the data of the user in our database. For example, stack list / app list / notification things and extra.

###

define [ "./submodels/OpsCollection", "OpsModel", "ApiRequest", "backbone", "constant", "component/exporter/Thumbnail" ], ( OpsCollection, OpsModel, ApiRequest, Backbone, constant, ThumbUtil )->

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

    getOpsModelById : ( opsId )-> @attributes.appList.get(opsId) || @attributes.stackList.get(opsId)

    clearImportOps : ()-> @attributes.appList.remove @attributes.appList.find ( m )-> m.isImported()

    createImportOps : ( region, vpcId )->
      m = @attributes.appList.findWhere({importVpcId:vpcId})
      if m then return m
      m = new OpsModel({
        importVpcId : vpcId
        region      : region
        state       : OpsModel.State.Running
      })
      @attributes.appList.add m
      m

    # This method creates a new stack in IDE, and returns that model.
    # The stack is not automatically stored in server.
    # You need to call save() after that.
    createStack : ( region )->
      console.assert( constant.REGION_KEYS.indexOf(region) >= 0, "Region is not recongnised when creating stack:", region )
      m = new OpsModel({
        name   : @attributes.stackList.getNewName()
        region : region
      }, {
        initJsonData : true
      })
      @attributes.stackList.add m
      m

    createStackByJson : ( json )->
      if not @attributes.stackList.isNameAvailable( json.name )
        json.name = @attributes.stackList.getNewName()

      m = new OpsModel({
        name   : json.name
        region : json.region
      }, {
        jsonData : json
      })
      @attributes.stackList.add m
      m

    getPriceData : ( awsRegion )-> (@__appdata[ awsRegion ] || {}).price


    ###
      Internal methods
    ###
    initialize : ()->
      @__appdata = {}
      @__initializeNotification()
      return

    # Fetches user's stacks and apps from the server, returns a promise
    fetch : ()->
      self = this
      sp = ApiRequest("stack_list", {region_name:null}).then (res)-> self.get("stackList").set self.__parseListRes( res )
      ap = ApiRequest("app_list",   {region_name:null}).then (res)-> self.get("appList").set   self.__parseListRes( res )

      # Load Application Data.
      appdata = ApiRequest("aws_aws",{fields : ["region","price","region_instance_type","instance_type"]}).then ( res )->
        self.__appdata[ i.region ] = i for i in res
        return

      # When app/stack list is fetched, we first cleanup unused thumbnail. Then
      # Tell others that we are ready.
      Q.all([ sp, ap ]).then ()->
        try
          ThumbUtil.cleanup self.appList().pluck("id").concat( self.stackList().pluck("id") )
        catch e

        return

    __parseListRes : ( res )->
      r = []

      for ops in res
        r.push {
          id         : ops.id
          updateTime : ops.time_update
          region     : ops.region
          usage      : ops.usage
          name       : ops.name
          state      : OpsModel.State[ ops.state ] || OpsModel.State.UnRun
          stoppable  : not (ops.property and ops.property.stoppable is false)
        }
      r

    # In the previous version, Websocket emits changes of request things (AKA, the notification). Websocket actually holds a copy of the request things. And the request things is process by module/design/toolbar ( ridiculous, but whatever ). There's no place to actually store the notification ( Well, it's stored in module/header, But I think the notification is a data source of the Application ). So now, we store the notification here.
    __initializeNotification : ()->
      # It seems like the toolbar doesn't even process the request_item, in which we can just directly listen to WS that the request item event.
      self = this
      App.WS.on "requestChange", (idx, dag)-> self.__processSingleNotification idx, dag

    __triggerNotification : _.debounce ()->
      @trigger "change:notification"
    , 400

    __processSingleNotification : ( idx )->

      req = App.WS.collection.request.findOne({'_id':idx})
      if not req then return

      item = @__parseRequestInfo req
      if not item then return

      @__handleRequestChange( item )

      info_list = @attributes.notification

      # check whether same operation
      for i, idx in info_list
        if i.id is item.id
          same_req = i
          break

      # Don't update the list if the request's state is not changed.
      if same_req and _.isEqual( same_req.state, item.state )
          return

      # Currently, the item is mark as readed if the WS is not ready.
      item.readed = not App.WS.isReady()

      # Mark the item as read if the current tab is the item's tab.
      if not item.readed and App.workspaces
        space = App.workspaces.getAwakeSpace()
        ops = @appList().get( item.targetId ) or @stackList().get( item.targetId )
        item.readed = space.isWorkingOn( ops )

      # Prepend the item to the list.
      info_list.splice idx, 1
      info_list.splice 0, 0, item

      # Limit the notificaiton queue
      if info_list.length > 30
        info_list.length = 30

      # Notify the others that notification has changed.
      @__triggerNotification()
      null

    __parseRequestInfo : (req)->
      if not req.brief then return

      dag = req.dag

      request =
        id         : req.id
        region     : constant.REGION_SHORT_LABEL[ req.region ]
        time       : req.time_end
        operation  : constant.OPS_CODE_NAME[ req.code ]
        targetId   : if dag and dag.spec then dag.spec.id else req.rid
        targetName : req.brief.split(" ")[2] || ""
        state      : { processing : true }
        readed     : true

      switch req.state
        when constant.OPS_STATE.OPS_STATE_FAILED
          request.error = req.data
          request.state = { failed : true }
        when constant.OPS_STATE.OPS_STATE_INPROCESS
          request.time  = req.time_begin
          request.step  = 0
          if req.dag
            request.totalSteps = req.dag.step.length
            for i in req.dag.step
              if i[1] is "done" then ++request.step
          else
            request.totalSteps = 1

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

    __handleRequestChange : ( request )->
      # This method is used to update the state of an app OpsModel

      if not App.WS.isReady() then return # only updates when WS has finished pushing the initial data.

      if request.state.pending then return

      theApp = @appList().get( request.targetId )
      if not theApp
        # If the app is newly created from an stack. It might not have an appId yet,
        # But it should have a requestId.
        theApp = @appList().findWhere({requestId:request.id})
        if theApp and request.targetId
          theApp.set "id", request.targetId

      if not theApp then return
      if not request.state.processing and not theApp.isProcessing() then return

      if request.state.processing
        theApp.setStatusProgress( request.step, request.totalSteps )
      else
        theApp.setStatusWithWSEvent( request.operation, request.state, request.error )
  }
