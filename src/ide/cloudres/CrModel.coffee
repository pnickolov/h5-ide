
define ["./CrCollection", "backbone"], ( CrCollection )->

  CrModel = Backbone.Model.extend {

    # Returns a promise which will be resolved when the model is saved to AWS
    save : ()->
      self = @

      if not @get("id")
        return @doCreate().then ()->
          self.__collection.add self
          delete self.__collection
          self
      else
        return @doSave()

    # Returns a promise which will be resolved when the model is deleted from AWS
    remove : ()->
      self = @
      @doRemove().then ()->
        self.collection.remove self
        self

    # Subclass needs to override these method.
    # doSave   : ()->
    # doCreate : ()->
    # doRemove : ()->
  }, {
    ### env:dev ###
    extend : CrCollection.__detailExtend
    ### env:dev:end ###
  }
