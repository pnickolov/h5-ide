#############################
#  View Mode for design/property/cgw
#############################

define [ '../base/model', 'Design', 'constant' ], ( PropertyModel, Design, constant ) ->

    CGWAppModel = PropertyModel.extend {

        init : ( uid )->

          # cgw assignment
          myCGWComponent = Design.instance().component( uid )

          appData = MC.data.resource_list[ Design.instance().region() ]

          cgw = appData[ myCGWComponent.get 'appId' ]
          if not cgw
            return false

          cgw = $.extend true, {}, cgw
          cgw.name = myCGWComponent.get 'name'

          this.set cgw
          null
    }

    new CGWAppModel()
