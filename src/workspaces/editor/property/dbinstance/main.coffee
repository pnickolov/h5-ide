####################################
#  Controller for design/property/dbinstance module
####################################

define [ "../base/main",
         "./model",
         "./view",
         # "./app_model",
         # "./app_view",
         "../sglist/main",
         "constant",
         "event"
], ( PropertyModule,
     model, view,
     sglist_main, constant, ide_event ) ->

    DBInstanceModule = PropertyModule.extend {

        handleTypes : [ constant.RESTYPE.DBINSTANCE ]

        onUnloadSubPanel : ( id )->
            # sglist_main.onUnloadSubPanel id
            null

        setupStack : () ->
            # @view.on "OPEN_AMI", (id) ->
            #     PropertyModule.loadSubPanel "STATIC", id
            null

        initStack : ()->
            @model = model
            @view  = view
            null

        afterLoadStack : ()->
            # sglist_main.loadModule @model
            null

        setupApp : () ->

            me = this

            # @model.on "KEYPAIR_DOWNLOAD", ( success, data, data2 ) ->
            #     me.view.updateKPModal 'download', success, data, data2

            # @model.on "PASSWORD_STATE", ( data ) ->
            #     me.view.updateKPModal 'check', data

            # @model.on "PASSWORD_GOT", ( data ) ->
            #     me.view.updateKPModal 'got', data

            # @view.on "OPEN_AMI", (id) ->
            #     PropertyModule.loadSubPanel "STATIC", id

            null

        initApp : () ->
            @model = app_model
            @view  = app_view
            null

        afterLoadApp : () ->
            # sglist_main.loadModule @model
            null
    }
    null
