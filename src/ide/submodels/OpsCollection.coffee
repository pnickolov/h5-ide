
###
----------------------------
  The Model for stack / app
----------------------------

  This model represent a stack or an app. It contains serveral methods to manipulate the stack / app

###

define [ "./OpsModel", "backbone"], ( OpsModel )->

  Backbone.Collection.extend {
    model      : OpsModel
    comparator : "updateTime"
  }
