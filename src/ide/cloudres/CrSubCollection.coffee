
define [
  "./CrCollection"
  "CloudResources"
  "ApiRequest"
  "constant"
  "./CrDhcpModel"
  "./CrSslcertModel"
  "./CrTopicModel"
  "./CrSubscriptionModel"
], ( CrCollection, CloudResources, ApiRequest, constant, CrDhcpModel, CrSslcertModel, CrTopicModel, CrSubscriptionModel )->

  ### Dhcp ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrDhcpCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.DHCP
    model : CrDhcpModel

    doFetch : ()-> ApiRequest("dhcp_DescribeDhcpOptions", {region_name : @category})
    parseFetchData : (res)->
      res = res.DescribeDhcpOptionsResponse.dhcpOptionsSet.item
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
      res = res.ListServerCertificatesResponse.ListServerCertificatesResult.ServerCertificateMetadataList.member
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

    doFetch : ()-> ApiRequest("sns_ListTopics", {region_name : @category})
    parseFetchData : (res)->
      res = res.ListTopicsResponse.ListTopicsResult.Topics.member
      for i in res
        i.id   = i.TopicArn
        i.Name = i.TopicArn.split(":").pop()
        delete i.TopicArn

      res

    __clearSubscription : ( removedModel, collection, options )->
      # Automatically remove all the subscription that is bound to this topic.
      snss = CloudResources( constant.RESTYPE.SUBSCRIPTION, @category )
      removes = []
      for sub in snss.models
        if sub.get("TopicArn") is removedModel.id
          removes.push sub

      if removes.length then snns.remove( removes )
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

    doFetch : ()-> ApiRequest("sns_ListSubscriptions", {region_name : @category})
    parseFetchData : (res)->
      res = res.ListSubscriptionsResponse.ListSubscriptionsResult.Subscriptions.member
      for i in res
        i.id = CrSubscriptionModel.uniqueId()

      res
  }
