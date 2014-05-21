
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

    initialize : ( attr )->
      @attributes.oldName = attr.Name

    doSave : ()->
      self = @
      newName = @get("Name")

      ApiRequest("iam_UpdateServerCertificate", {
        new_servercer_name : newName
        servercer_name     : @get("oldName")
        new_path           : @get("Path")
      }).then ()->
        self.set "oldName", newName
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
        console.info "Certificate Created", res

        # Empty the private data.
        self.attributes.CertificateChain = ""
        self.attributes.PrivateKey       = ""

        try
          id = res.UploadServerCertificateResponse.UploadServerCertificateResult.ServerCertificateMetadata.ServerCertificateId
        catch e
          throw McError( ApiRequest.Errors.InvalidAwsReturn, "Ssl cert created but aws returns invalid ata." )
        self.set( "id", id )
        self

    doDestroy : ()-> ApiRequest("iam_DeleteServerCertificate", { servercer_name:@get("Name") })
  }
