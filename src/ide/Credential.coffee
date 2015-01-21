
define [ "ApiRequest", "backbone" ], ( ApiRequest )->

  __maskString = ( text )->
    if text.length > 6
      return (new Array(text-6)).join("*")+text.substr(-6)
    else
      return text

  ###
  # Credential is a model used to represent the credential item of a project.
  # One can obtain the particular credential of a project, then update it with the
  # credential's method.
  ###
  PLATFORM =
    AWS       : "aws"
    OPENSTACK : "openstack"

  PROVIDER =
    AWSGLOBAL : "aws::global"
    AWSCHINA  : "aws::china"


  Credential = Backbone.Model.extend {

    ###
    attr :
      id           : ""
      platform     : ""
      provider     : ""
      isDemo       : ""
      awsAccount   : ""
      awsAccessKey : ""
      awsSecretKey : ""
    ###
    constructor : ( attr, option )->
      Backbone.Model.call this
      console.assert( option && option.project )

      @set {
        project      : option.project
        id           : attr.id
        provider     : attr.provider
        platform     : attr.cloud_type
        isDemo       : attr.is_demo
        awsAccount   : attr.account_id
        awsAccessKey : attr.access_key
        awsSecretKey : attr.secret_key
      }
      return

    isDemo   : ()-> !!@get("isDemo")
    platform : ()-> @get("platform")

    __update : ( cred, forceUpdate )->
      ApiRequest( "project_update_credential", {
        project_id   : @get("project").id
        key_id       : @id
        credential   : {
          account_id : cred.awsAccount
          access_key : cred.awsAccessKey
          secret_key : cred.awsSecretKey
        }
        force_update : forceUpdate
      } )

    ###
    cred : {
      provider     : ""
      awsAccount   : ""
      awsAccessKey : ""
      awsSecretKey : ""
    }
    ###
    validate : ( cred )->
      cred = $.extend {}, cred
      cred.provider = @get("provider")
      Credential.validate( cred )

    ###
    cred : {
      awsAccount   : ""
      awsAccessKey : ""
      awsSecretKey : ""
    }
    ###
    update : ( cred, forceUpdate = false, valid = true )->
      self = @
      if valid
        p = @validate( cred ).then ()-> self.__update( cred, forceUpdate )
      else
        p = @__update( cred, forceUpdate )

      p.then ( res )->
        self.set {
          awsAccount   : cred.awsAccount
          awsAccessKey : __maskString( cred.awsAccessKey )
          awsSecretKey : __maskString( cred.awsSecretKey )
        }
  }, {
    PLATFORM : PLATFORM
    PROVIDER : PROVIDER

    ###
    credential : {
      provider     : ""
      awsAccount   : ""
      awsAccessKey : ""
      awsSecretKey : ""
    }
    ###
    validate : ( credential )-> ApiRequest( "project_validate_credential", {credential:credential} )
  }

  Credential
