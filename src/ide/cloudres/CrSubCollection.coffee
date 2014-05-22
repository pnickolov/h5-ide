
define [
  "./CrCollection"
  "CloudResources"
  "ApiRequest"
  "constant"
  "./CrDhcpModel"
  "./CrSslcertModel"
  "./CrTopicModel"
  "./CrSubscriptionModel"
  "./CrSnapshotModel"
], ( CrCollection, CloudResources, ApiRequest, constant, CrDhcpModel, CrSslcertModel, CrTopicModel, CrSubscriptionModel, CrSnapshotModel )->

  ### Dhcp ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDhcpCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DHCP
    model : CrDhcpModel

    doFetch : ()-> ApiRequest("dhcp_DescribeDhcpOptions", {region_name : @region()})
    parseFetchData : (res)->
      res = res.DescribeDhcpOptionsResponse.dhcpOptionsSet
      if res is null then return []
      res = res.item

      for i in res
        i.id = i.dhcpOptionsId
        delete i.dhcpOptionsId

      res
  }



  ### Ssl cert ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSslcertCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.IAM
    model : CrSslcertModel

    doFetch : ()-> ApiRequest("iam_ListServerCertificates")
    parseFetchData : (res)->
      res = res.ListServerCertificatesResponse.ListServerCertificatesResult.ServerCertificateMetadataList
      if res is null then return []
      res = res.member

      for i in res
        i.id   = i.ServerCertificateId
        i.Name = i.ServerCertificateName
        delete i.ServerCertificateName
        delete i.ServerCertificateId

      res

  }, {
    category : ()-> "" # SslCert is global-wise.
  }


  ### Sns Topic ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrTopicCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.TOPIC
    model : CrTopicModel

    constructor : ()->
      @on "remove", @__clearSubscription
      CrCollection.apply this, arguments

    doFetch : ()-> ApiRequest("sns_ListTopics", {region_name : @region()})
    parseFetchData : (res)->

      res = res.ListTopicsResponse.ListTopicsResult.Topics
      if res is null then return []
      res = res.member

      for i in res
        i.id   = i.TopicArn
        i.Name = i.TopicArn.split(":").pop()
        delete i.TopicArn

      res

    __clearSubscription : ( removedModel, collection, options )->
      # Automatically remove all the subscription that is bound to this topic.
      snss = CloudResources( constant.RESTYPE.SUBSCRIPTION, @region() )
      removes = []
      for sub in snss.models
        if sub.get("TopicArn") is removedModel.id
          removes.push sub

      if removes.length then snss.remove( removes )
      return

    # Returns an array of topic which have no subscription.
    filterEmptySubs : ()->
      snss = CloudResources( constant.RESTYPE.SUBSCRIPTION, @category )
      topicMap = {}
      for i in snss.models
        topicMap[ i.get("TopicArn") ] = true

      @filter ( t )-> not topicMap[ t.get("id") ]
  }


  ### Sns Subscription ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSubscriptionCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.SUBSCRIPTION
    model : CrSubscriptionModel

    doFetch : ()-> ApiRequest("sns_ListSubscriptions", {region_name : @region()})
    parseFetchData : (res)->
      res = res.ListSubscriptionsResponse.ListSubscriptionsResult.Subscriptions
      if res is null then return []
      res = res.member

      for i in res
        i.id = CrSubscriptionModel.uniqueId()

      res
  }


  ### Snapshot ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSnapshotCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.SNAP
    model : CrSnapshotModel

    initialize : ()->
      @__pollingStatus = _.bind @__pollingStatus, @

    doFetch : ()-> ApiRequest("ebs_DescribeSnapshots", {region_name:@region(), owners:["self"]})
    parseFetchData : (res)->
      res = res.DescribeSnapshotsResponse.snapshotSet
      if res is null then return []
      res = res.item

      for i in res
        i.id = i.snapshotId
        if i.tagSet
          i.name = i.tagSet.Name || i.tagSet.name || ""
          delete i.tagSet

        delete i.snapshotId

        if i.status is "pending" then @startPollingStatus()

      res

    startPollingStatus : ()->
      if @__polling then return
      @__polling = setTimeout @__pollingStatus, 2000
      return

    stopPollingStatus : ()->
      clearTimeout @__polling
      @__polling = null
      return

    __pollingStatus : ()->
      self = @
      ApiRequest("ebs_DescribeSnapshots", {
        region_name : @region()
        owners      : ["self"]
        filters     : [{"Name":"status","Value":["pending"]}]
      }).then ( res )->
        self.__polling = null
        self.__parsePolling( res )
        return
      , ()->
        self.__polling = null
        self.startPollingStatus()

    __parsePolling : ( res )->
      res = res.DescribeSnapshotsResponse.snapshotSet
      if res is null
        # When we don't get any pending items.
        # We set all the snapshot models as completed.
        @where({status:"pending"}).forEach ( model )->
          model.set {
            progress : 100
            status   : "completed"
          }
        return

      for i in res.item
        try
          @get(i.snapshotId).set({
            status   : i.status
            progress : i.progress
          })

          if i.status is "pending" then @startPollingStatus()
        catch e

      return
  }
