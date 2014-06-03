
define ["ApiRequest", "backbone"], ( ApiRequest )->

  Backbone.Model.extend {

    # Returns a promise which will be resolved when the model is saved to AWS, the resolved data is the model itself
    save : ()->
      if @get("id")
        console.error "The resource is already created. You cannot re-create it again."
        return

      # prevent saving multiple time.
      if not @__savePromise
        self = @
        @__savePromise = @doCreate().then ()->
            self.__collection.add self
            self.tagResource()
            delete self.__collection
            delete self.__savePromise
            self
          , ( error )->
            delete self.__savePromise
            throw error

      @__savePromise

    # Returns a promise which will be resolved when the model is updated.
    update : ( newAttr )->
      if not @get("id")
        console.error "The resource is not yet created, so you can't update the resource.", @
        return

      if not @doUpdate
        console.error "This kind of resource does not support update,", @getCollection().type
        return

      @doUpdate( newAttr )

    # Returns a promise which will be resolved when the model is deleted from AWS
    # When the model is removed, the model will stop listening to any event.
    destroy : ()->
      self = @
      @doDestroy().then ()->
        self.getCollection().remove self
        self
      , (err)->
        # If AWS fail to remove an resource due to `ID.NotFound`, we treat it as
        # the resource is removed.
        if err.awsError is 400 and err.awsErrorCode.indexOf(".NotFound") != -1
          self.getCollection().remove self
          return self

        throw err

    # Subclass needs to override these method.
    ###
    dosave    : ()->
    doUpdate  : ( newAttr )->
    doDestroy : ()->
    ###

    getCollection : ()-> @__collection || @collection

    # Tags this resource. It should only called right after the resource is created.
    tagResource : ()->
      if @taggable is false then return

      self = @
      ApiRequest("ec2_CreateTags",{
        region_name  : @getCollection().region()
        resource_ids : [@get("id")]
        tags         : [{Name:"Created by",Value:App.user.get("username")}]
      }).then ()->
        console.log "Success to tag resource", self.get("id")
        return

  }, {
    ### env:dev ###
    extend : ( protoProps, staticProps )->
      ### jshint -W061 ###

      parent = this

      funcName = protoProps.ClassName || protoProps.type.split(".").pop()
      childSpawner = eval( "(function(a) { var #{funcName} = function(){ return a.apply( this, arguments ); }; return #{funcName}; })" )

      if protoProps and protoProps.hasOwnProperty "constructor"
        cstr = protoProps.constructor
      else
        cstr = ()-> return parent.apply( this, arguments )

      child = childSpawner( cstr )

      _.extend(child, parent, staticProps)

      funcName = "PROTO_" + funcName
      prototypeSpawner = eval( "(function(a) { var #{funcName} = function(){ this.constructor = a }; return #{funcName}; })" )

      Surrogate = prototypeSpawner( child )
      Surrogate.prototype = parent.prototype
      child.prototype = new Surrogate()

      if protoProps
        _.extend(child.prototype, protoProps)

      child.__super__ = parent.prototype
      ### jshint +W061 ###

      child
    ### env:dev:end ###
  }
