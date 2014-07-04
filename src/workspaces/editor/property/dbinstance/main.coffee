####################################
#  Controller for design/property/dbinstance module
####################################

define [
         "Design"
         "../base/main"
         "./view"
         # "./app_model",
         # "./app_view",
         "../sglist/main"
         "constant"
         "event"
], ( Design,
     PropertyModule,
     view,
     sglist_main, constant, ide_event ) ->

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

            me = this

            null

        initApp : () ->
            @model = app_model
            @view  = app_view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null
    }
    null
