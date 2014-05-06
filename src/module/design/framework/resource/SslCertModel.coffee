
define [ "constant", "../ComplexResModel", "../ConnectionModel"  ], ( constant, ComplexResModel, ConnectionModel )->

  SslCertUsage = ConnectionModel.extend {
    type : "SslCertUsage"
    oneToMany : constant.RESTYPE.IAM
  }


  SslCertModel = ComplexResModel.extend {

    type : constant.RESTYPE.IAM

    defaults :
      name   : "v"
      body   : ""
      chain  : ""
      key    : ""
      arn    : ""
      certId : ""

    isVisual : ()-> false

    assignTo : ( target )-> new SslCertUsage( this, target )

    serialize : () ->

      return { component : {
        uid : @id
        type : "AWS.IAM.ServerCertificate"
        name : @get("name")
        resource :
          PrivateKey : @get("key")
          CertificateBody : @get("body")
          CertificateChain : @get("chain")
          ServerCertificateMetadata :
            ServerCertificateName : @get("appName") or @get("name")
            Arn : @get("arn") or ""
            ServerCertificateId : @get("certId") or ""
      }}

    updateValue : (certObj) ->
      for key, value of certObj
        this.set(key, value)
      null
  },{
    handleTypes : constant.RESTYPE.IAM
    deserialize : ( data )->
      new SslCertModel({
        id      : data.uid
        name    : data.name
        body    : data.resource.CertificateBody
        chain   : data.resource.CertificateChain
        key     : data.resource.PrivateKey
        arn     : data.resource.ServerCertificateMetadata.Arn
        certId  : data.resource.ServerCertificateMetadata.ServerCertificateId
        appName : data.resource.ServerCertificateMetadata.ServerCertificateName
      })
      null
  }

  SslCertModel
