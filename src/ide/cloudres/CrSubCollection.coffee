
define [
  "./CrCollection"
  "ApiRequest"
  "constant"
  "./CrDhcpModel"
  "./CrSslcertModel"
  "./CcTopicModel"
  "./CrSubscriptionModel"
], ( CrCollection, ApiRequest, constant, CrDhcpModel, CrSslcertModel, CrTopicModel, CrSubscriptionModel )->

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

    doFetch : ()-> ApiRequest("sns_ListTopics")
    parseFetchData : (res)->
      res = res.ListTopicsResponse.ListTopicsResult.Topics.member
      for i in TopicArn
        i.id   = i.TopicArn
        i.Name = i.TopicArn.split(":").pop()
        delete i.TopicArn

      res
  }


  ### Sns Subscription ###
  CrCollection.extend {
    ### env:dev ###
    ClassName : "CrSubscriptionCollection"
    ### env:dev:end ###

    type  : constant.RESTYPE.SUBSCRIPTION
    model : CrSubscriptionModel

    doFetch : ()-> ApiRequest("sns_ListSubscriptions")
    parseFetchData : (res)->
      res = res.ListSubscriptionsResponse.ListSubscriptionsResult.Subscriptions.member
      for i in res
        i.id   = i.SubscriptionArn
        delete i.SubscriptionArn

      res
  }
