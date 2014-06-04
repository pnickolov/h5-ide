
###
  OpsEditorBase is the base class of a concrete OpsEditor
###

define [ "backbone" ], ()->

  Backbone.Model.extend {

    isAppStoppable : ()-> false
    isAppStopped   : ()-> false

  }
