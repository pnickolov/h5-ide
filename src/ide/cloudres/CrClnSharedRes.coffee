
define [
  "./CrCollection"
  "CloudResources"
  "ApiRequest"
  "constant"
  "./CrModelDhcp"
  "./CrModelKeypair"
  "./CrModelSslcert"
  "./CrModelTopic"
  "./CrModelSubscription"
  "./CrModelSnapshot"
], ( CrCollection, CloudResources, ApiRequest, constant, CrDhcpModel, CrKeypairModel, CrSslcertModel, CrTopicModel, CrSubscriptionModel, CrSnapshotModel )->

  ### Dhcp ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDhcpCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DHCP
    model : CrDhcpModel
    modelIdAttribute : "dhcpOptionsId"

    doFetch : ()-> ApiRequest("dhcp_DescribeDhcpOptions", {region_name : @region()})
    trAwsXml : (res)-> res.DescribeDhcpOptionsResponse.dhcpOptionsSet?.item
  }


  ### Keypair ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrKeypairCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.KP
    model : CrKeypairModel

    doFetch : ()-> ApiRequest("kp_DescribeKeyPairs", {region_name : @region()})
    trAwsXml : (res)-> res.DescribeKeyPairsResponse.keySet?.item
    parseFetchData : (res)->
      for i in res
        i.id = i.keyName
      res

    parseExternalData :( res ) ->
      #TODO map attribute

  }


  ### Ssl cert ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSslcertCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.IAM
    model : CrSslcertModel

    doFetch : ()-> ApiRequest("iam_ListServerCertificates")
    trAwsXml : (res)-> res.ListServerCertificatesResponse.ListServerCertificatesResult.ServerCertificateMetadataList?.member
    parseFetchData : (res)->
      for i in res
        i.id   = i.ServerCertificateId
        i.Name = i.ServerCertificateName
        delete i.ServerCertificateName
        delete i.ServerCertificateId

      res

    parseExternalData :( res ) ->
      #TODO map attribute

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
    trAwsXml : (res)-> res.ListTopicsResponse.ListTopicsResult.Topics?.member
    parseFetchData : (res)->
      for i in res
        i.id   = i.TopicArn
        i.Name = i.TopicArn.split(":").pop()
        delete i.TopicArn

      res

    parseExternalData :( res ) ->
      #TODO map attribute

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
    trAwsXml : (res)-> res.ListSubscriptionsResponse.ListSubscriptionsResult.Subscriptions?.member
    parseFetchData : (res)->
      for i in res
        i.id = CrSubscriptionModel.getIdFromData( i )

      res

    parseExternalData :( res ) ->
      #TODO map attribute

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
      return

    doFetch : ()-> ApiRequest("ebs_DescribeSnapshots", {region_name:@region(), owners:["self"]})
    trAwsXml : (res)-> res.DescribeSnapshotsResponse.snapshotSet?.item
    parseFetchData : (res)->
      for i in res
        i.id = i.snapshotId
        if i.tagSet
          i.name = i.tagSet.Name || i.tagSet.name || ""
          delete i.tagSet

        delete i.snapshotId

        if i.status is "pending" then @startPollingStatus()

      res

    parseExternalData :( res ) ->
      #TODO map attribute

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

      # When we don't get any pending items.
      # We set all the snapshot models as completed.
      completeStatus = {
        progress : 100
        status   : "completed"
      }
      statusMap = {}

      if res isnt null and res.item
        @startPollingStatus()
        for i in res.item
          statusMap[ i.snapshotId ] = { progress:i.progress }

      @where({status:"pending"}).forEach ( model )->
        model.set statusMap[ model.get("id") ] || completeStatus

      return
  }
