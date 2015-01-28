
define [ "ApiRequest", "backbone" ], ( ApiRequest )->

  __maskString = ( text )->
    if text.length > 6
      return (new Array(text.length-6)).join("*")+text.substr(-6)
    else
      return text

  ###
  # Credential is a model used to represent the credential item of a project.
  # One can obtain the particular credential of a project, then update it with the
  # credential's method.
  ###
  PROVIDER =
    AWSGLOBAL : "aws::global"
    AWSCHINA  : "aws::china"


  Credential = Backbone.Model.extend {

    ###
    attr :
      id           : ""
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
        isDemo       : attr.is_demo
        alias        : attr.alias
        awsAccount   : attr.account_id
        awsAccessKey : attr.access_key
        awsSecretKey : attr.secret_key
      }
      return

    isDemo   : ()-> !!@get("isDemo")

    __update : ( cred, forceUpdate )->
      ApiRequest( "project_update_credential", {
        project_id   : @get("project").id
        key_id       : @id
        credential   : cred
        force_update : forceUpdate
      } )

    formatCredForRequest: ( cred ) ->
      {
        alias      : cred.alias
        account_id : cred.awsAccount
        access_key : cred.awsAccessKey
        secret_key : cred.awsSecretKey
        provider   : cred.provider or PROVIDER.AWSGLOBAL
      }

    add: () ->
      model = @
      credential = @formatCredForRequest @attributes
      project = @get( 'project' )

      ApiRequest( "project_add_credential", {
        project_id: project.id
        credential: credential
      }).then ( res ) ->
        model.set 'id', res[ 1 ]
        project.addCredential model

        res

    ###
    cred : {
      awsAccount   : ""
      awsAccessKey : ""
      awsSecretKey : ""
    }
    ###
    update : ( cred, forceUpdate = false )->
      self = @
      credential = @formatCredForRequest cred
      p = @__update( credential, forceUpdate )

      p.then ( res )->
        self.set {
          alias        : cred.alias
          awsAccount   : cred.awsAccount
          awsAccessKey : cred.awsAccessKey
          awsSecretKey : cred.awsSecretKey
        }

    save: ( cred, forceUpdate = false, valid = true ) ->
      cred = @attributes unless cred

      if @id
        @update cred, forceUpdate, valid
      else
        @add cred, valid

    destroy: ( options ) ->
      model = @
      project = @get 'project'
      ApiRequest( "project_remove_credential", { project_id: project.id, key_id: @id } ).then ( res )->
        model.trigger 'destroy', model, model.collection, options
        project.removeCredential model

        res

    toJSON: ->
      _.extend {}, @attributes, {
        awsAccessKey: __maskString(@attributes.awsAccessKey)
        awsSecretKey: __maskString(@attributes.awsSecretKey)
      }

  }, {
    PROVIDER : PROVIDER
  }

  Credential
