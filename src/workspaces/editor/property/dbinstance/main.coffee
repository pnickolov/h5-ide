####################################
#  Controller for design/property/dbinstance module
####################################

define [
         "Design"
         "CloudResources"
         "../base/main"
         "./view"
         "./app_view"
         "../sglist/main"
         "constant"
         "event"
], ( Design,
     CloudResources,
     PropertyModule,
     view,
     app_view,
     sglist_main, constant ) ->

    DBInstanceModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.DBINSTANCE ]

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        setupStack : () ->
            null

        initStack : ( uid )->
            @model = Design.instance().component uid
            @view  = view
            null

        afterLoadStack : ()->
            sglist_main.loadModule @model
            null

        setupApp : () ->
            null

        initApp : ( uid ) ->
            resModel = Design.instance().component uid
            @model = CloudResources(constant.RESTYPE.DBINSTANCE, Design.instance().region()).get resModel.get('appId')
            @view  = app_view
            @view.resModel = resModel
            null

        initAppEdit : ( uid ) ->
            @model = Design.instance().component uid
            @model.isAppEdit = true
            @view  = view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null
    }
    null

    DBInstanceModule