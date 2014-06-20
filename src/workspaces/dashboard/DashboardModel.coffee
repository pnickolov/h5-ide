

define ["ApiRequest", "CloudResources", "constant", "backbone"], ( ApiRequest, CloudResources, constant )->

  VisualizeVpcParams =
    'AWS.VPC.VPC'    : {}
    'AWS.VPC.Subnet' : {}
    'AWS.EC2.Instance' : {
      'filter' : {
        'instance-state-name' : [ 'pending', 'running', 'stopping', 'stopped' ] # filter terminating and terminated instances
      }
    }
    'AWS.VPC.NetworkInterface' : {}
    'AWS.ELB'                  : {}


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

      @listenTo CloudResources( constant.RESTYPE.VPC ), "update", @onRegionResChanged
      @listenTo CloudResources( constant.RESTYPE.ASG ), "update", @onRegionResChanged
      @listenTo CloudResources( constant.RESTYPE.CW ),  "update", @onRegionResChanged

      for region in constant.REGION_KEYS
        @listenTo CloudResources( constant.RESTYPE.SUBSCRIPTION, region ), "update", @onRegionResChanged

    ### Visualize ###
    visualizeTimestamp : ()-> @__visRequestTime

    clearVisualizeData : ()->
      @set "visualizeData", []
      @__visRequest = null
      return

    # Returns a promise that will be fullfiled after the vpc's data is fetched.
    visualizeVpc : ( force )->
      if force then @__visRequest = null

      if @__visRequest then return

      @__isVisReady = false
      @__visRequest = true
      @__visRequestTime = +(new Date())

      self = @
      ApiRequest("aws_resource", {
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
      @attributes.visualizeData = null
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
              tags = {}
              if resources.Tag and resources.Tag.item and resources.Tag.item.length
                for t in resources.Tag.item
                  tags[ t.key ] = t.value

              obj =
                id      : vpc
                name    : tags["Name"] || tags["name"]
                subnet  : resourceMap resources["AWS|VPC|Subnet"]
                ami     : instanceMap resources["AWS|EC2|Instance"]
                stopped : instanceMap resources["AWS|EC2|Instance"], true
                eni     : resourceMap resources["AWS|VPC|NetworkInterface"]
                eip     : resourceMap resources["AWS|EC2|EIP"]
                elb     : resourceMap resources["AWS|ELB"]

              obj.disabled = obj.eni.length > 300
              vpcs.push obj
            catch e

      regions


    ### Cloud Resources ###
    onRegionResChanged : ()-> @trigger "change:regionResources"
    onGlobalResChanged : ()->
      @trigger "change:globalResources"
      @trigger "change:regionResources"

    fetchAwsResources : ( region )->
      if not region
        CloudResources( constant.RESTYPE.INSTANCE ).fetch()
        CloudResources( constant.RESTYPE.EIP ).fetch()
        CloudResources( constant.RESTYPE.VOL ).fetch()
        CloudResources( constant.RESTYPE.ELB ).fetch()
        CloudResources( constant.RESTYPE.VPN ).fetch()
        return

      CloudResources( constant.RESTYPE.SUBSCRIPTION, region ).fetch()
      CloudResources( constant.RESTYPE.VPC ).fetch()
      CloudResources( constant.RESTYPE.DHCP, region ).fetch()
      CloudResources( constant.RESTYPE.ASG ).fetch()
      CloudResources( constant.RESTYPE.CW ).fetch()
      CloudResources( constant.RESTYPE.ENI, region ).fetch()
      CloudResources( constant.RESTYPE.CGW, region ).fetch()
      CloudResources( constant.RESTYPE.VGW, region ).fetch()
      return


    isAwsResReady : ( region, type )->
      if not region
        datasource = [
          CloudResources( constant.RESTYPE.INSTANCE )
          CloudResources( constant.RESTYPE.EIP )
          CloudResources( constant.RESTYPE.VOL )
          CloudResources( constant.RESTYPE.ELB )
          CloudResources( constant.RESTYPE.VPN )
        ]
        for i in datasource
          if not i.isReady() then return false

        return true

      switch type
        when constant.RESTYPE.SUBSCRIPTION
          return CloudResources( type, region ).isReady()
        when constant.RESTYPE.VPC
          return CloudResources( type ).isReady() && CloudResources( constant.RESTYPE.DHCP, region ).isReady()
        when constant.RESTYPE.INSTANCE
          return CloudResources( type ).isReady() && CloudResources( constant.RESTYPE.ENI , region ).isReady()
        when constant.RESTYPE.VPN
          return CloudResources( type ).isReady() && CloudResources( constant.RESTYPE.VGW , region ).isReady() && CloudResources( constant.RESTYPE.CGW , region).isReady()
        else
          return CloudResources( type ).isReady()
      return

    getAwsResData : ( region, type )->
      if not region
        filter = ( m )-> if m.attributes.instanceState then m.attributes.instanceState.name is "running" else false

        return {
          instances : CloudResources( constant.RESTYPE.INSTANCE ).groupByCategory(undefined, filter)
          eips      : CloudResources( constant.RESTYPE.EIP ).groupByCategory()
          volumes   : CloudResources( constant.RESTYPE.VOL ).groupByCategory()
          elbs      : CloudResources( constant.RESTYPE.ELB ).groupByCategory()
          vpns      : CloudResources( constant.RESTYPE.VPN ).groupByCategory()
        }

      if type is constant.RESTYPE.SUBSCRIPTION
        return CloudResources( type, region ).models
      else
        return CloudResources( type, region ).where({ category : region })

    getAwsResDataById : ( region, type, id )-> CloudResources( type, region ).get(id)

    getResourcesCount : ( region )->
      filter = { category : region }
      data = {
        instances    : "INSTANCE"
        eips         : "EIP"
        volumes      : "VOL"
        elbs         : "ELB"
        vpns         : "VPN"
        vpcs         : "VPC"
        asgs         : "ASG"
        cloudwatches : "CW"
      }
      d = {}
      for key, type of data
        collection = CloudResources( constant.RESTYPE[type] )
        if collection.isReady()
          d[ key ] = collection.where(filter).length
        else
          d[ key ] = ""

      collection = CloudResources( constant.RESTYPE.SUBSCRIPTION, region )
      if collection.isReady()
        d.snss = collection.models.length
      else
        d.snss = ""
      d

    getResourceData : ( region, type, id )-> CloudResources( type, region ).get( id )
  }
