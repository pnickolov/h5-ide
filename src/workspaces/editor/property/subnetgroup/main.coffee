####################################
#  Controller for design/property/dbinstance module
####################################

define [ "Design"
         "../base/main"
         "./view"
         "constant"
], ( Design, PropertyModule, view, constant ) ->

    SubnetGroupModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.DBSBG ]

        initStack : ( uid )->
            @model = Design.instance().component uid
            @view  = view
            null

    }

    null
