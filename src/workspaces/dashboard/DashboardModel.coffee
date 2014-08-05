

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
        @listenTo CloudResources( constant.RESTYPE.DBINSTANCE, region ),  "update", @onGlobalResChanged

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
              if resources.Tag and resources.Tag.item
                if resources.Tag.item.length
                  for t in resources.Tag.item
                    tags[ t.key ] = t.value
                else
                  tags[ resources.Tag.item.key ] = resources.Tag.item.value

              obj =
                id      : vpc
                name    : tags.Name || tags.name
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
        _.each constant.REGION_KEYS, (e)->
          CloudResources( constant.RESTYPE.DBINSTANCE, e).fetch()
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
        globalReady = true
        datasource = [
          CloudResources( constant.RESTYPE.INSTANCE )
          CloudResources( constant.RESTYPE.EIP )
          CloudResources( constant.RESTYPE.VOL )
          CloudResources( constant.RESTYPE.ELB )
          CloudResources( constant.RESTYPE.VPN )
        ]
        for e in constant.REGION_KEYS
          globalReady = false unless CloudResources( constant.RESTYPE.DBINSTANCE, e).isReady()

        for i in datasource
          globalReady = false unless i.isReady()
        return globalReady

      #add isEIP to instance
      if CloudResources( constant.RESTYPE.INSTANCE, region ).isReady() and CloudResources( constant.RESTYPE.EIP ).isReady()
        eipGrp = CloudResources( constant.RESTYPE.EIP, region ).groupBy("instanceId")
        insGrp = CloudResources( constant.RESTYPE.INSTANCE, region ).groupBy("id")

        #reset isEIP
        _.each insGrp, (ins,key)->
          if ins[0]
            ins[0].set "isEIP", false

        _.each eipGrp, (eip,key)->
          if key isnt "undefined" and insGrp[key] and insGrp[key].length is 1
            insGrp[key][0].set 'isEIP', true

      switch type
        when constant.RESTYPE.SUBSCRIPTION
          return CloudResources( type, region ).isReady()
        when constant.RESTYPE.VPC
          return CloudResources( type ).isReady() && CloudResources( constant.RESTYPE.DHCP, region ).isReady()
        when constant.RESTYPE.INSTANCE
          return CloudResources( type ).isReady()
        when constant.RESTYPE.VPN
          return CloudResources( type ).isReady() && CloudResources( constant.RESTYPE.VGW , region ).isReady() && CloudResources( constant.RESTYPE.CGW , region).isReady()
        when constant.RESTYPE.DBINSTANCE
          return CloudResources( type, region ).isReady()
        else
          return CloudResources( type ).isReady()
      return

    getAwsResData : ( region, type )->
      if not region
        filter = ( m )-> if m.attributes.instanceState then m.attributes.instanceState.name is "running" else false
        DBInstancesCount = 0
        DBInstances =[]
        for e in constant.REGION_KEYS
          data =
            region: e
            data: CloudResources( constant.RESTYPE.DBINSTANCE, e ).models || []
            regionName: constant.REGION_SHORT_LABEL[ e ]
            regionArea: constant.REGION_LABEL[ e ]
          DBInstancesCount += data.data.length
          DBInstances.push data
        DBInstances.totalCount = DBInstancesCount
        return {
          instances : CloudResources( constant.RESTYPE.INSTANCE ).groupByCategory(undefined, filter)
          eips      : CloudResources( constant.RESTYPE.EIP ).groupByCategory()
          volumes   : CloudResources( constant.RESTYPE.VOL ).groupByCategory()
          elbs      : CloudResources( constant.RESTYPE.ELB ).groupByCategory()
          vpns      : CloudResources( constant.RESTYPE.VPN ).groupByCategory()
          rds       : DBInstances
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

      rdsCollection = CloudResources(constant.RESTYPE.DBINSTANCE, region)
      if rdsCollection.isReady()
        d.rds = rdsCollection.models.length
      else
        d.rds = ""
      collection = CloudResources( constant.RESTYPE.SUBSCRIPTION, region )
      if collection.isReady()
        d.snss = collection.models.length
      else
        d.snss = ""
      d

    getResourceData : ( region, type, id )-> CloudResources( type, region ).get( id )
  }
