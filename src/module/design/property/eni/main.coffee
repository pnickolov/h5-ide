####################################
#  Controller for design/property/eni module
####################################

define [ "../base/main",
         "./model",
         "./view",
         "./app_model",
         "./app_view",
         "../sglist/main",
         'event',
         "constant"
], ( PropertyModule, model, view, app_model, app_view, sglist_main, ide_event, constant )->

    ideEvents = {}
    ideEvents[ ide_event.PROPERTY_REFRESH_ENI_IP_LIST ] = () ->
        @view.refreshIPList()
        null

    EniModule = PropertyModule.extend {

        ideEvents : ideEvents

        handleTypes : constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface

        onUnloadSubPanel : ( id )->
            sglist_main.onUnloadSubPanel id
            null

        setupStack : () ->

            me = this

            @view.on 'SET_ENI_DESC', ( uid, value ) ->
                me.model.setEniDesc uid, value

            @view.on 'SET_ENI_SOURCE_DEST_CHECK', ( uid, check ) ->
                me.model.setSourceDestCheck uid, check

            @view.on 'ADD_NEW_IP', ( uid ) ->
                me.model.addNewIP uid

            @view.on 'ATTACH_EIP', ( uid, index, attach ) ->
                me.model.attachEIP uid, index, attach

            @view.on 'REMOVE_IP', ( uid, index ) ->
                me.model.removeIP uid, index

            @view.on 'SET_IP_LIST', (inputIPAry) ->
                me.model.setIPList inputIPAry
            null

        initStack : () ->
            @model = model
            @view  = view
            null

        afterLoadStack : () ->
            if not @model.attributes.association
                sglist_main.loadModule @model

        initApp : () ->
            @model = app_model
            @view  = app_view
            null

        afterLoadApp : () ->
            sglist_main.loadModule @model
            null
    }
    null
