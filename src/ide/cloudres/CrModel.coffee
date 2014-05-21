
define ["backbone"], ()->

  CrModel = Backbone.Model.extend {

    remove : ()->

    # Override this method to return a promise which will be resolved when the model is removed.
    doRemove : ()->

  }
