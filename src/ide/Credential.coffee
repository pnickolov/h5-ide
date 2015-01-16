
define [ "backbone" ], ()->

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


  Backbone.Model.extend {

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
    initialize : ( attr, option )->
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

    # __update : ( attr, forceUpdate )->
    #   p = __platformFromAttr( attr )

    #   if p is "AWS" or p is "UNKOWN"
    #     return ApiRequest( "account_set_credential", {
    #       account_id   : attr.awsAccount
    #       access_key   : attr.awsAccessKey
    #       secret_key   : attr.awsSecretKey
    #       force_update : forceUpdate
    #     } )
    #   null

    # # attr should be like the `attr` in initialize()
    # validate : ( attr )->
    #   p = __platformFromAttr( attr )

    #   if p is "AWS" or p is "UNKOWN"
    #     return ApiRequest("account_validate_credential", {
    #       access_key : attr.awsAccessKey
    #       secret_key : attr.awsSecretKey
    #     })

    #   null

    update : ( attr, forceUpdate = false, valid = true )->
      self = @
      if valid
        p = @validate( attr ).then ()-> self.__update( attr, forceUpdate )
      else
        p = @__update( attr, forceUpdate )

      p.then ()->
        self.set {
          awsAccount   : attr.awsAccount
          awsAccessKey : __maskString( attr.awsAccessKey )
          awsSecretKey : __maskString( attr.awsSecretKey )
        }
  }, {
    PLATFORM : PLATFORM
    PROVIDER : PROVIDER
  }
