#############################
#  View Mode for design/property/dbinstance
#############################

define [ '../base/model', 'Design', 'constant', 'CloudResources' ], ( PropertyModel, Design, constant, CloudResources ) ->

  DBInstanceAppModel = PropertyModel.extend {

    init : ( uid )->

      # cgw assignment
      myDBInstance = Design.instance().component( uid )

      dbInstance = CloudResources(constant.RESTYPE.DBINSTANCE, Design.instance().region()).get(myDBInstance.get('appId'))?.toJSON()
      if not dbInstance
        return false

      dbInstance = $.extend true, {}, dbInstance
      dbInstance.name = myDBInstance.get 'name'

      this.set dbInstance
      null
  }

  new DBInstanceAppModel()
