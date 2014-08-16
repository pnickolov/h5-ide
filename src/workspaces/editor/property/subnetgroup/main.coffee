####################################
#  Controller for design/property/dbinstance module
####################################

define [ "Design"
         "../base/main"
         "./view"
         './app_view'
         'CloudResources'
         "constant"
], ( Design, PropertyModule, view, app_view, CloudResources, constant ) ->

    SubnetGroupModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.DBSBG ]

        initStack : ( uid )->
            @model = Design.instance().component uid
            @view  = view
            @view.isAppEdit = false
            null

        initApp : (uid) ->
            @model = Design.instance().component uid
            @view  = app_view
            @view.appModel = CloudResources(constant.RESTYPE.DBSBG, Design.instance().region())?.get @model.get('appId')
            @view.isAppEdit = false
            null

        initAppEdit : ( uid ) ->
            @model = Design.instance().component uid
            @view  = view
            @view.isAppEdit = true
            null
    }

    null
