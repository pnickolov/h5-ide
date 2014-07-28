####################################
#  Controller for design/property/dbinstance module
####################################

define [ "Design"
         "../base/main"
         "./view"
         './app_view'
         "constant"
], ( Design, PropertyModule, view, app_view,constant ) ->

    SubnetGroupModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.DBSBG ]

        initStack : ( uid )->
            @model = Design.instance().component uid
            @view  = view
            null

        initApp : (uid) ->
            @model = Design.instance().component uid
            @view  = app_view
            null

        initAppEdit : ( uid ) ->
            @model = Design.instance().component uid
            @view  = view
            null
    }

    null
