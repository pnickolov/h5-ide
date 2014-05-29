

define ["ApiRequest", "CloudResources", "constant", "backbone"], ( ApiRequest, CloudResources, constant )->

  VisualizeVpcParams =
    'AWS.VPC.VPC'    : {
      'filter' : {
        'isDefault' : "false" # ignore default VPC
      }
    }
    'AWS.VPC.Subnet' : {}
    'AWS.EC2.Instance' : {
      'filter' : {
        'instance-state-name' : [ 'pending', 'running', 'stopping', 'stopped' ] # filter terminating and terminated instances
      }
    }
    'AWS.VPC.NetworkInterface' : {}
    'AWS.ELB'                  : {}
    # 'AWS.VPC.RouteTable'     : {}
    # 'AWS.VPC.VPNConnection'  : {
    #   'filter'               : {
    #     'state'              : [ 'pending', 'available' ] # filter deleting and deleted vpn
    #   }
    # }
    # 'AWS.VPC.VPNGateway' : {
    #   'filter' : {
    #     'state' : [ 'pending', 'available' ] # filter deleting and deleted vgw
    #   }
    # }
    # 'AWS.AutoScaling.Group'    : {}


  ###
    Dashboard Model
  ###
  Backbone.Model.extend {

    defaults :
      visualizeData : []

    initialize : ()->
      # Watch websocket, so that we will know when the import is done.
      @listenTo App.WS, "visualizeUpdate", @onVisualizeUpdated

      @listenTo CloudResources( constant.RESTYPE.INSTANCE ), "update", @onGlobalResChanged
      @listenTo CloudResources( constant.RESTYPE.EIP ), "update", @onGlobalResChanged
      @listenTo CloudResources( constant.RESTYPE.VOL ), "update", @onGlobalResChanged
      @listenTo CloudResources( constant.RESTYPE.ELB ), "update", @onGlobalResChanged
      @listenTo CloudResources( constant.RESTYPE.VPN ), "update", @onGlobalResChanged

    ### Visualize ###
    visualizeTimestamp : ()-> @__visRequestTime

    # Returns a promise that will be fullfiled after the vpc's data is fetched.
    visualizeVpc : ( force )->
      if force then @__visRequest = null

      if @__visRequest then return

      @__isVisReady = false
      @__visRequest = true
      @__visRequestTime = +(new Date())

      self = @
      ApiRequest("aws_resource",{
        region_name : null
        resources   : VisualizeVpcParams
        addition    : "statistic"
        retry_times : 1
      }).fail ( error )->
        self.__visRequest = false
        self.__isVisReady = true
        self.__isVisFail  = true
        self.set "visualizeData", []
        return

      return

    onVisualizeUpdated : ( result )->
      # Discards any data if we didn't fires a request.
      if not @__visRequest then return

      @__isVisReady = true
      @__isVisFail  = false
      @attributes.visualizeData = []
      @set "visualizeData", @parseVisData( result )
      return

    isVisualizeReady   : ()-> !!@__isVisReady
    isVisualizeFailed  : ()-> !!@__isVisFail
    isVisualizeTimeout : ()->
      # This method has sideeffect which will make the promise to be null
      if @__visRequestTime - (new Date()) > 60*10*1000
        @__visVpcDefer = null
        return true
      false

    parseVisData : ( data ) ->
      delete data._id
      delete data.username
      delete data.timestamp

      resourceMap = ( res )-> _.keys(res||{})
      instanceMap = ( res, stopped )->
        instances = []
        for id, ami of (res||{})
          state = ami.instanceState?.name || ""
          if stopped
            if state is "stopped" or state is "stopping"
              instances.push id
          else
            if state is "running" or state is "pending"
              instances.push id
        instances

      regions = []
      for region, vpcMap of data
          vpcs = []
          regions.push {
            id      : region
            name    : constant.REGION_SHORT_LABEL[ region ]
            subname : constant.REGION_LABEL[ region ]
            vpcs    : vpcs
          }
          for vpc, resources of vpcMap
            try
              # Ingore app that is created by us.
              if resources.Tag and resources.Tag.item and resources.Tag.item.length
                tags = []
                for t in resources.Tag.item
                  if t then tags.push t.key
                if tags.indexOf("Created by")>=0 and tags.indexOf("app-id")>=0
                  continue

              obj =
                id      : vpc
                subnet  : resourceMap resources["AWS|VPC|Subnet"]
                ami     : instanceMap resources["AWS|EC2|Instance"]
                stopped : instanceMap resources["AWS|EC2|Instance"], true
                eni     : resourceMap resources["AWS|VPC|NetworkInterface"]
                eip     : resourceMap resources["AWS|EC2|EIP"]
                elb     : resourceMap resources["AWS|ELB"]

              obj.disabled = obj.eni.length > 300
              obj.empty    = obj.subnet.length + obj.ami.length + obj.stopped.length + obj.eni.length + obj.eip.length + obj.elb.length is 0
              vpcs.push obj
            catch e

      regions


    ### Cloud Resources ###
    onGlobalResChanged : ()-> @trigger "change:globalResources", @isAwsResReady()
    fetchAwsResources : ( region )->
      if not region
        CloudResources( constant.RESTYPE.INSTANCE ).fetch()
        CloudResources( constant.RESTYPE.EIP ).fetch()
        CloudResources( constant.RESTYPE.VOL ).fetch()
        CloudResources( constant.RESTYPE.ELB ).fetch()
        CloudResources( constant.RESTYPE.VPN ).fetch()
        return

    isAwsResReady : (region)->
      ready = CloudResources( constant.RESTYPE.INSTANCE ).isReady() && CloudResources( constant.RESTYPE.EIP ).isReady() && CloudResources( constant.RESTYPE.VOL ).isReady() && CloudResources( constant.RESTYPE.ELB ).isReady() && CloudResources( constant.RESTYPE.VPN ).isReady()
      if not region then return ready

      ready

    getAwsResData : ( region )->
      if not region
        filter = ( m )-> if m.attributes.instanceState then m.attributes.instanceState.name is "running" else false

        return {
          instances : CloudResources( constant.RESTYPE.INSTANCE ).groupByCategory(undefined, filter)
          eips      : CloudResources( constant.RESTYPE.EIP ).groupByCategory()
          volumes   : CloudResources( constant.RESTYPE.VOL ).groupByCategory()
          elbs      : CloudResources( constant.RESTYPE.ELB ).groupByCategory()
          vpns      : CloudResources( constant.RESTYPE.VPN ).groupByCategory()
        }

      filter = { category : region }
      {
        instances    : CloudResources( constant.RESTYPE.INSTANCE ).where(filter)
        eips         : CloudResources( constant.RESTYPE.EIP ).where(filter)
        volumes      : CloudResources( constant.RESTYPE.VOL ).where(filter)
        elbs         : CloudResources( constant.RESTYPE.ELB ).where(filter)
        vpns         : CloudResources( constant.RESTYPE.VPN ).where(filter)
        vpcs         : []
        asgs         : []
        cloudwatches : []
        snss         : []
      }
  }
