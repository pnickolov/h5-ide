
define ["./CrCollection", "ApiRequest", "backbone"], ( CrCollection, ApiRequest )->

  CrModel = Backbone.Model.extend {

    # Returns a promise which will be resolved when the model is saved to AWS
    save : ()->
      self = @
      # prevent saving multiple time.
      if @__savePromise then return @__savePromise

      if not @get("id")
        @__savePromise = @doCreate().then ()->
          self.__collection.add self
          self.tagResource()
          delete self.__collection
          delete self.__savePromise
          self
        , ( error )->
          delete self.__savePromise
          throw error

      else
        @__savePromise = @doSave().finally ()-> delete self.__savePromise

      return @__savePromise

    getCollection : ()-> @__collection || @collection

    # Returns a promise which will be resolved when the model is deleted from AWS
    destroy : ()->
      self = @
      @doDestroy().then ()->
        self.collection.remove self
        self

    # Subclass needs to override these method.
    # doCreate  : ()->
    # doDestroy : ()->
    doSave : ()->
      # Default impl throws an Error
      defer = Q.defer()
      defer.reject McError( ApiRequest.Errors.InvalidMethodCall, "This cloud resource model doesn't support doSave() api, it means you cannot modify and save the resource." )
      defer.promise

    # Tags this resource. It should only called right after the resource is created.
    tagResource : ()->
      self = @
      ApiRequest("ec2_CreateTags",{
        resource_ids : [@get("id")]
        tags : [{Name:"Created by",Value:App.user.get("username")}]
      }).then ()->
        console.info "Success to tag resource", self.get("id")
        return

  }, {
    ### env:dev ###
    extend : CrCollection.__detailExtend
    ### env:dev:end ###
  }
