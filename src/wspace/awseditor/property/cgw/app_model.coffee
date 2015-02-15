#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', 'Design', 'constant', 'CloudResources' ], ( PropertyModel, Design, constant, CloudResources ) ->

    CGWAppModel = PropertyModel.extend {

        init : ( uid )->

          # cgw assignment
          myCGWComponent = Design.instance().component( uid )

          cgw = CloudResources( Design.instance().credentialId(), constant.RESTYPE.CGW, Design.instance().region()).get(myCGWComponent.get('appId'))?.toJSON()
          if not cgw
            return false

          cgw = $.extend true, {}, cgw
          cgw.uid = uid
          cgw.name = myCGWComponent.get 'name'
          cgw.description = myCGWComponent.get 'description'

          this.set cgw
          null
    }

    new CGWAppModel()
