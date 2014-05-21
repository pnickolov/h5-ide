
define [ "./CrCollection", "./CrSslcertModel", "ApiRequest", "constant" ], ( CrCollection, CrSslcertModel, ApiRequest, constant )->

  CrCollection.extend {
    type  : constant.RESTYPE.IAM
    model : CrSslcertModel

    ### env:dev ###
    ClassName : "CrSslcertCollection"
    ### env:dev:end ###

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
    # SslCert is global-wise.
    category : ()-> ""
  }
