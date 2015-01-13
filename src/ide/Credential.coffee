
define [ "backbone" ], ()->

  __platformFromAttr : ( attr )->
      if attr.awsAccessKey then return "AWS"
      return "UNKOWN"

  ###
  # Credential is a model used to represent the credential item of a project.
  # One can obtain the particular credential of a project, then update it with the
  # credential's method.
  ###

  Backbone.Model.extend {

    ###
    attr :
      awsAccount   : ""
      awsAccessKey : ""
      awsSecretKey : ""
    ###
    initialize : ( attr, option )->
      console.assert( option && option.project )
      @set attr
      @set {
        "project"  : option.project
        "platform" : __platformFromAttr( attr )
      }
      return

    isDemo   : ()-> !!@get("isDemo")
    platform : ()-> @get("platform")

    __update : ( attr, forceUpdate )->
      p = __platformFromAttr( attr )

      if p is "AWS" or p is "UNKOWN"
        return ApiRequest( "account_set_credential", {
          account_id   : attr.awsAccount
          access_key   : attr.awsAccessKey
          secret_key   : attr.awsSecretKey
          force_update : forceUpdate
        } )
      null

    # attr should be like the `attr` in initialize()
    validate : ( attr )->
      p = __platformFromAttr( attr )

      if p is "AWS" or p is "UNKOWN"
        return ApiRequest("account_validate_credential", {
          access_key : attr.awsAccessKey
          secret_key : attr.awsSecretKey
        })

      null

    update : ( attr, forceUpdate = false, valid = true )->
      self = @
      if valid
        p = @validate( attr ).then ()-> self.__update( attr, forceUpdate )
      else
        p = @__update( attr, forceUpdate )

      p.then ()->

        if attr.awsAccessKey.length > 6
          attr.awsAccessKey = (new Array(attr.awsAccessKey.length-6)).join("*")+attr.awsAccessKey.substr(-6)
        if attr.awsSecretKey.length > 6
          attr.awsSecretKey = (new Array(attr.awsSecretKey.length-6)).join("*")+attr.awsSecretKey.substr(-6)

        self.set {
          awsAccount   : attr.awsAccount
          awsAccessKey : attr.awsAccessKey
          awsSecretKey : attr.awsSecretKey
        }
  }
