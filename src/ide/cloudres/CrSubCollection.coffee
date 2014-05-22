
define [
  "./CrCollection"
  "ApiRequest"
  "constant"
  "./CrDhcpModel"
  "./CrSslcertModel"
], ( CrCollection, ApiRequest, constant, CrDhcpModel, CrSslcertModel )->

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
