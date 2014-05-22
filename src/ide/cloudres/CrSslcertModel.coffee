
define [ "./CrModel", "ApiRequest" ], ( CrModel, ApiRequest )->

  CrModel.extend {

    ### env:dev ###
    ClassName : "CrSslcertModel"
    ### env:dev:end ###

    taggable : false

    defaults :
      Path             : ""
      Name             : ""
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
          id = res.UploadServerCertificateResponse.UploadServerCertificateResult.ServerCertificateMetadata.ServerCertificateId
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Ssl cert created but aws returns invalid ata." )

        self.set( "id", id )
        console.info "Certificate Created", self

        self

    doDestroy : ()-> ApiRequest("iam_DeleteServerCertificate", { servercer_name:@get("Name") })
  }
