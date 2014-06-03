
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrSslcertModel"
    ### env:dev:end ###

    taggable : false

    defaults :
      Path             : ""
      Name             : "" # == "ServerCertificateName"
      PrivateKey       : ""
      CertificateChain : ""
      CertificateBody  : ""

    doUpdate : ( newAttr )->
      self = @
      ApiRequest("iam_UpdateServerCertificate", {
        servercer_name     : @get("Name")
        new_servercer_name : newAttr.Name
        new_path           : newAttr.Path
      }).then ()->
        self.set newAttr
        self

    doCreate : ()->
      self = @
      ApiRequest("iam_UploadServerCertificate", {
        servercer_name : @get("Name")
        cert_body      : @get("CertificateBody")
        private_key    : @get("PrivateKey")
        cert_chain     : @get("CertificateChain")
        path           : @get("Path")
      }).then ( res )->
        # Empty the private data.
        self.attributes.CertificateChain = ""
        self.attributes.PrivateKey       = ""

        try

          res = res.UploadServerCertificateResponse.UploadServerCertificateResult.ServerCertificateMetadata

          res.Arn = res.Arn
          res.Expiration = res.Expiration
          res.Path = res.Path
          res.id   = res.ServerCertificateId
          res.Name = res.ServerCertificateName
          res.UploadDate = res.UploadDate
          
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Ssl cert created but aws returns invalid data." )

        self.set res
        console.log "Created SslCert resource", self

        self

    doDestroy : ()-> ApiRequest("iam_DeleteServerCertificate", { servercer_name:@get("Name") })
  }
